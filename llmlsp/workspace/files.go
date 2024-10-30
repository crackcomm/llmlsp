package workspace

import (
	"strings"
	"sync"

	"github.com/crackcomm/llmlsp/llmlsp/lsp/types"
	"github.com/crackcomm/llmlsp/llmlsp/util"
	"github.com/sourcegraph/go-lsp"
)

type Files struct {
	fileMap types.MemoryFileMap
	mu      sync.Mutex
}

func NewFiles() *Files {
	return &Files{
		fileMap: make(types.MemoryFileMap),
	}
}

// SetText sets the text for a specific URI within the files.
func (f *Files) SetText(uri lsp.DocumentURI, text string) {
	f.mu.Lock()
	f.fileMap[uri] = text
	f.mu.Unlock()
}

// LocationText retrieves the text from a specific location defined by
// the input 'loc' within the files. It returns the text segment found at
// the provided location along with a boolean indicating if the text was
// successfully retrieved.
func (f *Files) LocationText(loc lsp.Location) (text string, ok bool) {
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

// LocationCode retrieves the formatted code for a given lsp.Location.
// It returns the formatted code as a string and a boolean indicating success.
// If the text for the location cannot be retrieved, it returns an empty string and false.
func (f *Files) LocationCode(loc lsp.Location) (text string, ok bool) {
	text, ok = f.LocationText(loc)
	if !ok {
		return
	}
	return util.FormatCode(string(loc.URI), text), true
}
