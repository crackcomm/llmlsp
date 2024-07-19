package router

import (
	"context"

	"github.com/sourcegraph/jsonrpc2"
)

// HandlerFunc is a function type that handles a single JSON-RPC 2.0 request.
//
// The handler is passed the request context, a JSON-RPC connection, and the request object. The
// handler can reply to the request by calling the Reply method on the connection.
type HandlerFunc func(context.Context, *jsonrpc2.Conn, *jsonrpc2.Request)

// Handle implements the jsonrpc2.Handler interface for HandlerFunc.
func (h HandlerFunc) Handle(ctx context.Context, conn *jsonrpc2.Conn, req *jsonrpc2.Request) {
	h(ctx, conn, req)
}

// Router handles JSON-RPC 2.0 requests and dispatches them to the appropriate handler.
type Router struct {
	routes map[string]jsonrpc2.Handler
}

// NewRouter creates a new Router.
func NewRouter() *Router {
	return &Router{
		routes: make(map[string]jsonrpc2.Handler),
	}
}

// Register registers a new handler for the given JSON-RPC 2.0 method.
func (r *Router) Register(method string, handler jsonrpc2.Handler) {
	r.routes[method] = handler
}

// Handle dispatches a JSON-RPC 2.0 request to the appropriate handler.
// It responds with a MethodNotFound error if no handler is registered
// for the method.
func (r *Router) Handle(ctx context.Context, conn *jsonrpc2.Conn, req *jsonrpc2.Request) {
	if handler, ok := r.routes[req.Method]; ok {
		handler.Handle(ctx, conn, req)
		return
	}
}
