package services

import (
	"context"
	"errors"

	"golang.org/x/crypto/bcrypt"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

// AccountService сервис для работы с аккаунтами пользователей
type AccountService struct {
	users    repositories.UserRepository    // Репозиторий пользователей
	sessions repositories.SessionRepository // Репозиторий сессий
}

// NewAccountService создает новый экземпляр сервиса аккаунтов
func NewAccountService(users repositories.UserRepository, sessions repositories.SessionRepository) *AccountService {
	return &AccountService{users: users, sessions: sessions}
}

// DeleteAccount удаляет аккаунт пользователя
// Проверяет пароль перед удалением для безопасности
func (s *AccountService) DeleteAccount(ctx context.Context, userID domain.ID, password string) error {
	if password == "" {
		return errors.New("пароль обязателен")
	}

	u, err := s.users.GetUser(ctx, userID)
	if err != nil {
		return err
	}
	if u == nil {
		return errors.New("пользователь не найден")
	}

	// Проверяем пароль пользователя перед удалением аккаунта
	if err := bcrypt.CompareHashAndPassword([]byte(u.PasswordHash), []byte(password)); err != nil {
		return errors.New("неверный пароль")
	}

	// Отзываем все сессии пользователя (на случай, если удаление не сработает мгновенно)
	_ = s.sessions.RevokeAllForUser(ctx, userID)

	// Удаляем пользователя из базы данных
	return s.users.DeleteUser(ctx, userID)
}
