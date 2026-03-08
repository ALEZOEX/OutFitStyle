package services

import (
	"context"
	"errors"
	"fmt"
	"time"

	"go.uber.org/zap"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

var (
	ErrSessionNotFound      = errors.New("session not found")
	ErrSessionExpired       = errors.New("session expired")
	ErrSessionInactive      = errors.New("session inactive")
	ErrMaxSessionsExceeded  = errors.New("maximum concurrent sessions exceeded")
	ErrUnauthorizedRevoke   = errors.New("unauthorized to revoke this session")
)

// SessionConfig конфигурация для управления сессиями
type SessionConfig struct {
	IdleTimeout         time.Duration // Таймаут неактивности (например, 30 минут)
	AbsoluteTimeout     time.Duration // Абсолютный таймаут (например, 24 часа)
	MaxConcurrentSessions int         // Максимальное количество одновременных сессий (например, 5)
}

// DefaultSessionConfig возвращает конфигурацию по умолчанию
func DefaultSessionConfig() SessionConfig {
	return SessionConfig{
		IdleTimeout:         30 * time.Minute,
		AbsoluteTimeout:     24 * time.Hour,
		MaxConcurrentSessions: 5,
	}
}

// SessionService сервис для управления сессиями пользователей
type SessionService struct {
	sessionRepo repositories.SessionRepository
	config      SessionConfig
	logger      *zap.Logger
}

// NewSessionService создает новый экземпляр сервиса сессий
func NewSessionService(
	sessionRepo repositories.SessionRepository,
	config SessionConfig,
	logger *zap.Logger,
) *SessionService {
	return &SessionService{
		sessionRepo: sessionRepo,
		config:      config,
		logger:      logger,
	}
}

// SessionInfo информация о сессии для отображения пользователю
type SessionInfo struct {
	ID              string     `json:"id"`
	DeviceInfo      *string    `json:"device_info,omitempty"`
	DeviceName      *string    `json:"device_name,omitempty"`
	DeviceType      *string    `json:"device_type,omitempty"`
	IPAddress       *string    `json:"ip_address,omitempty"`
	UserAgent       *string    `json:"user_agent,omitempty"`
	IsActive        bool       `json:"is_active"`
	IsCurrent       bool       `json:"is_current"`
	CreatedAt       *time.Time `json:"created_at"`
	LastUsedAt      *time.Time `json:"last_used_at"`
	ExpiresAt       *time.Time `json:"expires_at"`
}

// CreateSession создает новую сессию с проверкой лимитов
func (s *SessionService) CreateSession(ctx context.Context, params repositories.CreateSessionParams) (domain.ID, error) {
	// Проверяем количество активных сессий пользователя
	activeSessions, err := s.sessionRepo.ListByUser(ctx, params.UserID)
	if err != nil {
		s.logger.Error("Failed to list user sessions", zap.Error(err))
		return domain.ID{}, err
	}

	// Фильтруем только активные сессии
	activeCount := 0
	for _, sess := range activeSessions {
		if sess.IsActive && (sess.ExpiresAt == nil || time.Now().Before(*sess.ExpiresAt)) {
			activeCount++
		}
	}

	// Если превышен лимит, отзываем самую старую сессию
	if activeCount >= s.config.MaxConcurrentSessions {
		s.logger.Info("Max concurrent sessions reached, revoking oldest session",
			zap.String("user_id", params.UserID.String()),
			zap.Int("active_count", activeCount),
			zap.Int("max_allowed", s.config.MaxConcurrentSessions),
		)

		// Находим самую старую активную сессию
		var oldestSession *repositories.Session
		for i := range activeSessions {
			sess := &activeSessions[i]
			if sess.IsActive && (sess.ExpiresAt == nil || time.Now().Before(*sess.ExpiresAt)) {
				if oldestSession == nil || (sess.CreatedAt != nil && oldestSession.CreatedAt != nil && sess.CreatedAt.Before(*oldestSession.CreatedAt)) {
					oldestSession = sess
				}
			}
		}

		// Отзываем самую старую сессию
		if oldestSession != nil {
			if err := s.sessionRepo.Revoke(ctx, oldestSession.ID); err != nil {
				s.logger.Error("Failed to revoke oldest session", zap.Error(err))
				// Продолжаем создание новой сессии даже если не удалось отозвать старую
			}
		}
	}

	// Создаем новую сессию
	sessionID, err := s.sessionRepo.Create(ctx, params)
	if err != nil {
		s.logger.Error("Failed to create session", zap.Error(err))
		return domain.ID{}, err
	}

	s.logger.Info("Session created",
		zap.String("session_id", sessionID.String()),
		zap.String("user_id", params.UserID.String()),
	)

	return sessionID, nil
}

// ValidateSession проверяет сессию на активность и таймауты
func (s *SessionService) ValidateSession(ctx context.Context, sessionID domain.ID) (*repositories.Session, error) {
	session, err := s.sessionRepo.GetByID(ctx, sessionID)
	if err != nil {
		return nil, err
	}
	if session == nil {
		return nil, ErrSessionNotFound
	}

	// Проверяем, активна ли сессия
	if !session.IsActive {
		return nil, ErrSessionInactive
	}

	now := time.Now()

	// Проверяем абсолютный таймаут (expires_at)
	if session.ExpiresAt != nil && now.After(*session.ExpiresAt) {
		s.logger.Info("Session expired (absolute timeout)",
			zap.String("session_id", sessionID.String()),
			zap.Time("expires_at", *session.ExpiresAt),
		)
		// Автоматически отзываем истекшую сессию
		_ = s.sessionRepo.Revoke(ctx, sessionID)
		return nil, ErrSessionExpired
	}

	// Проверяем таймаут неактивности (last_used_at + idle_timeout)
	if session.LastUsedAt != nil {
		idleDeadline := session.LastUsedAt.Add(s.config.IdleTimeout)
		if now.After(idleDeadline) {
			s.logger.Info("Session expired (idle timeout)",
				zap.String("session_id", sessionID.String()),
				zap.Time("last_used_at", *session.LastUsedAt),
				zap.Duration("idle_timeout", s.config.IdleTimeout),
			)
			// Автоматически отзываем неактивную сессию
			_ = s.sessionRepo.Revoke(ctx, sessionID)
			return nil, ErrSessionExpired
		}
	}

	// Обновляем время последнего использования
	if err := s.sessionRepo.Touch(ctx, sessionID); err != nil {
		s.logger.Warn("Failed to touch session", zap.Error(err))
		// Не прерываем валидацию при ошибке обновления
	}

	return session, nil
}

// ListUserSessions возвращает список всех сессий пользователя
func (s *SessionService) ListUserSessions(ctx context.Context, userID domain.ID, currentSessionID *domain.ID) ([]SessionInfo, error) {
	sessions, err := s.sessionRepo.ListByUser(ctx, userID)
	if err != nil {
		s.logger.Error("Failed to list user sessions", zap.Error(err))
		return nil, err
	}

	result := make([]SessionInfo, 0, len(sessions))
	now := time.Now()

	for _, sess := range sessions {
		// Проверяем, не истекла ли сессия
		isExpired := false
		if sess.ExpiresAt != nil && now.After(*sess.ExpiresAt) {
			isExpired = true
		}
		if sess.LastUsedAt != nil {
			idleDeadline := sess.LastUsedAt.Add(s.config.IdleTimeout)
			if now.After(idleDeadline) {
				isExpired = true
			}
		}

		// Определяем, является ли это текущей сессией
		isCurrent := false
		if currentSessionID != nil && sess.ID == *currentSessionID {
			isCurrent = true
		}

		info := SessionInfo{
			ID:         sess.ID.String(),
			DeviceInfo: sess.DeviceInfo,
			DeviceName: sess.DeviceName,
			DeviceType: sess.DeviceType,
			IPAddress:  sess.IPAddress,
			UserAgent:  sess.UserAgent,
			IsActive:   sess.IsActive && !isExpired,
			IsCurrent:  isCurrent,
			CreatedAt:  sess.CreatedAt,
			LastUsedAt: sess.LastUsedAt,
			ExpiresAt:  sess.ExpiresAt,
		}

		result = append(result, info)
	}

	return result, nil
}

// RevokeSession отзывает конкретную сессию пользователя
func (s *SessionService) RevokeSession(ctx context.Context, userID, sessionID domain.ID) error {
	// Проверяем, что сессия принадлежит пользователю
	session, err := s.sessionRepo.GetByID(ctx, sessionID)
	if err != nil {
		return err
	}
	if session == nil {
		return ErrSessionNotFound
	}
	if session.UserID != userID {
		s.logger.Warn("Unauthorized session revoke attempt",
			zap.String("user_id", userID.String()),
			zap.String("session_id", sessionID.String()),
			zap.String("session_owner", session.UserID.String()),
		)
		return ErrUnauthorizedRevoke
	}

	if err := s.sessionRepo.Revoke(ctx, sessionID); err != nil {
		s.logger.Error("Failed to revoke session", zap.Error(err))
		return err
	}

	s.logger.Info("Session revoked",
		zap.String("session_id", sessionID.String()),
		zap.String("user_id", userID.String()),
	)

	return nil
}

// RevokeAllSessions отзывает все сессии пользователя кроме текущей
func (s *SessionService) RevokeAllSessions(ctx context.Context, userID domain.ID, exceptSessionID *domain.ID) error {
	sessions, err := s.sessionRepo.ListByUser(ctx, userID)
	if err != nil {
		s.logger.Error("Failed to list user sessions", zap.Error(err))
		return err
	}

	revokedCount := 0
	for _, sess := range sessions {
		// Пропускаем текущую сессию, если указана
		if exceptSessionID != nil && sess.ID == *exceptSessionID {
			continue
		}

		if sess.IsActive {
			if err := s.sessionRepo.Revoke(ctx, sess.ID); err != nil {
				s.logger.Error("Failed to revoke session",
					zap.String("session_id", sess.ID.String()),
					zap.Error(err),
				)
				// Продолжаем отзывать остальные сессии
				continue
			}
			revokedCount++
		}
	}

	s.logger.Info("Revoked all user sessions",
		zap.String("user_id", userID.String()),
		zap.Int("revoked_count", revokedCount),
	)

	return nil
}

// CleanupExpiredSessions удаляет истекшие сессии из базы данных
// Должен вызываться периодически (например, через cron job)
func (s *SessionService) CleanupExpiredSessions(ctx context.Context) error {
	// Удаляем сессии, у которых истек абсолютный таймаут
	sessions, err := s.sessionRepo.ListByUser(ctx, domain.ID{}) // Получаем все сессии
	if err != nil {
		s.logger.Error("Failed to list sessions for cleanup", zap.Error(err))
		return err
	}

	now := time.Now()
	deletedCount := 0

	for _, sess := range sessions {
		shouldDelete := false

		// Проверяем абсолютный таймаут
		if sess.ExpiresAt != nil && now.After(*sess.ExpiresAt) {
			shouldDelete = true
		}

		// Проверяем таймаут неактивности
		if sess.LastUsedAt != nil {
			idleDeadline := sess.LastUsedAt.Add(s.config.IdleTimeout)
			if now.After(idleDeadline) {
				shouldDelete = true
			}
		}

		if shouldDelete {
			// Сначала отзываем сессию
			if err := s.sessionRepo.Revoke(ctx, sess.ID); err != nil {
				s.logger.Warn("Failed to revoke expired session",
					zap.String("session_id", sess.ID.String()),
					zap.Error(err),
				)
			}
			deletedCount++
		}
	}

	s.logger.Info("Cleaned up expired sessions",
		zap.Int("deleted_count", deletedCount),
	)

	return nil
}

// GetSessionConfig возвращает текущую конфигурацию сессий
func (s *SessionService) GetSessionConfig() SessionConfig {
	return s.config
}

// UpdateSessionConfig обновляет конфигурацию сессий
func (s *SessionService) UpdateSessionConfig(config SessionConfig) error {
	if config.IdleTimeout <= 0 {
		return fmt.Errorf("idle timeout must be positive")
	}
	if config.AbsoluteTimeout <= 0 {
		return fmt.Errorf("absolute timeout must be positive")
	}
	if config.MaxConcurrentSessions <= 0 {
		return fmt.Errorf("max concurrent sessions must be positive")
	}

	s.config = config
	s.logger.Info("Session config updated",
		zap.Duration("idle_timeout", config.IdleTimeout),
		zap.Duration("absolute_timeout", config.AbsoluteTimeout),
		zap.Int("max_concurrent_sessions", config.MaxConcurrentSessions),
	)

	return nil
}
