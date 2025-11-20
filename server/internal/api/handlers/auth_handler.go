package handlers

import (
	"context"
	"encoding/json"
	"errors"
	"log"
	"net/http"
	"net/mail"
	"strings"
	"time"
	"unicode"

	"github.com/gorilla/mux"

	"outfitstyle/server/internal/core/application/services"
	"outfitstyle/server/internal/core/domain"
	resp "outfitstyle/server/internal/pkg/http"
)

const accessTokenTTLSeconds = 3600

var (
	errInvalidRequestBody         = errors.New("invalid request body")
	errInvalidCredentials         = errors.New("invalid credentials")
	errCodeRequired               = errors.New("code is required")
	errInvalidOrExpiredCode       = errors.New("invalid or expired code")
	errAuthHeaderRequired         = errors.New("authorization header required")
	errInvalidAuthHeaderFormat    = errors.New("invalid authorization header format")
	errInvalidRefreshToken        = errors.New("invalid refresh token")
	errInvalidEmailFormat         = errors.New("invalid email format")
	errFailedToProcessReset       = errors.New("failed to process password reset")
	errTokenRequired              = errors.New("token is required")
	errInvalidOrExpiredResetToken = errors.New("invalid or expired reset token")
)

// AuthHandler handles authentication-related HTTP requests
type AuthHandler struct {
	authService *services.AuthService
}

// NewAuthHandler creates a new authentication handler
func NewAuthHandler(authService *services.AuthService) *AuthHandler {
	return &AuthHandler{authService: authService}
}

// DTO для запросов
type loginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type verifyCodeRequest struct {
	Code string `json:"code"`
}

type emailRequest struct {
	Email string `json:"email"`
}

type resetPasswordRequest struct {
	Token       string `json:"token"`
	NewPassword string `json:"newPassword"`
}

func decodeJSON(w http.ResponseWriter, r *http.Request, dst interface{}) bool {
	dec := json.NewDecoder(r.Body)
	dec.DisallowUnknownFields()
	if err := dec.Decode(dst); err != nil {
		log.Printf("decodeJSON error: %v", err)
		resp.Error(w, http.StatusBadRequest, errInvalidRequestBody)
		return false
	}
	return true
}

func (h *AuthHandler) Register(w http.ResponseWriter, r *http.Request) {
	var userInput domain.UserRegistration
	if !decodeJSON(w, r, &userInput) {
		return
	}

	if err := validateRegistrationInput(userInput); err != nil {
		resp.Error(w, http.StatusBadRequest, err)
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	user, err := h.authService.RegisterUser(ctx, userInput)
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to register user"))
		log.Printf("Registration error: %v", err)
		return
	}

	response := map[string]interface{}{
		"user": map[string]interface{}{
			"id":         user.ID,
			"email":      user.Email,
			"username":   user.Username,
			"isVerified": user.IsVerified,
		},
		"message": "Verification code sent to your email. Please check your inbox.",
	}
	resp.Success(w, response)
}

func (h *AuthHandler) Login(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()
	var input loginRequest
	if !decodeJSON(w, r, &input) {
		return
	}
	if err := validateLoginInput(input); err != nil {
		resp.Error(w, http.StatusBadRequest, err)
		return
	}

	ctx, cancel := context.WithTimeout(r.Context(), 10*time.Second)
	defer cancel()

	// Метод LoginUser теперь возвращает (string, error) - код подтверждения
	_, err := h.authService.LoginUser(ctx, input.Email, input.Password)
	if err != nil {
		log.Printf("Login error: %v", err)
		resp.Error(w, http.StatusUnauthorized, errInvalidCredentials)
		return
	}

	response := map[string]interface{}{
		"message": "Verification code sent to your email. Please check your inbox.",
	}
	resp.Success(w, response)
}

func (h *AuthHandler) VerifyCode(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()
	var input verifyCodeRequest
	if !decodeJSON(w, r, &input) {
		return
	}
	input.Code = strings.TrimSpace(input.Code)
	if input.Code == "" {
		resp.Error(w, http.StatusBadRequest, errCodeRequired)
		return
	}

	ctx, cancel := context.WithTimeout(r.Context(), 10*time.Second)
	defer cancel()

	user, accessToken, err := h.authService.VerifyCode(ctx, input.Code)
	if err != nil {
		log.Printf("VerifyCode error: %v", err)
		resp.Error(w, http.StatusUnauthorized, errInvalidOrExpiredCode)
		return
	}

	response := map[string]interface{}{
		"user": map[string]interface{}{
			"id":         user.ID,
			"email":      user.Email,
			"username":   user.Username,
			"isVerified": user.IsVerified,
		},
		"accessToken": accessToken,
		"expiresIn":   accessTokenTTLSeconds,
	}
	resp.Success(w, response)
}

func (h *AuthHandler) RefreshToken(w http.ResponseWriter, r *http.Request) {
	authHeader := strings.TrimSpace(r.Header.Get("Authorization"))
	if authHeader == "" {
		resp.Error(w, http.StatusUnauthorized, errAuthHeaderRequired)
		return
	}
	const prefix = "Bearer "
	if !strings.HasPrefix(authHeader, prefix) || len(authHeader) <= len(prefix) {
		resp.Error(w, http.StatusUnauthorized, errInvalidAuthHeaderFormat)
		return
	}
	refreshToken := strings.TrimSpace(authHeader[len(prefix):])

	ctx, cancel := context.WithTimeout(r.Context(), 10*time.Second)
	defer cancel()

	accessToken, err := h.authService.RefreshToken(ctx, refreshToken)
	if err != nil {
		log.Printf("RefreshToken error: %v", err)
		resp.Error(w, http.StatusUnauthorized, errInvalidRefreshToken)
		return
	}

	response := map[string]interface{}{
		"accessToken": accessToken,
		"expiresIn":   accessTokenTTLSeconds,
	}
	resp.Success(w, response)
}

