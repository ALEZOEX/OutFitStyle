// Package main OutfitStyle API.
//
// @title       OutfitStyle API
// @version     1.0
// @BasePath    /api/v1
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
	"github.com/prometheus/client_golang/prometheus/promhttp"
	httpSwagger "github.com/swaggo/http-swagger"
	"go.uber.org/zap"

	"outfitstyle/server/internal/api/handlers"
	"outfitstyle/server/internal/api/middleware"
	"outfitstyle/server/internal/config"
	"outfitstyle/server/internal/core/application/services"
	_ "outfitstyle/server/internal/docs"
	"outfitstyle/server/internal/infrastructure/external"
	"outfitstyle/server/internal/infrastructure/persistence/postgres"
	"outfitstyle/server/internal/pkg/health"
)

func main() {
	// ---------- Логгер ----------
	logger, err := setupLogger()
	if err != nil {
		log.Fatalf("Failed to initialize logger: %v", err)
	}
	defer logger.Sync()

	// ---------- Конфиг приложения ----------
	cfg, err := config.Load()
	if err != nil {
		logger.Fatal("Configuration loading failed", zap.Error(err))
	}

	if err := cfg.Validate(); err != nil {
		logger.Fatal("Configuration validation failed", zap.Error(err))
	}

	// ---------- БД ----------
	db, err := postgres.NewDB(cfg.Database.DatabaseURL(), logger)
	if err != nil {
		logger.Fatal("Database connection failed", zap.Error(err))
	}
	defer db.Close()

	// ---------- Внешние сервисы ----------
	weatherAPIKey := os.Getenv("WEATHER_API_KEY")
	weatherBaseURL := os.Getenv("WEATHER_API_BASE_URL")
	if weatherAPIKey == "" {
		logger.Warn("WEATHER_API_KEY is not set")
	}
	if weatherBaseURL == "" {
		weatherBaseURL = "https://api.openweathermap.org/data/2.5"
	}

	weatherService := external.NewWeatherService(
		weatherAPIKey,
		weatherBaseURL,
		10*time.Second,
		logger,
	)

	mlService := external.NewMLService(
		cfg.MLService.BaseURL,
		logger,
	)

	googleAuth, err := external.NewGoogleAuthService()
	if err != nil {
		logger.Fatal("Google auth init failed", zap.Error(err))
	}

	// ---------- Репозитории ----------
	userRepo := postgres.NewUserRepository(db, logger)
	recommendationRepo := postgres.NewRecommendationRepository(db, logger)
	clothingItemRepo := postgres.NewClothingItemRepository(db, logger)

	// ---------- EmailService через cfg.Email ----------
	var emailService services.EmailService
	if cfg.Email.SMTPHost != "" {
		from := os.Getenv("FROM_EMAIL")
		if from == "" {
			from = "noreply@outfitstyle.com"
		}

		logger.Info("SMTP email service enabled",
			zap.String("host", cfg.Email.SMTPHost),
			zap.Int("port", cfg.Email.SMTPPort),
			zap.String("from", from),
		)

		emailService = services.NewEmailService(
			cfg.Email.SMTPHost,
			cfg.Email.SMTPPort,
			cfg.Email.SMTPUsername,
			cfg.Email.SMTPPassword,
			from,
			logger,
		)
	} else {
		logger.Warn("SMTP config not set, using NoopEmailService")
		emailService = services.NewNoopEmailService()
	}

	// ---------- Services ----------
	clothingItemService := services.NewClothingItemService(clothingItemRepo)
	tokenService := services.NewTokenService(
		cfg.Security.JWTSecret,
		time.Duration(cfg.Security.TokenExpiryHours)*time.Hour,
		time.Duration(cfg.Security.RefreshTokenExpiryDays)*24*time.Hour,
	)

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

	// ---------- Доменные сервисы ----------
	recommendationService := services.NewRecommendationService(
		recommendationRepo,
		userRepo,
		clothingItemRepo,
		weatherService,
		mlService,
		logger,
	)

	userService := services.NewUserService(userRepo, logger)

	// ---------- HTTP‑обработчики ----------
	clothingItemHandler := handlers.NewClothingItemHandler(clothingItemService, logger)
	recommendationHandler := handlers.NewRecommendationHandler(recommendationService, weatherService, logger)
	authHandler := handlers.NewAuthHandler(authService, googleAuth)
	userHandler := handlers.NewUserHandler(userService, logger)

	// ---------- Роутер ----------
	router := setupRouter(cfg, clothingItemHandler, recommendationHandler, authHandler, userHandler, logger)

	// ---------- Health checks ----------
	checks := map[string]health.Checker{
		"database": db,
		"weather":  weatherService,
		"ml":       mlService,
	}
	health.RegisterChecks(checks)

	// ---------- HTTP‑сервер ----------
	addr := cfg.Server.Host + ":" + cfg.Server.Port
	srv := &stdhttp.Server{
		Addr:         addr,
		Handler:      router,
		ReadTimeout:  time.Duration(cfg.Server.ReadTimeout) * time.Second,
		WriteTimeout: time.Duration(cfg.Server.WriteTimeout) * time.Second,
		IdleTimeout:  120 * time.Second,
	}

	// Стартуем сервер
	go func() {
		logger.Info("Starting server", zap.String("address", addr))
		if err := srv.ListenAndServe(); err != nil && err != stdhttp.ErrServerClosed {
			logger.Fatal("Server failed to start", zap.Error(err))
		}
	}()

	// ---------- Graceful shutdown ----------
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
	clothingItemHandler *handlers.ClothingItemHandler,
	recommendationHandler *handlers.RecommendationHandler,
	authHandler *handlers.AuthHandler,
	userHandler *handlers.UserHandler,
	logger *zap.Logger,
) *mux.Router {
	router := mux.NewRouter()

	// Middleware
	router.Use(
		middleware.CORSMiddleware(cfg.Security.GetAllowedOrigins()),
		middleware.LoggerMiddleware(logger),
		middleware.RateLimitMiddleware(cfg.Security.RateLimit, time.Minute),
	)

	// Health
	router.HandleFunc("/health", health.Handler).Methods(stdhttp.MethodGet)

	// Swagger UI: /swagger/index.html
	router.PathPrefix("/swagger/").Handler(httpSwagger.WrapHandler)

	// API v1
	api := router.PathPrefix("/api/v1").Subrouter()

	// Auth routes: /api/v1/auth/...
	authHandler.RegisterRoutes(api)

	// Protected routes (пока без auth‑middleware)
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
	users.HandleFunc("/{id}/stats", userHandler.GetUserStats).Methods(stdhttp.MethodGet)

	// Clothing items routes
	clothingItems := protected.PathPrefix("/clothing-items").Subrouter()
	clothingItems.HandleFunc("", clothingItemHandler.GetAllClothingItems).Methods(stdhttp.MethodGet)
	clothingItems.HandleFunc("", clothingItemHandler.CreateClothingItem).Methods(stdhttp.MethodPost)
	clothingItems.HandleFunc("/{id:[0-9]+}", clothingItemHandler.GetClothingItem).Methods(stdhttp.MethodGet)
	clothingItems.HandleFunc("/{id:[0-9]+}", clothingItemHandler.UpdateClothingItem).Methods(stdhttp.MethodPut)
	clothingItems.HandleFunc("/{id:[0-9]+}", clothingItemHandler.DeleteClothingItem).Methods(stdhttp.MethodDelete)

	// Wardrobe routes
	wardrobe := protected.PathPrefix("/wardrobe").Subrouter()
	wardrobe.HandleFunc("/users/{user_id:[0-9]+}", clothingItemHandler.GetWardrobeItems).Methods(stdhttp.MethodGet)
	wardrobe.HandleFunc("/users/{user_id:[0-9]+}/items/{item_id:[0-9]+}", clothingItemHandler.AddItemToWardrobe).Methods(stdhttp.MethodPost)
	wardrobe.HandleFunc("/users/{user_id:[0-9]+}/items/{item_id:[0-9]+}", clothingItemHandler.RemoveItemFromWardrobe).Methods(stdhttp.MethodDelete)

	// Prometheus metrics
	router.Handle("/metrics", promhttp.Handler()).Methods(stdhttp.MethodGet)
	
	return router
}
