package lsp

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"os"

	"github.com/crackcomm/llmlsp/llmlsp/llm"
	"github.com/crackcomm/llmlsp/llmlsp/lsp/router"
	"github.com/crackcomm/llmlsp/llmlsp/lsp/types"
	"github.com/crackcomm/llmlsp/llmlsp/util"
	"github.com/sourcegraph/go-lsp"
	"github.com/sourcegraph/jsonrpc2"
)

type Server struct {
	Debug       bool
	LLMProvider llm.Provider

	files       *files
	router      *router.Router
	initialized bool
}

// NewServer creates a new server instance.
func NewServer() *Server {
	s := &Server{
		LLMProvider: llm.NewOpenAI(&llm.Options{}),
		files:       newFiles(),
		router:      router.NewRouter(),
	}

	registerHandler(s, "initialize", s.initialize)
	registerHandler(s, "textDocument/didChange", s.textDocumentDidChange)
	registerHandler(s, "textDocument/didOpen", s.textDocumentDidOpen)
	registerHandler(s, "textDocument/codeAction", requiresInitialized(s, s.textDocumentCodeAction))
	registerHandler(s, "textDocument/completion", requiresInitialized(s, s.textDocumentCompletion))
	registerHandler(s, "workspace/didChangeConfiguration", s.workspaceDidChangeConfiguration)
	registerHandler(s, "workspace/executeCommand", requiresInitialized(s, s.workspaceExecuteCommand))
	registerHandler(s, "chat/execMessage", requiresInitialized(s, s.chatExecMessage))
	registerHandler(s, "textDocument/inlayHint", requiresInitialized(s, s.inlayHint))
	registerHandler(s, "shutdown", s.shutdown)

	return s
}

func (s *Server) Handle(ctx context.Context, conn *jsonrpc2.Conn, req *jsonrpc2.Request) {
	log.Printf("Received request: %s", req.Method)
	s.router.Handle(ctx, conn, req)
}

func (s *Server) initialize(ctx context.Context, conn *jsonrpc2.Conn, _ *jsonrpc2.Request, params lsp.InitializeParams) (any, error) {
	s.initialized = true

	opts := lsp.TextDocumentSyncOptionsOrKind{
		Options: &lsp.TextDocumentSyncOptions{
			OpenClose: true,
			WillSave:  true,
			Change:    lsp.TDSKFull,
		},
	}
	ecopts := lsp.ExecuteCommandOptions{
		Commands: []string{
			"todos",
			"suggest",
			"answer",
			"docstring",
			"llmlsp",
			"llmlsp.explain",
			"llmlsp.explainErrors",
			"llmlsp.remember",
			"llmlsp.forget",
			"llmlsp.chat/history",
			"llmlsp.chat/message",
			"testCommand",
		},
	}
	return lsp.InitializeResult{
		Capabilities: lsp.ServerCapabilities{
			TextDocumentSync:       &opts,
			CodeActionProvider:     true,
			CompletionProvider:     &lsp.CompletionOptions{},
			ExecuteCommandProvider: &ecopts,
		},
	}, nil
}

func (s *Server) textDocumentDidChange(_ context.Context, _ *jsonrpc2.Conn, _ *jsonrpc2.Request, params lsp.DidChangeTextDocumentParams) (any, error) {
	s.files.set(params.TextDocument.URI, params.ContentChanges[0].Text)
	return nil, nil
}

func (s *Server) textDocumentDidOpen(_ context.Context, _ *jsonrpc2.Conn, _ *jsonrpc2.Request, params lsp.DidOpenTextDocumentParams) (any, error) {
	s.files.set(params.TextDocument.URI, params.TextDocument.Text)
	return nil, nil
}