func (h *AuthHandler) Logout(w http.ResponseWriter, r *http.Request) {
	authHeader := strings.TrimSpace(r.Header.Get("Authorization"))
	if authHeader == "" {
		resp.Error(w, http.StatusUnauthorized, errAuthHeaderRequired)
		return
	}
	const prefix = "Bearer "
	if !strings.HasPrefix(authHeader, prefix) || len(authHeader) <= len(prefix) {
		resp.Error(w, http.StatusUnauthorized, errInvalidAuthHeaderFormat)
		return
	}
	refreshToken := strings.TrimSpace(authHeader[len(prefix):])
	h.authService.RevokeToken(refreshToken)

	response := map[string]interface{}{
		"message": "Successfully logged out",
	}
	resp.Success(w, response)
}

func (h *AuthHandler) ForgotPassword(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()
	var input emailRequest
	if !decodeJSON(w, r, &input) {
		return
	}
	if !isValidEmail(input.Email) {
		resp.Error(w, http.StatusBadRequest, errInvalidEmailFormat)
		return
	}

	ctx, cancel := context.WithTimeout(r.Context(), 10*time.Second)
	defer cancel()

	if err := h.authService.ForgotPassword(ctx, input.Email); err != nil {
		log.Printf("Password reset request error: %v", err)
		resp.Error(w, http.StatusInternalServerError, errFailedToProcessReset)
		return
	}
	resp.Success(w, map[string]interface{}{"message": "Password reset instructions sent to your email"})
}

func (h *AuthHandler) ResetPassword(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()
	var input resetPasswordRequest
	if !decodeJSON(w, r, &input) {
		return
	}
	input.Token = strings.TrimSpace(input.Token)
	if input.Token == "" {
		resp.Error(w, http.StatusBadRequest, errTokenRequired)
		return
	}
	if err := validatePasswordStrength(input.NewPassword); err != nil {
		resp.Error(w, http.StatusBadRequest, err)
		return
	}

	ctx, cancel := context.WithTimeout(r.Context(), 10*time.Second)
	defer cancel()

	if err := h.authService.ResetPassword(ctx, input.Token, input.NewPassword); err != nil {
		log.Printf("ResetPassword error: %v", err)
		resp.Error(w, http.StatusUnauthorized, errInvalidOrExpiredResetToken)
		return
	}
	resp.Success(w, map[string]interface{}{"message": "Password successfully reset. Please login with your new password."})
}

func (h *AuthHandler) RegisterRoutes(r *mux.Router) {
	auth := r.PathPrefix("/api/auth").Subrouter()
	auth.HandleFunc("/register", h.Register).Methods(http.MethodPost)
	auth.HandleFunc("/login", h.Login).Methods(http.MethodPost)
	auth.HandleFunc("/verify", h.VerifyCode).Methods(http.MethodPost)
	auth.HandleFunc("/forgot-password", h.ForgotPassword).Methods(http.MethodPost)
	auth.HandleFunc("/reset-password", h.ResetPassword).Methods(http.MethodPost)
	auth.HandleFunc("/refresh", h.RefreshToken).Methods(http.MethodPost)
	auth.HandleFunc("/logout", h.Logout).Methods(http.MethodPost)
}

func validateRegistrationInput(input domain.UserRegistration) error {
	input.Email = strings.TrimSpace(input.Email)
	input.Username = strings.TrimSpace(input.Username)
	if input.Email == "" {
		return errors.New("email is required")
	}
	if !isValidEmail(input.Email) {
		return errors.New("invalid email format")
	}
	if input.Password == "" {
		return errors.New("password is required")
	}
	if len(input.Password) < 8 {
		return errors.New("password must be at least 8 characters")
	}
	if input.Username == "" {
		return errors.New("username is required")
	}
	return nil
}

func validateLoginInput(input loginRequest) error {
	input.Email = strings.TrimSpace(input.Email)
	if input.Email == "" {
		return errors.New("email is required")
	}
	if !isValidEmail(input.Email) {
		return errors.New("invalid email format")
	}
	if input.Password == "" {
		return errors.New("password is required")
	}
	return nil
}

func validatePasswordStrength(password string) error {
	if len(password) < 8 {
		return errors.New("password must be at least 8 characters")
	}
	var hasDigit, hasSpecial bool
	for _, r := range password {
		if unicode.IsDigit(r) {
			hasDigit = true
		}
		if unicode.IsPunct(r) || unicode.IsSymbol(r) {
			hasSpecial = true
		}
	}
	if !hasDigit {
		return errors.New("password must contain at least one number")
	}
	if !hasSpecial {
		return errors.New("password must contain at least one special character")
	}
	return nil
}

func isValidEmail(email string) bool {
	if email == "" {
		return false
	}
	_, err := mail.ParseAddress(email)
	return err == nil
}
