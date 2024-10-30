package lsp

import (
	"context"
	"encoding/json"
	"errors"

	"github.com/crackcomm/llmlsp/llmlsp/lsp/router"
	"github.com/sourcegraph/jsonrpc2"
)

// LSPHandler is a generic type for LSP Handlers that take parameters of type T.
type LSPHandler[T any] func(context.Context, *jsonrpc2.Conn, *jsonrpc2.Request, T) (any, error)

// LSPHandlerFunc takes an LSPHandler, wraps it in an error handler and unmarshals
// the request parameters before calling the provided handler.
func LSPHandlerFunc[T any](fn LSPHandler[T]) router.HandlerFunc {
	return jsonrpc2.HandlerWithError(
		func(ctx context.Context, conn *jsonrpc2.Conn, req *jsonrpc2.Request) (any, error) {
			var params T
			if req.Params != nil {
				if err := json.Unmarshal(*req.Params, &params); err != nil {
					return nil, err
				}
			}

			return fn(ctx, conn, req, params)
		},
	).Handle
}

// registerHandler is a convenience function to register handlers on a server
// and reduce the boilerplate of calling LSPHandlerFunc on every handler.
func registerHandler[T any](s *Server, method string, handler LSPHandler[T]) {
	s.router.Register(method, LSPHandlerFunc(handler))
}

// requiresInitialized is middleware that checks whether or not the server has been
// initialized. If not, it returns an error.
func requiresInitialized[T any](s *Server, handler LSPHandler[T]) LSPHandler[T] {
	return func(ctx context.Context, conn *jsonrpc2.Conn, req *jsonrpc2.Request, params T) (any, error) {
		if !s.initialized {
			return nil, errors.New("server has not yet been initialized")
		}

		return handler(ctx, conn, req, params)
	}
}

// ExecuteCommandHandler is a type for handling LSP ExecuteCommand requests.
type ExecuteCommandHandler func(ctx context.Context, conn *jsonrpc2.Conn, params *json.RawMessage) (any, error)

func executeCommandHandler[T any](fn func(ctx context.Context, conn *jsonrpc2.Conn, params T) (any, error)) ExecuteCommandHandler {
	return func(ctx context.Context, conn *jsonrpc2.Conn, params *json.RawMessage) (any, error) {
		var p T
		if err := json.Unmarshal(*params, &p); err != nil {
			return nil, err
		}
		return fn(ctx, conn, p)
	}
}