func (s *Server) workspaceExecuteCommand(ctx context.Context, conn *jsonrpc2.Conn, req *jsonrpc2.Request, params types.ExecuteCommandParams) (any, error) {
	done := createProgress(ctx, conn)
	defer done()

	switch params.Command {
	case "docstring":
		var cmdParams lsp.Location
		if err := json.Unmarshal(params.Arguments[0], &cmdParams); err != nil {
			return nil, err
		}

		// get content of the location
		code, ok := s.files.getLocationCode(cmdParams)
		if !ok {
			return nil, errors.New("failed to get location text")
		}

		// TODO: prompting
		messages := []llm.Message{
			{
				Speaker: llm.System,
				Text: "Generate a concise docstring for the following code snippet." +
					" Include the entire function with the new docstring." +
					" Reply only with the code, nothing else." +
					" Enclose it in a markdown style block.\n\n",
			},
			{
				Speaker: llm.User,
				Text:    code,
			},
		}

		completion, err := llm.GetCompletion(ctx, s.LLMProvider, llm.StreamCompletionParams{
			Messages: messages,
		})
		if err != nil {
			return nil, err
		}

		completion = util.ExtractCode(completion)
		editResponse := createEdit(cmdParams, completion)

		var res json.RawMessage
		return nil, conn.Call(ctx, "workspace/applyEdit", editResponse, &res)

	case "testCommand":
		var cmdParams lsp.Location
		if err := json.Unmarshal(params.Arguments[0], &cmdParams); err != nil {
			return nil, err
		}

		editResponse := createEdit(cmdParams, "this\nis\na\nmultiline\nchange\n")

		var res json.RawMessage
		return nil, conn.Call(ctx, "workspace/applyEdit", editResponse, &res)

	case "diagnosticTest":
		var cmdParams lsp.Location
		if err := json.Unmarshal(params.Arguments[0], &cmdParams); err != nil {
			return nil, err
		}
		return nil, s.sendDiagnostics(ctx, conn, cmdParams)
	}

	return nil, fmt.Errorf("unknown command: %s", params.Command)
}

func (s *Server) getCodeActions(doc lsp.DocumentURI, selection lsp.Range) []lsp.Command {
	commands := []lsp.Command{
		{
			Title:     "Provide suggestions",
			Command:   "suggest",
			Arguments: []interface{}{doc, selection.Start.Line, selection.End.Line},
		},
		{
			Title:     "Generate docstring",
			Command:   "docstring",
			Arguments: []interface{}{lsp.Location{URI: doc, Range: selection}},
		},
		{
			Title:     "LLMLSP: Remember this",
			Command:   "llmlsp.remember",
			Arguments: []interface{}{doc, selection.Start.Line, selection.End.Line},
		},
		{
			Title:     "LLMSP: test command",
			Command:   "testCommand",
			Arguments: []interface{}{lsp.Location{URI: doc, Range: selection}},
		},
		{
			Title:     "LLMSP: diagnostic test",
			Command:   "diagnosticTest",
			Arguments: []interface{}{lsp.Location{URI: doc, Range: selection}},
		},
	}
	// if len(l.InteractionMemory) > 0 {
	// 	commands = append(commands, lsp.Command{
	// 		Title:   "Cody: Forget",
	// 		Command: "llmlsp.forget",
	// 	})
	// }
	// cp := repoutil.CommentPrefix(repoutil.DetermineLanguage(string(doc)))
	// if strings.Contains(strings.Join(strings.Split(l.FileMap[doc], "\n")[selection.Start.Line:selection.End.Line+1], "\n"), fmt.Sprintf("%s TODO", cp)) {
	// 	commands = append(commands, lsp.Command{
	// 		Title:     "Implement TODOs",
	// 		Command:   "todos",
	// 		Arguments: []interface{}{doc, selection.Start.Line, selection.End.Line},
	// 	})
	// }
	// if strings.Contains(strings.Join(strings.Split(l.FileMap[doc], "\n")[selection.Start.Line:selection.End.Line+1], "\n"), fmt.Sprintf("%s ASK", cp)) {
	// 	commands = append(commands, lsp.Command{
	// 		Title:     "Answer question",
	// 		Command:   "answer",
	// 		Arguments: []interface{}{doc, selection.Start.Line, selection.End.Line},
	// 	})
	// }
	return commands
}

func (s *Server) textDocumentCodeAction(_ context.Context, conn *jsonrpc2.Conn, _ *jsonrpc2.Request, params types.CodeActionParams) (any, error) {
	/* go func() {
		time.Sleep(time.Second * 2)
		ctx := context.Background()
		err := conn.Notify(ctx, "window/showMessage", lsp.LogMessageParams{Type: lsp.Info, Message: "hello world from code actions"})
		if err != nil {
			log.Printf("error: %s", err)
		}
	}() */

	commands := s.getCodeActions(params.TextDocument.URI, params.Range)
	for _, diagnostic := range params.Context.Diagnostics {
		commands = append(commands, lsp.Command{
			Title:     fmt.Sprintf("Explain error: %s", diagnostic.Message),
			Command:   "llmlsp.explainErrors",
			Arguments: []any{diagnostic.Message},
		})
	}

	// select context only commands if requested
	if len(params.Context.Only) > 0 {
		var filteredCommands []lsp.Command
		for _, command := range commands {
			for _, filteredCommand := range params.Context.Only {
				if filteredCommand == command.Command {
					filteredCommands = append(filteredCommands, command)
					break
				}
			}
		}
		return filteredCommands, nil
	}

	return commands, nil
}

