package util

import (
	"fmt"
	"path/filepath"
	"strings"
)

func CommentPrefix(language string) string {
	switch language {
	case "Go":
		return "//"
	case "Python":
		return "#"
	case "JavaScript":
		return "//"
	case "TypeScript":
		return "//"
	case "TypeScript React":
		return "//"
	case "Java":
		return "//"
	case "C":
		return "//"
	case "C++":
		return "//"
	case "Lua":
		return "--"
	case "Ruby":
		return "#"
	case "PHP":
		return "#"
	case "C#":
		return "//"
	default:
		return ""
	}
}

func DetermineLanguage(filename string) string {
	ext := filepath.Ext(filename)
	switch ext {
	case ".go":
		return "Go"
	case ".py":
		return "Python"
	case ".js":
		return "JavaScript"
	case ".ts":
		return "TypeScript"
	case ".tsx":
		return "TypeScript React"
	case ".java":
		return "Java"
	case ".c":
		return "C"
	case ".cpp":
		return "C++"
	case ".lua":
		return "Lua"
	case ".rb":
		return "Ruby"
	case ".php":
		return "PHP"
	case ".cs":
		return "C#"
	case ".bzl":
		return "Starlark"
	default:
		return strings.TrimPrefix(ext, ".")
	}
}

func GetFileSnippet(fileContent string, startLine, endLine int) string {
	fileLines := strings.Split(fileContent, "\n")
	return strings.Join(fileLines[startLine:endLine+1], "\n")
}

func NumberLines(content string, startLine int) string {
	lines := strings.Split(content, "\n")
	for i, line := range lines {
		lines[i] = fmt.Sprintf("%d. %s", i+startLine, line)
	}
	return strings.Join(lines, "\n")
}
