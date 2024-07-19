package llm

import "context"

func GetCompletion(ctx context.Context, provider Provider, params StreamCompletionParams) (completion string, err error) {
	stream, err := provider.StreamCompletion(ctx, params)
	if err != nil {
		return
	}
	for content := range stream {
		completion = content
	}
	return
}
