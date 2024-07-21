package types

import (
	"encoding/json"

	"github.com/crackcomm/llmlsp/llmlsp/llm"
	"github.com/sourcegraph/go-lsp"
)

type MemoryFileMap map[lsp.DocumentURI]string

type LLMLSPSettings struct {
	Colab *SourcegraphSettings `json:"colab"`
}

type SourcegraphSettings struct {
	URL              string   `json:"url"`
	AccessToken      string   `json:"accessToken"`
	RepoEmbeddings   []string `json:"repos"`
	AnonymousUIDFile string   `json:"uidFile"`
}

type ConfigurationSettings struct {
	LLMLSP LLMLSPSettings `json:"llmlsp"`
}

type DidChangeConfigurationParams struct {
	Settings ConfigurationSettings `json:"settings"`
}

// type TextDocumentEdit struct {
// 	TextDocument lsp.VersionedTextDocumentIdentifier `json:"textDocument"`
// 	Edits        []lsp.TextEdit                      `json:"edits"`
// }
//
// type WorkspaceEdit struct {
// 	DocumentChanges []TextDocumentEdit `json:"documentChanges"`
// }

type ApplyWorkspaceEditParams struct {
	Edit lsp.WorkspaceEdit `json:"edit"`
}

type ProgressParams[T any] struct {
	Token string `json:"token"`
	Value T      `json:"value"`
}

type WorkDoneProgressBegin struct {
	Title   string `json:"title"`
	Kind    string `json:"kind"`
	Message string `json:"message"`
}

type WorkDoneProgressEnd struct {
	Kind    string `json:"kind"`
	Message string `json:"message"`
}

type WorkDoneProgressCreateParams struct {
	Token string `json:"token"`
}

type CodeActionContext struct {
	lsp.CodeActionContext
	Only []string `json:"only,omitempty"`
}

type CodeActionParams struct {
	TextDocument lsp.TextDocumentIdentifier `json:"textDocument"`
	Range        lsp.Range                  `json:"range"`
	Context      CodeActionContext          `json:"context"`
}

type ExecuteCommandParams struct {
	Command       string            `json:"command"`
	Arguments     []json.RawMessage `json:"arguments,omitempty"`
	WorkDoneToken string            `json:"workDoneToken"`
}

type ChatPromptParams struct {
	Id             string `json:"id"`
	MessageId      string `json:"messageId"`
	HumanChatInput string `json:"humanChatInput"`
}

type ChatResponseParams struct {
	MessageId string      `json:"messageId"`
	Value     llm.Message `json:"value"`
}

type InsertTextMode int

const (
	ITMAsIs              InsertTextMode = 1
	ITMAdjustIndentation                = 2
)

type CompletionItem struct {
	Label            string                 `json:"label"`
	Kind             lsp.CompletionItemKind `json:"kind,omitempty"`
	Detail           string                 `json:"detail,omitempty"`
	Documentation    string                 `json:"documentation,omitempty"`
	SortText         string                 `json:"sortText,omitempty"`
	FilterText       string                 `json:"filterText,omitempty"`
	InsertText       string                 `json:"insertText,omitempty"`
	InsertTextFormat lsp.InsertTextFormat   `json:"insertTextFormat,omitempty"`
	InsertTextMode   InsertTextMode         `json:"insertTextMode,omitempty"`
	TextEdit         *lsp.TextEdit          `json:"textEdit,omitempty"`
	Data             interface{}            `json:"data,omitempty"`
	Preselect        bool                   `json:"preselect,omitempty"`
}

type CompletionList struct {
	IsIncomplete bool             `json:"isIncomplete"`
	Items        []CompletionItem `json:"items"`
}

type InlayHintParams struct {
	TextDocument lsp.TextDocumentIdentifier `json:"textDocument"`
	Range        lsp.Range                  `json:"range"`
}

type InlayHint struct {
	Position     lsp.Position  `json:"position"`
	Label        string        `json:"label"`
	Kind         InlayHintKind `json:"kind,omitempty"`
	Tooltip      string        `json:"tooltip,omitempty"`
	PaddingLeft  bool          `json:"paddingLeft,omitempty"`
	PaddingRight bool          `json:"paddingRight,omitempty"`
}

type InlayHintKind int

const (
	InlayHintKind_None      = 0
	InlayHintKind_Type      = 1
	InlayHintKind_Parameter = 2
)
