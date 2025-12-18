package services

import (
	"context"
	"errors"
	"net"
	"strings"
	"time"

	"golang.org/x/crypto/bcrypt"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

var (
	ErrInvalidCredentials = errors.New("invalid credentials")
	ErrUnauthorized       = errors.New("unauthorized")
)

type AuthService struct {
	userRepo    repositories.UserRepository
	sessionRepo repositories.SessionRepository
	tokenSvc    *TokenService
}

type RegisterResult struct {
	User   *domain.User      `json:"user"`
	Tokens domain.TokenPair  `json:"tokens"`
}

type LoginResult struct {
	User   *domain.User     `json:"user"`
	Tokens domain.TokenPair `json:"tokens"`
	// subscription добавим позже (модуль subscriptions)
}

func NewAuthService(
	userRepo repositories.UserRepository,
	sessionRepo repositories.SessionRepository,
	tokenSvc *TokenService,
) *AuthService {
	return &AuthService{userRepo: userRepo, sessionRepo: sessionRepo, tokenSvc: tokenSvc}
}

type DeviceInfo struct {
	DeviceID   *string
	DeviceName *string
	DeviceType *string
	IPAddress  *string
	UserAgent  *string
}

func (s *AuthService) Register(ctx context.Context, input domain.UserRegistration, device DeviceInfo) (*RegisterResult, error) {
	email := strings.TrimSpace(strings.ToLower(input.Email))
	if email == "" || input.Password == "" {
		return nil, ErrInvalidCredentials
	}

	existing, err := s.userRepo.GetUserByEmail(ctx, email)
	if err != nil {
		return nil, err
	}
	if existing != nil {
		return nil, repositories.ErrEmailAlreadyExists
	}

	hash, err := bcrypt.GenerateFromPassword([]byte(input.Password), bcrypt.DefaultCost)
	if err != nil {
		return nil, err
	}

	u := &domain.User{
		Email:        email,
		PasswordHash: string(hash),
		DisplayName:  input.DisplayName,
		IsActive:     true,
		IsVerified:   false,
		Locale:       "ru",
		Timezone:     "Europe/Moscow",
	}
	if input.Locale != nil && *input.Locale != "" {
		u.Locale = *input.Locale
	}

	if err := s.userRepo.CreateUser(ctx, u); err != nil {
		return nil, err
	}

	pair, err := s.createSessionAndTokens(ctx, u.ID, device)
	if err != nil {
		return nil, err
	}

	return &RegisterResult{User: u, Tokens: pair}, nil
}

func (s *AuthService) Login(ctx context.Context, input domain.UserLogin, device DeviceInfo) (*LoginResult, error) {
	email := strings.TrimSpace(strings.ToLower(input.Email))
	if email == "" || input.Password == "" {
		return nil, ErrInvalidCredentials
	}

	u, err := s.userRepo.GetUserByEmail(ctx, email)
	if err != nil || u == nil {
		return nil, ErrInvalidCredentials
	}

	if err := bcrypt.CompareHashAndPassword([]byte(u.PasswordHash), []byte(input.Password)); err != nil {
		return nil, ErrInvalidCredentials
	}

	pair, err := s.createSessionAndTokens(ctx, u.ID, device)
	if err != nil {
		return nil, err
	}

	return &LoginResult{User: u, Tokens: pair}, nil
}

func (s *AuthService) Refresh(ctx context.Context, refreshToken string) (domain.TokenPair, error) {
	if refreshToken == "" {
		return domain.TokenPair{}, ErrUnauthorized
	}

	hash := s.tokenSvc.HashRefreshToken(refreshToken)
	sess, err := s.sessionRepo.GetByRefreshHash(ctx, hash)
	if err != nil {
		return domain.TokenPair{}, err
	}
	if sess == nil || !sess.IsActive || time.Now().After(sess.ExpiresAt) {
		return domain.TokenPair{}, ErrUnauthorized
	}

	// rotate refresh
	newRefresh, err := s.tokenSvc.GenerateRefreshToken()
	if err != nil {
		return domain.TokenPair{}, err
	}
	newHash := s.tokenSvc.HashRefreshToken(newRefresh)
	newRefreshExp := time.Now().Add(s.tokenSvc.RefreshTTL())

	if err := s.sessionRepo.RotateRefresh(ctx, sess.ID, newHash, newRefreshExp); err != nil {
		return domain.TokenPair{}, err
	}

	access, exp, err := s.tokenSvc.GenerateAccessToken(sess.UserID, sess.ID)
	if err != nil {
		return domain.TokenPair{}, err
	}

	return domain.TokenPair{
		AccessToken:  access,
		RefreshToken: newRefresh,
		ExpiresAt:    exp,
	}, nil
}

func (s *AuthService) Logout(ctx context.Context, userID, sessionID domain.ID, allDevices bool) error {
	if allDevices {
		return s.sessionRepo.RevokeAllForUser(ctx, userID)
	}
	return s.sessionRepo.Revoke(ctx, sessionID)
}

// ValidateAccessToken: JWT + проверка, что session active (logout invalidates access immediately)
func (s *AuthService) ValidateAccessToken(ctx context.Context, accessToken string) (domain.ID, domain.ID, error) {
	userID, sessionID, err := s.tokenSvc.ValidateAccessToken(accessToken)
	if err != nil {
		return domain.ID{}, domain.ID{}, ErrUnauthorized
	}

	sess, err := s.sessionRepo.GetByID(ctx, sessionID)
	if err != nil {
		return domain.ID{}, domain.ID{}, ErrUnauthorized
	}
	if sess == nil || !sess.IsActive || sess.UserID != userID {
		return domain.ID{}, domain.ID{}, ErrUnauthorized
	}

	_ = s.sessionRepo.Touch(ctx, sessionID)

	return userID, sessionID, nil
}

func (s *AuthService) createSessionAndTokens(ctx context.Context, userID domain.ID, device DeviceInfo) (domain.TokenPair, error) {
	refresh, err := s.tokenSvc.GenerateRefreshToken()
	if err != nil {
		return domain.TokenPair{}, err
	}
	hash := s.tokenSvc.HashRefreshToken(refresh)
	refreshExp := time.Now().Add(s.tokenSvc.RefreshTTL())

	sessionID, err := s.sessionRepo.Create(ctx, repositories.CreateSessionParams{
		UserID:           userID,
		RefreshTokenHash: hash,
		DeviceID:         device.DeviceID,
		DeviceName:       device.DeviceName,
		DeviceType:       device.DeviceType,
		IPAddress:        device.IPAddress,
		UserAgent:        device.UserAgent,
		ExpiresAt:        refreshExp,
	})
	if err != nil {
		return domain.TokenPair{}, err
	}

	access, accessExp, err := s.tokenSvc.GenerateAccessToken(userID, sessionID)
	if err != nil {
		return domain.TokenPair{}, err
	}

	return domain.TokenPair{
		AccessToken:  access,
		RefreshToken: refresh,
		ExpiresAt:    accessExp,
	}, nil
}

// helpers
func ExtractIP(remoteAddr string) *string {
	if remoteAddr == "" {
		return nil
	}
	host, _, err := net.SplitHostPort(remoteAddr)
	if err != nil {
		// иногда приходит просто IP без порта
		host = remoteAddr
	}
	host = strings.TrimSpace(host)
	if host == "" {
		return nil
	}
	return &host
}
