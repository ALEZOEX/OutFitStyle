package repositories

import "errors"

var (
	ErrEmailAlreadyExists = errors.New("email already exists")
	ErrNotFound           = errors.New("not found")
	ErrForbidden          = errors.New("forbidden")
)
