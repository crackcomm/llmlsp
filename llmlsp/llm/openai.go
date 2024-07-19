package llm

import (
	"context"
	"os"

	"github.com/pkg/errors"
	openai "github.com/sashabaranov/go-openai"
)

type OpenAIProvider struct {
	opts   *Options
	client *openai.Client
}

func NewOpenAI(opts *Options) *OpenAIProvider {
	opts.setDefaults()
	token := os.Getenv("OPENAI_API_KEY")
	client := openai.NewClient(token)
	return &OpenAIProvider{opts: opts, client: client}
}

func openAIMessages(messages []Message) []openai.ChatCompletionMessage {
	var openAIMessages []openai.ChatCompletionMessage
	for _, msg := range messages {
		openAIMessages = append(openAIMessages, openai.ChatCompletionMessage{
			Role:    string(msg.Speaker),
			Content: msg.Text,
		})
	}
	return openAIMessages
}

func (p *OpenAIProvider) StreamCompletion(ctx context.Context, params StreamCompletionParams) (<-chan string, error) {
	maxTokens := params.MaxTokens
	if maxTokens == 0 {
		maxTokens = p.opts.MaxTokens
	}
	resp, err := p.client.CreateChatCompletionStream(
		ctx,
		openai.ChatCompletionRequest{
			Model:       "gpt-4o-mini",
			MaxTokens:   maxTokens,
			TopP:        params.TopP,
			Temperature: params.Temperature,
			Messages:    openAIMessages(params.Messages),
		},
	)
	if err != nil {
		return nil, errors.Wrapf(err, "create chat completion stream")
	}

	out := make(chan string)

	go func() {
		var content string
		for {
			msg, err := resp.Recv()
			if err != nil {
				panic(err) // TODO
			}
			choice := msg.Choices[0]
			if choice.FinishReason == openai.FinishReasonStop {
				close(out)
				break
			}
			content += choice.Delta.Content
			out <- content
		}
	}()

	return out, nil
}
