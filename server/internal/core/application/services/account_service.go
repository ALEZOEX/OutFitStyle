package services

import (
	"context"
	"errors"

	"golang.org/x/crypto/bcrypt"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

type AccountService struct {
	users    repositories.UserRepository
	sessions repositories.SessionRepository
}

func NewAccountService(users repositories.UserRepository, sessions repositories.SessionRepository) *AccountService {
	return &AccountService{users: users, sessions: sessions}
}

func (s *AccountService) DeleteAccount(ctx context.Context, userID domain.ID, password string) error {
	if password == "" {
		return errors.New("password is required")
	}

	u, err := s.users.GetUser(ctx, userID)
	if err != nil {
		return err
	}
	if u == nil {
		return repositories.ErrNotFound
	}

	if err := bcrypt.CompareHashAndPassword([]byte(u.PasswordHash), []byte(password)); err != nil {
		return errors.New("invalid password")
	}

	// Сессии ревокнем (на случай, если delete не сработает мгновенно)
	_ = s.sessions.RevokeAllForUser(ctx, userID)
	return s.users.DeleteUser(ctx, userID)
}