func (s *Server) textDocumentCompletion(ctx context.Context, conn *jsonrpc2.Conn, _ *jsonrpc2.Request, params lsp.CompletionParams) (any, error) {
	done := createProgress(ctx, conn)
	defer done()

	textEdit := &lsp.TextEdit{
		Range: lsp.Range{
			Start: lsp.Position{
				Line: params.Position.Line,
			},
			End: params.Position,
		},
		NewText: "test: insert some text\nwith\nmultiple\nlines\nwith\nmultiple\nlines\nwith\nmultiple\nlines\nwith\nmultiple\nlines\nwith\nmultiple\nlines\nwith\nmultiple\nlines\nwith\nmultiple\nlines\nwith\nmultiple\nlines\nwith\nmultiple\nlines\nwith\nmultiple\nlines\nwith\nmultiple\nlines",
	}

	completions := []types.CompletionItem{
		{
			Label:            "test",
			InsertText:       textEdit.NewText,
			InsertTextMode:   types.ITMAdjustIndentation,
			InsertTextFormat: lsp.ITFSnippet,
			Kind:             lsp.CIKSnippet,
			Preselect:        true,
		},
	}

	return types.CompletionList{
		IsIncomplete: true,
		Items:        completions,
	}, nil
}

func (s *Server) workspaceDidChangeConfiguration(ctx context.Context, conn *jsonrpc2.Conn, _ *jsonrpc2.Request, params types.DidChangeConfigurationParams) (any, error) {
	s.initialized = true
	conn.Notify(ctx, "window/logMessage", lsp.LogMessageParams{Type: lsp.MTWarning, Message: "LLMSP initialized!"})
	return nil, nil
}

func (s *Server) chatExecMessage(ctx context.Context, conn *jsonrpc2.Conn, _ *jsonrpc2.Request, params types.ChatPromptParams) (any, error) {
	log.Printf("chatExecMessage Params: %v", params.HumanChatInput)

	messages, err := s.LLMProvider.StreamCompletion(ctx, llm.StreamCompletionParams{
		Messages: []llm.Message{{
			Speaker: llm.User,
			Text:    params.HumanChatInput,
		}},
	})
	if err != nil {
		log.Printf("Completion error: %v", err)
		return nil, err
	}

	for msg := range messages {
		log.Printf("chatExecMessage: %v", msg)
		conn.Notify(ctx, "chat/updateMessageInProgress", types.ProgressParams[llm.Message]{
			Token: params.MessageId,
			Value: llm.Message{
				Speaker: llm.Assistant,
				Text:    msg,
			},
		})
	}

	return nil, nil
}

func (l *Server) sendDiagnostics(ctx context.Context, conn *jsonrpc2.Conn, params lsp.Location) error {
	diagnostics := []lsp.Diagnostic{
		lsp.Diagnostic{
			Range: lsp.Range{
				Start: lsp.Position{
					Line:      params.Range.Start.Line,
					Character: 0,
				},
				End: lsp.Position{
					Line:      params.Range.End.Line,
					Character: 0,
				},
			},
			Severity: lsp.Hint,
			Message:  "My smart message",
		},
	}
	diagnostic := lsp.PublishDiagnosticsParams{
		URI:         params.URI,
		Diagnostics: diagnostics,
	}
	if err := conn.Notify(ctx, "textDocument/publishDiagnostics", diagnostic); err != nil {
		return err
	}
	return nil
}

func (s *Server) inlayHint(_ context.Context, conn *jsonrpc2.Conn, _ *jsonrpc2.Request, params types.InlayHintParams) (any, error) {
	hints := []types.InlayHint{
		// {
		// 	Position: lsp.Position{
		// 		Line:      7,
		// 		Character: 5,
		// 	},
		// 	Label:       "some hint label",
		// 	Tooltip:     "some tooltip",
		// 	Kind:        types.InlayHintKind_Type,
		// 	PaddingLeft: true,
		// },
	}
	return hints, nil
}

func (s *Server) shutdown(_ context.Context, _ *jsonrpc2.Conn, _ *jsonrpc2.Request, params json.RawMessage) (any, error) {
	os.Exit(1)
	return nil, nil
}
