package lsp

import (
	"context"

	"github.com/crackcomm/llmlsp/llmlsp/lsp/types"
	"github.com/google/uuid"
	"github.com/sourcegraph/go-lsp"
	"github.com/sourcegraph/jsonrpc2"
)

func createProgress(ctx context.Context, conn *jsonrpc2.Conn) func() {
	uuid := uuid.New().String()
	var res any
	conn.Call(ctx, "window/workDoneProgress/create", types.WorkDoneProgressCreateParams{
		Token: uuid,
	}, &res)
	conn.Notify(ctx, "$/progress", types.ProgressParams[types.WorkDoneProgressBegin]{
		Token: uuid,
		Value: types.WorkDoneProgressBegin{
			Title:   "Code actions",
			Kind:    "begin",
			Message: "Computing code actions...",
		},
	})
	done := func() {
		conn.Notify(ctx, "$/progress", types.ProgressParams[types.WorkDoneProgressEnd]{
			Token: uuid,
			Value: types.WorkDoneProgressEnd{
				Message: "Code actions computed",
				Kind:    "end",
			},
		})
	}
	return done
}

func createEdit(dr lsp.Location, newText string) types.ApplyWorkspaceEditParams {
	edits := []lsp.TextEdit{
		{
			Range:   dr.Range,
			NewText: newText,
		},
	}
	return types.ApplyWorkspaceEditParams{
		Edit: lsp.WorkspaceEdit{
			Changes: map[string][]lsp.TextEdit{
				string(dr.URI): edits,
			},
		},
	}
}
