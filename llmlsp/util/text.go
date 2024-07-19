package util

import (
	"bufio"
	"strings"
)

const charsPerToken = 4

// TruncateText trims the end of the text, leaving only the first `maxTokens`.
func TruncateText(text string, maxTokens int) (string, int) {
	maxLength := maxTokens * charsPerToken
	if len(text) > maxLength {
		text = text[:maxLength]
	}

	return text, getTokenLength(text)
}

func getTokenLength(text string) int {
	return (len(text) + charsPerToken - 1) / charsPerToken
}

func SplitLines(s string) []string {
	var lines []string
	sc := bufio.NewScanner(strings.NewReader(s))
	for sc.Scan() {
		lines = append(lines, sc.Text())
	}
	return lines
}
