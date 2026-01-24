package services

import (
	"fmt"
	"strings"
)

// ValidationError represents a validation error with field-specific messages
type ValidationError struct {
	Errors map[string]string
}

func NewValidationError(errors map[string]string) *ValidationError {
	return &ValidationError{Errors: errors}
}

func (e *ValidationError) Error() string {
	var errorStrings []string
	for field, message := range e.Errors {
		errorStrings = append(errorStrings, fmt.Sprintf("%s: %s", field, message))
	}
	return strings.Join(errorStrings, "; ")
}

func (e *ValidationError) HasErrors() bool {
	return len(e.Errors) > 0
}