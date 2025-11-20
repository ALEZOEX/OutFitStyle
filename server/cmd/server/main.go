package main

import (
	"context"
	"log"
	stdhttp "net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/gorilla/mux"
	"go.uber.org/zap"

	"outfitstyle/server/internal/api/handlers"
	"outfitstyle/server/internal/api/middleware"
	"outfitstyle/server/internal/config"
	"outfitstyle/server/internal/core/application/services"
	"outfitstyle/server/internal/infrastructure/external"
	"outfitstyle/server/internal/infrastructure/persistence/postgres"
	"outfitstyle/server/internal/pkg/health"
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
		logger.Fatal("Databaseconnection failed", zap.Error(err))
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

	// Initialize email service
	var emailService services.EmailService
	if cfg.Email.SMTPHost != "" {
		emailSvc := services.NewEmailService(
			cfg.Email.SMTPHost,
			cfg.Email.SMTPPort,
			cfg.Email.SMTPUsername,
			cfg.Email.SMTPPassword,
			"noreply@outfitstyle.com",
			logger,
		)
		emailService = emailSvc
	} else {
		emailService = services.NewNoopEmailService()
	}

	// Initialize token service
	tokenService := services.NewTokenService(
		cfg.Security.JWTSecret,
		time.Duration(cfg.Security.TokenExpiryHours)*time.Hour,
		time.Duration(cfg.Security.RefreshTokenExpiryDays)*24*time.Hour,
	)

	// Initialize auth service
	authConfig := services.AuthConfig{
		TokenExpiryHours:       cfg.Security.TokenExpiryHours,
		VerificationCodeExpiry: time.Duration(cfg.Security.VerificationCodeExpiry) * time.Minute,
		MaxLoginAttempts:       cfg.Security.MaxLoginAttempts,
		BlockDuration:          time.Duration(cfg.Security.BlockDuration) * time.Minute,
	}
	authService := services.NewAuthService(
		userRepo,
		emailService,
		tokenService,
		authConfig,
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
	recommendationHandler := handlers.NewRecommendationHandler(recommendationService, weatherService, logger)
	authHandler := handlers.NewAuthHandler(authService)
	userHandler := handlers.NewUserHandler(userService, logger)

	// Setup router
	router := setupRouter(cfg, recommendationHandler, authHandler, userHandler, logger)

	// Setup health checks
	checks := map[string]health.Checker{
		"database": db,
		"weather":  weatherService,
		"ml":       mlService,
	}
	health.RegisterChecks(checks)

	// Setup server
	addr := cfg.Server.Host + ":" + cfg.Server.Port
	srv := &stdhttp.Server{
		Addr:         addr,
		Handler:      router,
		ReadTimeout:  time.Duration(cfg.Server.ReadTimeout) * time.Second,
		WriteTimeout: time.Duration(cfg.Server.WriteTimeout) * time.Second,
		IdleTimeout:  120 * time.Second,
	}

	// Start server in a goroutine
	go func() {
		logger.Info("Starting server", zap.String("address", addr))
		if err := srv.ListenAndServe(); err != nil && err != stdhttp.ErrServerClosed {
			logger.Fatal("Server failed to start", zap.Error(err))
		}
	}()

	// Graceful shutdown
	shutdown := make(chan os.Signal, 1)
	signal.Notify(shutdown, syscall.SIGINT, syscall.SIGTERM)
	<-shutdown
	logger.Info("Shutting down server...")

	ctx, cancel := context.WithTimeout(context.Background(), time.Duration(cfg.Server.ShutdownTimeout)*time.Second)
	defer cancel()

	if err := srv.Shutdown(ctx); err != nil {
		logger.Error("Server forced to shutdown", zap.Error(err))
	}

	logger.Info("Server stopped successfully")
}

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
	recommendationHandler *handlers.RecommendationHandler,
	authHandler *handlers.AuthHandler,
	userHandler *handlers.UserHandler,
	logger *zap.Logger,
) *mux.Router {
	router := mux.NewRouter()

	// Enablemiddleware
	router.Use(
		middleware.CORSMiddleware(cfg.Security.GetAllowedOrigins()),
		middleware.LoggerMiddleware(logger),
		middleware.RateLimitMiddleware(cfg.Security.RateLimit, time.Minute),
	)

	// Health check endpoint
	router.HandleFunc("/health", health.Handler).Methods(stdhttp.MethodGet)

	// API routes
	api := router.PathPrefix("/api/v1").Subrouter()

	// Public routes (authentication)
	auth := api.PathPrefix("/auth").Subrouter()
	auth.HandleFunc("/register", authHandler.Register).Methods(stdhttp.MethodPost)
	auth.HandleFunc("/login", authHandler.Login).Methods(stdhttp.MethodPost)
	auth.HandleFunc("/verify", authHandler.VerifyCode).Methods(stdhttp.MethodPost)
	auth.HandleFunc("/refresh", authHandler.RefreshToken).Methods(stdhttp.MethodPost)

	// Protected routes
	protected := api.PathPrefix("").Subrouter()

	recommendations := protected.PathPrefix("/recommendations").Subrouter()
	recommendations.HandleFunc("", recommendationHandler.GetRecommendations).Methods(stdhttp.MethodGet)
	recommendations.HandleFunc("/{id}", recommendationHandler.GetRecommendationByID).Methods(stdhttp.MethodGet)

	users := protected.PathPrefix("/users").Subrouter()
	users.HandleFunc("/{id}/profile", userHandler.GetUserProfile).Methods(stdhttp.MethodGet)
	users.HandleFunc("/{id}/profile", userHandler.UpdateUserProfile).Methods(stdhttp.MethodPut)
	users.HandleFunc("/{id}/outfit-plans", userHandler.GetUserOutfitPlans).Methods(stdhttp.MethodGet)
	users.HandleFunc("/{id}/outfit-plans", userHandler.CreateOutfitPlan).Methods(stdhttp.MethodPost)
	users.HandleFunc("/{id}/outfit-plans/{plan_id}", userHandler.DeleteOutfitPlan).Methods(stdhttp.MethodDelete)

	return router
}
