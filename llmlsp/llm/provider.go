package llm

import (
	"context"
)

// Speaker is the speaker of a message.
type Speaker string

const (
	User      Speaker = "user"
	Assistant Speaker = "assistant"
	System    Speaker = "system"
)

// Message is a message sent to or by the LLM.
type Message struct {
	Speaker Speaker `json:"speaker"`
	Text    string  `json:"text"`
}

type Options struct {
	MaxTokens int
}

type StreamCompletionParams struct {
	Messages    []Message `json:"messages"`
	TopP        float32   `json:"topP"`
	Temperature float32   `json:"temperature"`
	MaxTokens   int       `json:"maxTokens"`
}

// Provider is the interface for LLM providers.
type Provider interface {
	StreamCompletion(context.Context, StreamCompletionParams) (<-chan string, error)
}

func (o *Options) setDefaults() {
	if o.MaxTokens == 0 {
		o.MaxTokens = 1000
	}
}
