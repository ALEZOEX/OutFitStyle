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
	"strings"
	"syscall"
	"time"

	"github.com/gorilla/mux"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	httpSwagger "github.com/swaggo/http-swagger"
	"go.uber.org/zap"

	"outfitstyle/server/internal/api/handlers"
	"outfitstyle/server/internal/api/middleware"
	"outfitstyle/server/internal/config"
	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/application/services"
	"outfitstyle/server/internal/core/domain"
	_ "outfitstyle/server/internal/docs"
	"outfitstyle/server/internal/infrastructure/cache"
	ext "outfitstyle/server/internal/infrastructure/external"
	"outfitstyle/server/internal/infrastructure/observability"
	dbpg "outfitstyle/server/internal/infrastructure/persistence/postgres"
	pg "outfitstyle/server/internal/infrastructure/persistence/postgres/pg"
	"outfitstyle/server/internal/infrastructure/queue"
	"outfitstyle/server/internal/pkg/health"

	"github.com/redis/go-redis/v9"
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

	_ = observability.InitSentry(observability.SentryConfig{
		DSN:         cfg.Sentry.DSN,
		Environment: cfg.Server.Environment,
		Release:     "outfitstyle-api@dev",
	})
	defer observability.Flush(2 * time.Second)

	// ---------- БД ----------
	db, err := dbpg.NewDB(cfg.Database.DatabaseURL(), logger)
	if err != nil {
		logger.Fatal("Database connection failed", zap.Error(err))
	}
	defer db.Close()

	// ---------- Redis клиент для кэширования ----------
	var redisClient *redis.Client
	redisClient, err = cache.NewRedisClient(cfg.Redis.URL, cfg.Redis.Password)
	if err != nil {
		logger.Warn("Redis unavailable, caching/rate-limit degrade", zap.Error(err))
		redisClient = nil
	} else {
		defer redisClient.Close()
	}

	// ---------- Погодный сервис с выбором провайдера ----------
	var provider ext.WeatherProvider

	switch strings.ToLower(cfg.WeatherProvider.Provider) {
	case "openmeteo":
		provider = ext.NewOpenMeteoProvider(cfg.WeatherProvider.OpenMeteoBaseURL, 10*time.Second)
		logger.Info("Weather provider: open-meteo")
	default:
		owClient := ext.NewOpenWeatherClient(cfg.OpenWeather.APIKey, cfg.OpenWeather.BaseURL, 10*time.Second)
		provider = ext.NewOpenWeatherProvider(owClient)
		logger.Info("Weather provider: openweather")
	}

	weatherService := ext.NewWeatherService(provider, redisClient, cfg.OpenWeather.CacheTTL, cfg.WeatherProvider.Provider)

	// ---------- Обновленный ML-сервис с новым контрактом ----------
	mlClient := ext.NewMLClient(cfg.MLService.BaseURL, cfg.MLService.Timeout)

	// ---------- Репозитории ----------
	userRepo := pg.NewUserRepository(db, logger)
	sessionRepo := pg.NewSessionRepository(db, logger)
	recommendationRepo := pg.NewRecommendationRepository(db, logger)
	clothingRepo := pg.NewClothingRepository(db, logger)
	wardrobeRepo := pg.NewWardrobeRepository(db)
	// specRepo := pg.NewSubcategorySpecRepository(db, logger)
	subRepo := pg.NewSubscriptionRepository(db, logger)
	notifRepo := pg.NewNotificationRepository(db)
	pushTokenRepo := pg.NewPushTokenRepository(db)
	tripRepo := pg.NewTripRepository(db)
	savedOutfitRepo := pg.NewSavedOutfitRepository(db)
	catalogRepo := pg.NewCatalogRepository(db)
	achievementRepo := pg.NewAchievementRepository(db, logger)
	achEngineRepo := pg.NewAchievementEngineRepository(db)
	// auditRepo := pg.NewAuditRepository(db) // объявлен позже, когда используется

	// ---------- Services ----------
	// Пока не создаем ML клиент, передаем nil для него
	// var clothingItemService *services.ClothingItemService
	// clothingItemService = nil
	tokenSvc := services.NewTokenService(cfg.Security.JWTSecret, cfg.Security.AccessTokenTTL, cfg.Security.RefreshTokenTTL)
	googleClient := ext.NewGoogleAuthClient(cfg.Security.GoogleClientID)
	authService := services.NewAuthService(userRepo, sessionRepo, tokenSvc, googleClient)

	// ---------- Rate limit violation repository ----------
	rateLimitRepo := pg.NewRateLimitViolationRepository(db)

	// ---------- Rate limiter ----------
	limiter := middleware.NewRedisRateLimiter(redisClient, rateLimitRepo)

	// ---------- Queue client ----------
	var qClient *queue.Client
	redisOpt, err := queue.ParseRedisURLToAsynqOpt(cfg.Queue.RedisURL)
	if err != nil {
		logger.Warn("queue disabled: bad redis url", zap.Error(err))
	} else {
		qClient = queue.NewClient(redisOpt)
		defer qClient.Close()
	}

	// ---------- Geo клиент (Nominatim) с кэшированием ----------
	geo := ext.NewNominatimClient(
		"https://nominatim.openstreetmap.org",
		5*time.Second,
		"OutfitStyle/1.0 (contact: dev @outfitstyle.app)",
		redisClient,
		7*24*time.Hour,
	)
	geoHandler := handlers.NewGeoHandler(geo, logger)

	// ---------- Notification services ----------
	notifService := services.NewNotificationService(notifRepo, pushTokenRepo, qClient)

	// ---------- Personalization repository ----------
	personalizationRepo := pg.NewPersonalizationRepository(db)

	// ---------- Доменные сервисы ----------
	recommendationService := services.NewRecommendationService(
		recommendationRepo,
		clothingRepo,
		userRepo,
		weatherService,
		mlClient,
		personalizationRepo,
		logger,
	)

	achEngine := services.NewAchievementEngine(achEngineRepo, userRepo, notifService) // notifService может быть nil, если не включен

	userService := services.NewUserService(userRepo, logger)

	subService := services.NewSubscriptionService(subRepo)

	// ---------- Payment gateways ----------
	gateways := map[string]domain.PaymentGateway{
		"dummy":    ext.NewDummyGateway(),
		"stripe":   ext.NewStripeGateway(cfg.Payments.StripeWebhookSecret),
		"yookassa": ext.NewYooKassaGateway(cfg.Payments.YooKassaSecretKey),
	}

	// ---------- Billing service (updated to support multiple gateways) ----------
	billingRepo := pg.NewBillingRepository(db, logger)
	promoRepo := pg.NewPromoRepository(db)
	billingService := services.NewBillingService(subRepo, billingRepo, promoRepo, gateways)

	// ---------- S3 storage ----------
	var s3 *ext.S3Storage
	if cfg.Storage.S3Endpoint != "" && cfg.Storage.S3Bucket != "" {
		st, err := ext.NewS3Storage(ext.S3Config{
			Endpoint:      cfg.Storage.S3Endpoint,
			Bucket:        cfg.Storage.S3Bucket,
			AccessKey:     cfg.Storage.S3AccessKey,
			SecretKey:     cfg.Storage.S3SecretKey,
			Region:        cfg.Storage.S3Region,
			PublicBaseURL: cfg.Storage.PublicBaseURL,
			PresignTTL:    cfg.Storage.PresignTTL,
		})
		if err != nil {
			logger.Warn("S3 disabled", zap.Error(err))
		} else {
			s3 = st
			logger.Info("S3 enabled", zap.String("bucket", cfg.Storage.S3Bucket))
		}
	}

	// ---------- Новые сервисы для модуля 4 ----------
	wardrobeService := services.NewWardrobeService(wardrobeRepo, clothingRepo)

	// ---------- Модуль 11: Trips, Saved Outfits, Catalog services ----------
	tripService := services.NewTripService(tripRepo)
	savedOutfitService := services.NewSavedOutfitService(savedOutfitRepo)
	catalogService := services.NewCatalogService(catalogRepo, redisClient)

	// ---------- Repositories for module 12 ----------
	uploadedRepo := pg.NewUploadedFilesRepository(db)
	exportRepo := pg.NewExportRepository(db)

	// ---------- Services for module 12 ----------
	fileService := services.NewFileService(s3, uploadedRepo, userRepo)
	exportService := services.NewExportService(exportRepo, uploadedRepo, s3)
	accountService := services.NewAccountService(userRepo, sessionRepo)

	// ---------- HTTP‑обработчики ----------
	recommendationHandler := handlers.NewRecommendationHandler(recommendationService, achEngine, logger)
	authHandler := handlers.NewAuthHandler(authService)
	userHandler := handlers.NewUserHandler(userService, fileService, exportService, accountService, sessionRepo, logger)
	weatherHandler := handlers.NewWeatherHandler(weatherService, userRepo, logger)
	subHandler := handlers.NewSubscriptionHandler(subService, logger)
	billingHandler := handlers.NewBillingHandler(billingService, logger)
	subLimiter := middleware.NewSubscriptionLimiter(subService)
	notifHandler := handlers.NewNotificationHandler(notifService, logger)

	// ---------- Новые обработчики для модуля 4 ----------
	wardrobeHandler := handlers.NewWardrobeHandler(wardrobeService, logger)

	// ---------- Модуль 11: Handlers ----------
	tripHandler := handlers.NewTripHandler(tripService, logger)
	savedOutfitHandler := handlers.NewSavedOutfitHandler(savedOutfitService)
	catalogHandler := handlers.NewCatalogHandler(catalogService)

	// ---------- Achievement handler ----------
	achievementService := services.NewAchievementsService(achievementRepo)
	achievementHandler := handlers.NewAchievementHandler(achievementService, logger)

	// ---------- Repositories for audit (module 13) ----------
	auditRepo := pg.NewAuditRepository(db)

	// ---------- Модуль 10: Share, Support, Feedback, Admin ----------
	shareRepo := pg.NewShareRepository(db)
	supportRepo := pg.NewSupportRepository(db)
	feedbackRepo := pg.NewFeedbackRepository(db)
	adminRepo := pg.NewAdminRepository(db)

	shareService := services.NewShareService(shareRepo)
	supportService := services.NewSupportService(supportRepo, feedbackRepo)
	adminService := services.NewAdminService(adminRepo)

	shareHandler := handlers.NewShareHandler(shareService, logger)
	supportHandler := handlers.NewSupportHandler(supportService)
	feedbackHandler := handlers.NewFeedbackHandler(supportService)
	adminHandler := handlers.NewAdminHandler(adminService, logger)

	// ---------- Модуль 13: API Keys, Feature Flags, Experiments ----------

	apiKeyRepo := pg.NewAPIKeyRepository(db)
	apiKeyService := services.NewAPIKeyService(apiKeyRepo, cfg.APIKeys.Pepper)
	apiKeyHandler := handlers.NewAPIKeyHandler(apiKeyService)

	ffRepo := pg.NewFeatureFlagRepository(db)
	ffService := services.NewFeatureFlagService(ffRepo)
	adminFFHandler := handlers.NewAdminFeatureFlagsHandler(ffService)

	expRepo := pg.NewExperimentRepository(db)
	expService := services.NewExperimentService(expRepo)

	// ---------- Роутер ----------
	router := setupRouter(cfg, authHandler, userHandler, weatherHandler, limiter, logger, authService, subHandler, billingHandler, subLimiter, notifHandler, wardrobeHandler, recommendationHandler, achievementHandler, tripHandler, savedOutfitHandler, catalogHandler, shareHandler, supportHandler, feedbackHandler, adminHandler, apiKeyHandler, adminFFHandler, expService, apiKeyService, geoHandler, auditRepo)

	// ---------- Health checks ----------
	checks := map[string]health.Checker{
		"database": db,
	}
	health.RegisterChecks(checks)

	// ---------- HTTP‑сервер ----------
	addr := cfg.Server.Host + ":" + cfg.Server.Port
	srv := &stdhttp.Server{
		Addr:         addr,
		Handler:      router,
		ReadTimeout:  cfg.Server.ReadTimeout,
		WriteTimeout: cfg.Server.WriteTimeout,
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

	ctx, cancel := context.WithTimeout(context.Background(), cfg.Server.ShutdownTimeout)
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
	authHandler *handlers.AuthHandler,
	userHandler *handlers.UserHandler,
	weatherHandler *handlers.WeatherHandler,
	limiter *middleware.RateLimiter,
	logger *zap.Logger,
	authService *services.AuthService,
	subHandler *handlers.SubscriptionHandler,
	billingHandler *handlers.BillingHandler,
	subLimiter *middleware.SubscriptionLimiter,
	notifHandler *handlers.NotificationHandler,
	wardrobeHandler *handlers.WardrobeHandler,
	recommendationHandler *handlers.RecommendationHandler,
	achievementHandler *handlers.AchievementHandler,
	tripHandler *handlers.TripHandler,
	savedOutfitHandler *handlers.SavedOutfitHandler,
	catalogHandler *handlers.CatalogHandler,
	shareHandler *handlers.ShareHandler,
	supportHandler *handlers.SupportHandler,
	feedbackHandler *handlers.FeedbackHandler,
	adminHandler *handlers.AdminHandler,
	apiKeyHandler *handlers.APIKeyHandler,
	adminFFHandler *handlers.AdminFeatureFlagsHandler,
	expService *services.ExperimentService,
	apiKeyService *services.APIKeyService,
	geoHandler *handlers.GeoHandler,
	auditRepo repositories.AuditRepository,
) *mux.Router {
	router := mux.NewRouter()

	router.Use(
		middleware.RecoveryMiddleware(logger),
		middleware.SecurityHeadersMiddleware(),
		middleware.CORSMiddleware(cfg.Security.CORSAllowedOrigins),
		middleware.LoggerMiddleware(logger),
		middleware.RateLimitMiddleware(limiter, cfg.Security.RateLimitPerMinute, time.Minute),
		middleware.MetricsMiddleware(),
	)

	router.HandleFunc("/health", health.Handler).Methods(stdhttp.MethodGet)
	router.PathPrefix("/swagger/").Handler(httpSwagger.WrapHandler)
	router.Handle("/metrics", promhttp.Handler()).Methods(stdhttp.MethodGet)

	api := router.PathPrefix("/api/v1").Subrouter()

	// /api/v1/subscription/plans (public)
	subscriptionPublic := api.PathPrefix("/subscription").Subrouter()
	subHandler.RegisterPublic(subscriptionPublic)
	billingHandler.RegisterWebhook(subscriptionPublic) // webhook/{provider}

	// /api/v1/auth/*
	auth := api.PathPrefix("/auth").Subrouter()
	authHandler.RegisterRoutes(auth)

	// protected
	protected := api.NewRoute().Subrouter()
	protected.Use(middleware.AuthMiddleware(authService, apiKeyService))

	// Business API-key policies
	protected.Use(middleware.APIKeyPolicyMiddleware())
	protected.Use(middleware.APIKeyRateLimitMiddleware(limiter))

	// AB testing
	protected.Use(middleware.ABTestingMiddleware(expService, "recommendation_ranking", cfg.Features.ABTesting))

	// Subscription limits (если включали ранее)
	protected.Use(subLimiter.EnforceRecommendationsLimit())
	protected.Use(subLimiter.EnforceWardrobeLimit())

	// Audit (best-effort)
	protected.Use(middleware.AuditMiddleware(auditRepo, logger))

	// /api/v1/subscription/current (protected)
	subscriptionProtected := protected.PathPrefix("/subscription").Subrouter()
	subHandler.RegisterProtected(subscriptionProtected)
	billingHandler.RegisterProtected(subscriptionProtected) // subscribe/cancel/reactivate/promo/payments

	// /api/v1/auth/logout должен быть protected
	authProtected := protected.PathPrefix("/auth").Subrouter()
	authProtected.HandleFunc("/logout", authHandler.Logout).Methods(stdhttp.MethodPost)

	// /api/v1/user/*
	user := protected.PathPrefix("/user").Subrouter()
	userHandler.RegisterRoutes(user)

	// /api/v1/notifications/*
	notifs := protected.PathPrefix("/notifications").Subrouter()
	notifHandler.RegisterRoutes(notifs)

	// /api/v1/wardrobe/*
	wardrobe := protected.PathPrefix("/wardrobe").Subrouter()
	wardrobeHandler.RegisterRoutes(wardrobe)

	// /api/v1/recommendations/*
	recommendations := protected.PathPrefix("/recommendations").Subrouter()
	recommendationHandler.RegisterRoutes(recommendations)

	// /api/v1/achievements/*
	ach := protected.PathPrefix("/achievements").Subrouter()
	achievementHandler.RegisterRoutes(ach)

	// /api/v1/trips/*
	trips := protected.PathPrefix("/trips").Subrouter()
	tripHandler.RegisterRoutes(trips)

	// /api/v1/outfits/*
	outfits := protected.PathPrefix("/outfits").Subrouter()
	savedOutfitHandler.RegisterRoutes(outfits)

	// /api/v1/catalog/*
	// catalog может быть public
	catalog := api.PathPrefix("/catalog").Subrouter()
	catalogHandler.RegisterRoutes(catalog)

	// public weather (можно на onboarding)
	weather := api.PathPrefix("/weather").Subrouter()
	weatherHandler.RegisterRoutes(weather)

	// public geo (автокомплит городов)
	geoR := api.PathPrefix("/geo").Subrouter()
	geoHandler.RegisterRoutes(geoR)

	// Public sharing
	sharePublic := api.PathPrefix("/share").Subrouter()
	shareHandler.RegisterPublic(sharePublic)

	// Protected sharing + support + feedback
	shareProtected := protected.PathPrefix("/share").Subrouter()
	shareHandler.RegisterProtected(shareProtected)

	support := protected.PathPrefix("/support").Subrouter()
	supportHandler.RegisterRoutes(support)

	protected.HandleFunc("/feedback", feedbackHandler.Create).Methods(stdhttp.MethodPost)

	// API keys
	apiKeys := protected.PathPrefix("/user/api-keys").Subrouter()
	apiKeyHandler.RegisterRoutes(apiKeys)

	// Admin (за X-Admin-Key middleware)
	admin := protected.PathPrefix("/admin").Subrouter()
	admin.Use(middleware.AdminMiddleware(cfg))

	admin.HandleFunc("/stats", adminHandler.Stats).Methods(stdhttp.MethodGet)
	admin.HandleFunc("/users", adminHandler.Users).Methods(stdhttp.MethodGet)
	admin.HandleFunc("/audit", adminHandler.Audit).Methods(stdhttp.MethodGet)
	admin.HandleFunc("/promo", adminHandler.CreatePromo).Methods(stdhttp.MethodPost)

	// Admin feature flags
	admin.HandleFunc("/feature-flags", adminFFHandler.List).Methods(stdhttp.MethodGet)
	admin.HandleFunc("/feature-flags", adminFFHandler.SetEnabled).Methods(stdhttp.MethodPut)

	return router
}
