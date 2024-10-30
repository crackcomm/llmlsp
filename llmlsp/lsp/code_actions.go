package lsp

import (
	"context"
	"encoding/json"
	"errors"

	"github.com/crackcomm/llmlsp/llmlsp/llm"
	"github.com/crackcomm/llmlsp/llmlsp/util"
	"github.com/sourcegraph/go-lsp"
	"github.com/sourcegraph/jsonrpc2"
)

func (s *Server) docstringAction(ctx context.Context, conn *jsonrpc2.Conn, params lsp.Location) (any, error) {
	// get content of the location
	code, ok := s.workspace.Files.LocationCode(params)
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
	editResponse := createEdit(params, completion)

	var res json.RawMessage
	return nil, conn.Call(ctx, "workspace/applyEdit", editResponse, &res)
}

func (s *Server) diagnosticTestAction(ctx context.Context, conn *jsonrpc2.Conn, params lsp.Location) (any, error) {
	return nil, s.sendDiagnostics(ctx, conn, params)
}
