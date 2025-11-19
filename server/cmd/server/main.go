package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/gorilla/mux"
	"go.uber.org/zap"

	"outfitstyle/server/internal/config"
	"outfitstyle/server/internal/core/application/services"
	"outfitstyle/server/internal/infrastructure/external"
	"outfitstyle/server/internal/infrastructure/persistence/postgres"
	"outfitstyle/server/internal/pkg/health"
	"outfitstyle/server/internal/pkg/http"
	"outfitstyle/server/internal/pkg/http/middleware"
)

func main() {
	// Setup logger
	logger, err := setupLogger()
	if err != nil {
		log.Fatalf("Failed to initialize logger: %v", err)
	}
	defer logger.Sync()

	// Load configuration
	cfg, err := config.Load()
	if err != nil {
		logger.Fatal("Configuration loading failed", zap.Error(err))
	}

	// Validate configuration
	if err := cfg.Validate(); err != nil {
		logger.Fatal("Configuration validation failed", zap.Error(err))
	}

	// Initialize database
	db, err := postgres.NewDB(cfg.Database.DatabaseURL(), logger)
	if err != nil {
		logger.Fatal("Database connection failed", zap.Error(err))
	}
	defer db.Close()

	// Initialize external services
	weatherService := external.NewWeatherService(
		cfg.WeatherAPI.Key,
		cfg.WeatherAPI.BaseURL,
		time.Duration(cfg.WeatherAPI.Timeout)*time.Second,
		logger,
	)

	mlService := external.NewMLService(
		cfg.MLService.BaseURL,
		logger,
	)

	// Initialize repositories
	userRepo := postgres.NewUserRepository(db, logger)
	recommendationRepo := postgres.NewRecommendationRepository(db, logger)

	// Initialize email service (with fallback)
	var emailService services.EmailService
	if cfg.Email.SMTPHost != "" {
		emailService, err = services.NewEmailService(cfg.Email, logger)
		if err != nil {
			logger.Warn("Email service initialization failed, using fallback", zap.Error(err))
			emailService = services.NewNoopEmailService()
		}
	} else {
		emailService = services.NewNoopEmailService()
	}

	// Initialize token service
	tokenService := services.NewTokenService(
		cfg.Security.JWTSecret,
		time.Duration(cfg.Security.TokenExpiryHours)*time.Hour,
		time.Duration(cfg.Security.RefreshTokenExpiryDays)*24*time.Hour,
		logger,
	)

	// Initialize auth service
	authConfig := services.AuthConfig{
		TokenExpiry:            time.Duration(cfg.Security.TokenExpiryHours) * time.Hour,
		VerificationCodeExpiry: time.Duration(cfg.Security.VerificationCodeExpiry) * time.Minute,
		MaxLoginAttempts:       cfg.Security.MaxLoginAttempts,
		BlockDuration:          time.Duration(cfg.Security.BlockDuration) * time.Minute,
	}
	authService := services.NewAuthService(
		userRepo,
		emailService,
		tokenService,
		authConfig,
		logger,
	)

	// Initialize application services
	recommendationService := services.NewRecommendationService(
		recommendationRepo,
		userRepo,
		weatherService,
		mlService,
		logger,
	)

	userService := services.NewUserService(userRepo, logger)

	// Initialize handlers
	recommendationHandler := http.NewRecommendationHandler(recommendationService, logger)
	authHandler := http.NewAuthHandler(authService, logger)
	userHandler := http.NewUserHandler(userService, authHandler, logger)

	// Setup router
	router := setupRouter(cfg, recommendationHandler, authHandler, userHandler, logger)

	// Setup health checks
	health.RegisterChecks(map[string]health.Checker{
		"database": db,
		"weather":  weatherService,
		"ml":       mlService,
	})

	// Setup server
	addr := cfg.Server.Host + ":" + cfg.Server.Port
	srv := &http.Server{
		Addr:         addr,
		Handler:      router,
		ReadTimeout:  cfg.Server.ReadTimeout,
		WriteTimeout: cfg.Server.WriteTimeout,
		IdleTimeout:  120 * time.Second,
	}

	// Start server in a goroutine
	go func() {
		logger.Info("Starting server", zap.String("address", addr))
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			logger.Fatal("Server failed to start", zap.Error(err))
		}
	}()

	// Graceful shutdown
	shutdown := make(chan os.Signal, 1)
	signal.Notify(shutdown, syscall.SIGINT, syscall.SIGTERM)
	<-shutdown
	logger.Info("Shutting down server...")

	ctx, cancel := context.WithTimeout(context.Background(), cfg.Server.ShutdownTimeout)
	defer cancel()

	if err := srv.Shutdown(ctx); err != nil {
		logger.Error("Server forced to shutdown", zap.Error(err))
	}

	logger.Info("Server stopped successfully")
}

