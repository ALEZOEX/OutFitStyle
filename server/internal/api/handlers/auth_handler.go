package handlers

import (
	"context"
	"encoding/json"
	"errors"
	"log"
	"net/http"
	"strings"
	"time"

	"github.com/gorilla/mux"

	"outfitstyle/server/internal/api"
	"outfitstyle/server/internal/core/application/services"
	"outfitstyle/server/internal/core/domain"
)

// AuthHandler handles authentication-related HTTP requests
type AuthHandler struct {
	authService *services.AuthService
}

// NewAuthHandler creates a new authentication handler
func NewAuthHandler(authService *services.AuthService) *AuthHandler {
	return &AuthHandler{authService: authService}
}

// Register handles user registration
func (h *AuthHandler) Register(w http.ResponseWriter, r *http.Request) {
	var userInput domain.UserRegistration
	if err := json.NewDecoder(r.Body).Decode(&userInput); err != nil {
		api.JSONError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	// Validate input
	if err := validateRegistrationInput(userInput); err != nil {
		api.JSONError(w, http.StatusBadRequest, err.Error())
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	user, err := h.authService.RegisterUser(ctx, userInput)
	if err != nil {
		// In a real implementation, you would check the specific error type
		api.JSONError(w, http.StatusInternalServerError, "Failed to register user")
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

	api.JSONResponse(w, http.StatusCreated, response)
}

// Login handles user login
func (h *AuthHandler) Login(w http.ResponseWriter, r *http.Request) {
	var loginInput struct {
		Email    string `json:"email"`
		Password string `json:"password"`
	}

	if err := json.NewDecoder(r.Body).Decode(&loginInput); err != nil {
		api.JSONError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	// Validate input
	if err := validateLoginInput(loginInput); err != nil {
		api.JSONError(w, http.StatusBadRequest, err.Error())
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	_, err := h.authService.LoginUser(ctx, loginInput.Email, loginInput.Password)
	if err != nil {
		// Don't reveal which part failed for security
		api.JSONError(w, http.StatusUnauthorized, "Invalid credentials")
		return
	}

	response := map[string]interface{}{
		"message": "Verification code sent to your email. Please check your inbox.",
	}

	api.JSONResponse(w, http.StatusOK, response)
}

// VerifyCode handles verification code submission
func (h *AuthHandler) VerifyCode(w http.ResponseWriter, r *http.Request) {
	var verifyInput struct {
		Code string `json:"code"`
	}

	if err := json.NewDecoder(r.Body).Decode(&verifyInput); err != nil {
		api.JSONError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	user, accessToken, err := h.authService.VerifyCode(ctx, verifyInput.Code)
	if err != nil {
		api.JSONError(w, http.StatusUnauthorized, "Invalid or expired code")
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
		"expiresIn":   3600, // 1 hour
	}

	api.JSONResponse(w, http.StatusOK, response)
}

// RefreshToken handles token refresh
func (h *AuthHandler) RefreshToken(w http.ResponseWriter, r *http.Request) {
	authHeader := r.Header.Get("Authorization")
	if authHeader == "" {
		api.JSONError(w, http.StatusUnauthorized, "Authorization header required")
		return
	}

	if !strings.HasPrefix(authHeader, "Bearer ") {
		api.JSONError(w, http.StatusUnauthorized, "Invalid authorization header format")
		return
	}

	refreshToken := authHeader[7:] // Remove "Bearer " prefix

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	accessToken, err := h.authService.RefreshToken(ctx, refreshToken)
	if err != nil {
		api.JSONError(w, http.StatusUnauthorized, "Invalid refresh token")
		return
	}

	response := map[string]interface{}{
		"accessToken": accessToken,
		"expiresIn":   3600, // 1 hour
	}

	api.JSONResponse(w, http.StatusOK, response)
}

// Logout handles user logout
func (h *AuthHandler) Logout(w http.ResponseWriter, r *http.Request) {
	authHeader := r.Header.Get("Authorization")
	if authHeader == "" {
		api.JSONError(w, http.StatusUnauthorized, "Authorization header required")
		return
	}

	if !strings.HasPrefix(authHeader, "Bearer ") {
		api.JSONError(w, http.StatusUnauthorized, "Invalid authorization header format")
		return
	}

	refreshToken := authHeader[7:] // Remove "Bearer " prefix

	h.authService.RevokeToken(refreshToken)

	response := map[string]interface{}{
		"message": "Successfully logged out",
	}

	api.JSONResponse(w, http.StatusOK, response)
}

// ForgotPassword handles password reset request
func (h *AuthHandler) ForgotPassword(w http.ResponseWriter, r *http.Request) {
	var emailInput struct {
		Email string `json:"email"`
	}

	if err := json.NewDecoder(r.Body).Decode(&emailInput); err != nil {
		api.JSONError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	err := h.authService.ForgotPassword(ctx, emailInput.Email)
	if err != nil {
		api.JSONError(w, http.StatusInternalServerError, "Failed to process password reset")
		log.Printf("Password reset error: %v", err)
		return
	}

	response := map[string]interface{}{
		"message": "If this email is registered, you will receive a password reset link.",
	}

	api.JSONResponse(w, http.StatusOK, response)
}

// ResetPassword handles password reset
func (h *AuthHandler) ResetPassword(w http.ResponseWriter, r *http.Request) {
	var resetInput struct {
		Token       string `json:"token"`
		NewPassword string `json:"newPassword"`
	}

	if err := json.NewDecoder(r.Body).Decode(&resetInput); err != nil {
		api.JSONError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	// Validate password strength
	if err := validatePasswordStrength(resetInput.NewPassword); err != nil {
		api.JSONError(w, http.StatusBadRequest, err.Error())
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	err := h.authService.ResetPassword(ctx, resetInput.Token, resetInput.NewPassword)
	if err != nil {
		api.JSONError(w, http.StatusUnauthorized, "Invalid or expired reset token")
		return
	}

	response := map[string]interface{}{
		"message": "Password successfully reset. Please login with your new password.",
	}

	api.JSONResponse(w, http.StatusOK, response)
}

// RegisterRoutes registers authentication routes
func (h *AuthHandler) RegisterRoutes(r *mux.Router) {
	auth := r.PathPrefix("/api/auth").Subrouter()

	// Public routes
	auth.HandleFunc("/register", h.Register).Methods("POST")
	auth.HandleFunc("/login", h.Login).Methods("POST")
	auth.HandleFunc("/verify", h.VerifyCode).Methods("POST")
	auth.HandleFunc("/forgot-password", h.ForgotPassword).Methods("POST")
	auth.HandleFunc("/reset-password", h.ResetPassword).Methods("POST")

	// Protected routes
	auth.HandleFunc("/refresh", h.RefreshToken).Methods("POST")
	auth.HandleFunc("/logout", h.Logout).Methods("POST")
}

// validateRegistrationInput validates registration input
func validateRegistrationInput(input domain.UserRegistration) error {
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

// validateLoginInput validates login input
func validateLoginInput(input struct {
	Email    string
	Password string
}) error {
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

// validatePasswordStrength checks password strength
func validatePasswordStrength(password string) error {
	if len(password) < 8 {
		return errors.New("password must be at least 8 characters")
	}
	if !containsDigit(password) {
		return errors.New("password must contain at least one number")
	}
	if !containsSpecialChar(password) {
		return errors.New("password must contain at least one special character")
	}
	return nil
}

// isValidEmail validates email format
func isValidEmail(email string) bool {
	// Simple email validation - in a real application, use a proper email validation library
	return strings.Contains(email, "@") && strings.Contains(email, ".")
}

// containsDigit checks if string contains a digit
func containsDigit(s string) bool {
	for _, c := range s {
		if c >= '0' && c <= '9' {
			return true
		}
	}
	return false
}

// containsSpecialChar checks if string contains special character
func containsSpecialChar(s string) bool {
	specialChars := "!@#$%^&*()_+-=[]{}|;:,.<>?/`~"
	for _, c := range s {
		if strings.ContainsRune(specialChars, c) {
			return true
		}
	}
	return false
}
