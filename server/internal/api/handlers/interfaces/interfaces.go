// Пакет interfaces содержит интерфейсы для тестирования HTTP-обработчиков
package interfaces

import (
	"context"
	"time"

	"outfitstyle/server/internal/core/application/services"
	"outfitstyle/server/internal/core/domain"
)

// AuthServiceInterface интерфейс сервиса аутентификации для тестирования
type AuthServiceInterface interface {
	Register(ctx context.Context, input domain.UserRegistration, device services.DeviceInfo) (*services.RegisterResult, error)
	Login(ctx context.Context, input domain.UserLogin, device services.DeviceInfo) (*services.LoginResult, error)
	Refresh(ctx context.Context, refreshToken string) (domain.TokenPair, error)
	Logout(ctx context.Context, userID, sessionID domain.ID, allDevices bool) error
	GoogleSignIn(ctx context.Context, idToken string, device services.DeviceInfo) (*services.LoginResult, error)
	ValidateAccessToken(ctx context.Context, accessToken string) (domain.ID, domain.ID, error)
	ValidateTokenForSilentLogin(ctx context.Context, accessToken string) (*domain.User, error)
	SilentLogin(ctx context.Context, accessToken string, device services.DeviceInfo) (*services.LoginResult, error)
}

// AccountLockoutInterface интерфейс защиты от brute-force для тестирования
type AccountLockoutInterface interface {
	CheckLoginAttempt(ctx context.Context, email string) (allowed bool, remaining int, lockedUntil *time.Time, err error)
	RecordFailedAttempt(ctx context.Context, email string) error
	Reset(ctx context.Context, email string) error
}

// WardrobeServiceInterface интерфейс сервиса гардероба для тестирования
type WardrobeServiceInterface interface {
	List(ctx context.Context, userID domain.ID, q domain.WardrobeListQuery) ([]domain.WardrobeItem, int, error)
	Get(ctx context.Context, userID, wardrobeID domain.ID) (*domain.WardrobeItem, error)
	Create(ctx context.Context, userID domain.ID, req domain.WardrobeCreateRequest) (*domain.WardrobeItem, error)
	Update(ctx context.Context, userID, wardrobeID domain.ID, req domain.WardrobeUpdateRequest) (*domain.WardrobeItem, error)
	Delete(ctx context.Context, userID, wardrobeID domain.ID) error
	SetFavorite(ctx context.Context, userID, wardrobeID domain.ID, isFavorite bool) error
	SetArchived(ctx context.Context, userID, wardrobeID domain.ID, isArchived bool) error
	MarkWorn(ctx context.Context, userID, wardrobeID domain.ID) (*domain.WardrobeItem, error)
}
