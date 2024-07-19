package server

import (
	"context"
	"os"
	"os/signal"

	"github.com/crackcomm/llmlsp/llmlsp/lsp"
	"github.com/sourcegraph/jsonrpc2"
)

func ServeStdio(server *lsp.Server) {
	ctx, cancel := signalContext(context.Background(), os.Interrupt)
	defer cancel()

	<-jsonrpc2.NewConn(
		ctx,
		jsonrpc2.NewBufferedStream(stdio{}, jsonrpc2.VSCodeObjectCodec{}),
		jsonrpc2.AsyncHandler(server),
	).DisconnectNotify()
}

func signalContext(parentCtx context.Context, signals ...os.Signal) (ctx context.Context, stop context.CancelFunc) {
	ctx, cancel := context.WithCancel(parentCtx)
	ch := make(chan os.Signal, 1)
	go func() {
		select {
		case <-ch:
			cancel()
		case <-ctx.Done():
		}
	}()
	signal.Notify(ch, signals...)

	return ctx, cancel
}

type stdio struct{}

func (stdio) Read(p []byte) (int, error) {
	return os.Stdin.Read(p)
}

func (stdio) Write(p []byte) (int, error) {
	return os.Stdout.Write(p)
}

func (stdio) Close() error {
	if err := os.Stdin.Close(); err != nil {
		return err
	}
	return os.Stdout.Close()
}
