package types

import (
	"time"
)

// Base types for consistent definitions
type ID int64
type Timestamp time.Time

// Common response types
type Response[T any] struct {
	Data T      `json:"data"`
	Meta Meta   `json:"meta"`
}

type Meta struct {
	Total int `json:"total"`
}

// Common error type
type AppError struct {
	Code    string `json:"code"`
	Message string `json:"message"`
}