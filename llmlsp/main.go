package main

import (
	"log"
	"os"

	"github.com/alecthomas/kong"
	"github.com/crackcomm/llmlsp/llmlsp/lsp"
	"github.com/crackcomm/llmlsp/llmlsp/server"
)

type cli struct {
	Debug   bool   `name:"debug" help:"Enable debugging mode."`
	LogFile string `name:"log-file" help:"Log file."`
}

func main() {
	var cli cli
	kong.Parse(&cli)

	if cli.LogFile != "" {
		f, err := os.OpenFile("/tmp/llmsp.log", os.O_RDWR|os.O_CREATE|os.O_APPEND, 0666)
		if err != nil {
			log.Fatalf("Opening log file err: %v", err)
		}
		// defer f.Close()
		log.SetOutput(f)
	}

	srv := lsp.NewServer()
	srv.Debug = cli.Debug

	server.ServeStdio(srv)
}
