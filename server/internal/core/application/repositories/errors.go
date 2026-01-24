package repositories

import "errors"

// Общие ошибки, используемые в репозиториях
var (
	// ErrEmailAlreadyExists возвращается, когда пользователь с таким email уже существует
	ErrEmailAlreadyExists = errors.New("email already exists")

	// ErrNotFound возвращается, когда запрашиваемый ресурс не найден
	ErrNotFound = errors.New("not found")

	// ErrForbidden возвращается, когда доступ к ресурсу запрещен
	ErrForbidden = errors.New("forbidden")
)
