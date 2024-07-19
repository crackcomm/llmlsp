package lsp

import (
	"strings"
	"sync"

	"github.com/crackcomm/llmlsp/llmlsp/lsp/types"
	"github.com/crackcomm/llmlsp/llmlsp/util"
	"github.com/sourcegraph/go-lsp"
)

type files struct {
	fileMap types.MemoryFileMap
	mu      sync.Mutex
}

func newFiles() *files {
	return &files{
		fileMap: make(types.MemoryFileMap),
	}
}

func (f *files) set(uri lsp.DocumentURI, text string) {
	f.mu.Lock()
	f.fileMap[uri] = text
	f.mu.Unlock()
}

func (f *files) getLocationText(loc lsp.Location) (text string, ok bool) {
	f.mu.Lock()
	text, ok = f.fileMap[loc.URI]
	f.mu.Unlock()
	if !ok {
		return
	}

	lines := util.SplitLines(text)

	// get the lines from the range
	var selectedLines []string
	for i := loc.Range.Start.Line; i <= loc.Range.End.Line; i++ {
		selectedLines = append(selectedLines, lines[i])
	}

	// in first and last line get the text from the range
	last := len(selectedLines) - 1
	selectedLines[0] = selectedLines[0][loc.Range.Start.Character:]
	selectedLines[last] = selectedLines[last][:loc.Range.End.Character]

	// join the lines (no CRLF sorry)
	text = strings.Join(selectedLines, "\n")

	return
}

func (f *files) getLocationCode(loc lsp.Location) (text string, ok bool) {
	text, ok = f.getLocationText(loc)
	if !ok {
		return
	}
	return util.FormatCode(string(loc.URI), text), true
}