// Helper functions

func setupLogger() (*zap.Logger, error) {
	var cfg zap.Config
	if os.Getenv("ENVIRONMENT") == "production" {
		cfg = zap.NewProductionConfig()
	} else {
		cfg = zap.NewDevelopmentConfig()
	}

	logger, err := cfg.Build()
	if err != nil {
		return nil, err
	}
	return logger, nil
}

func setupRouter(
	cfg *config.AppConfig,
	recommendationHandler *http.RecommendationHandler,
	authHandler *http.AuthHandler,
	userHandler *http.UserHandler,
	logger *zap.Logger,
) *mux.Router {
	router := mux.NewRouter()

	// Middleware
	router.Use(
		middleware.CORSMiddleware(cfg.Security.GetAllowedOrigins()),
		middleware.LoggerMiddleware(logger),
		middleware.RecoveryMiddleware(logger),
		middleware.RateLimitMiddleware(cfg.Security.RateLimit, time.Minute),
	)

	// Health check endpoint
	router.HandleFunc("/health", health.Handler).Methods(http.MethodGet)

	// API routes
	api := router.PathPrefix("/api/v1").Subrouter()

	// Public routes (authentication)
	auth := api.PathPrefix("/auth").Subrouter()
	auth.HandleFunc("/register", authHandler.Register).Methods(http.MethodPost)
	auth.HandleFunc("/login", authHandler.Login).Methods(http.MethodPost)
	auth.HandleFunc("/verify", authHandler.Verify).Methods(http.MethodPost)
	auth.HandleFunc("/refresh", authHandler.Refresh).Methods(http.MethodPost)

	// Protected routes
	protected := api.PathPrefix("").Subrouter()
	protected.Use(middleware.AuthMiddleware(authHandler.AuthService))

	// Recommendations
	recommendations := protected.PathPrefix("/recommendations").Subrouter()
	recommendations.HandleFunc("", recommendationHandler.GetRecommendations).Methods(http.MethodGet)
	recommendations.HandleFunc("/{id}", recommendationHandler.GetRecommendation).Methods(http.MethodGet)

	// Users
	users := protected.PathPrefix("/users").Subrouter()
	users.HandleFunc("/me", userHandler.GetCurrentUser).Methods(http.MethodGet)
	users.HandleFunc("/me/profile", userHandler.UpdateProfile).Methods(http.MethodPut)
	users.HandleFunc("/me/preferences", userHandler.UpdatePreferences).Methods(http.MethodPut)
	users.HandleFunc("/me/wardrobe", userHandler.GetUserWardrobe).Methods(http.MethodGet)
	users.HandleFunc("/me/wardrobe", userHandler.AddWardrobeItem).Methods(http.MethodPost)
	users.HandleFunc("/me/plans", userHandler.GetUserPlans).Methods(http.MethodGet)
	users.HandleFunc("/me/plans", userHandler.CreatePlan).Methods(http.MethodPost)
	users.HandleFunc("/me/plans/{id}", userHandler.DeletePlan).Methods(http.MethodDelete)

	return router
}
