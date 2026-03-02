// Пакет routes содержит функции регистрации маршрутов для различных API-эндпоинтов
// Обеспечивает централизованную настройку маршрутов приложения
package routes

import (
	"outfitstyle/server/internal/api/handlers"

	"github.com/gorilla/mux"
)

// RegisterUserRoutes регистрирует маршруты, связанные с пользователями
// Устанавливает обработчики для эндпоинтов управления профилем пользователя
func RegisterUserRoutes(router *mux.Router, userHandler *handlers.UserHandler, passwordHandler *handlers.PasswordHandler) {
	users := router.PathPrefix("/api/users").Subrouter()
	userHandler.RegisterRoutes(users)

	// Маршруты управления паролем
	password := router.PathPrefix("/api/v1/user").Subrouter()
	passwordHandler.RegisterRoutes(password)
}
