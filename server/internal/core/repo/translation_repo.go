package translation

import (
	"context"
)

// ServiceInterface defines the interface for the translation service
type ServiceInterface interface {
	Translate(ctx context.Context, text, sourceLang, targetLang string) (string, error)
	TranslateSlice(ctx context.Context, texts []string, sourceLang, targetLang string) ([]string, error)
	GetSupportedLanguages(ctx context.Context) []string
}