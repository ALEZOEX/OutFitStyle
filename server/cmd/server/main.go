// Package main OutfitStyle API.
//
// @title           OutfitStyle API
// @version         2.0
// @description     Платформа умных рекомендаций одежды с учётом погоды, предпочтений пользователя и контекста
// @description
// @description     ## Основные возможности:
// @description     - **Аутентификация**: Регистрация, вход, Google OAuth, восстановление пароля
// @description     - **Рекомендации**: Персонализированные рекомендации одежды на основе погоды и ML
// @description     - **Гардероб**: Управление личными вещами пользователя
// @description     - **Каталог**: Просмотр доступных предметов одежды
// @description     - **Оценки**: Оценка рекомендаций для улучшения ML модели
// @description     - **Уведомления**: Push и email уведомления
// @description     - **Подписки**: Управление платными подписками
// @description     - **Администрирование**: Статистика, управление пользователями, feature flags
// @description
// @description     ## Аутентификация
// @description     Большинство endpoints требуют JWT токен в заголовке `Authorization: Bearer <token>`
// @description     Также поддерживается аутентификация через API ключ: `X-API-Key: <key>`
// @description
// @description     ## Координаты
// @description     Для получения рекомендаций необходимы координаты местоположения (широта/долгота)
// @description     Координаты можно установить в профиле пользователя или передавать в запросе
// @description
// @BasePath        /api/v1
// @schemes         http https
//
// @contact.name   OutfitStyle Support
// @contact.email  support@outfitstyle.app
//
// @license.name   MIT
// @license.url    https://opensource.org/licenses/MIT
//
// @securityDefinitions.apikey ApiKeyAuth
// @in header
// @name Authorization
// @description JWT Bearer token или API Key
//
// @securityDefinitions.apikey XApiKey
// @in header
// @name X-API-Key
// @description Business API key для партнёров
package main

import (
	"context"
	"crypto/tls"
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

	_ "outfitstyle/server/docs"
	"outfitstyle/server/internal/api/handlers"
	"outfitstyle/server/internal/api/middleware"
	"outfitstyle/server/internal/config"
	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/application/services"
	"outfitstyle/server/internal/core/domain"
	"outfitstyle/server/internal/core/use_cases"
	"outfitstyle/server/internal/infrastructure/adapters"
	"outfitstyle/server/internal/infrastructure/cache"
	"outfitstyle/server/internal/infrastructure/email"
	"outfitstyle/server/internal/infrastructure/eventing"
	ext "outfitstyle/server/internal/infrastructure/external"
	"outfitstyle/server/internal/infrastructure/observability"
	dbpg "outfitstyle/server/internal/infrastructure/persistence/postgres"
	pg "outfitstyle/server/internal/infrastructure/persistence/postgres/pg"
	redisrepo "outfitstyle/server/internal/infrastructure/persistence/redis"
	"outfitstyle/server/internal/infrastructure/push"
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
	defer func() {
		_ = logger.Sync()
	}()

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

	// ---------- ML Service Adapter ----------
	mlService := adapters.NewMLServiceAdapterFromExternal(mlClient)

	// ---------- Репозитории ----------
	userRepo := pg.NewUserRepository(db.Pool(), logger)
	sessionRepo := pg.NewSessionRepository(db.Pool(), logger)
	recommendationRepo := pg.NewRecommendationRepository(db.Pool(), redisClient, logger)
	clothingRepo := pg.NewClothingRepository(db.Pool(), redisClient, logger)
	wardrobeRepo := pg.NewWardrobeRepository(db.Pool())
	// specRepo := pg.NewSubcategorySpecRepository(db.Pool(), logger)

	// Rating repository (нужен до recommendationService)
	ratingRepo := pg.NewOutfitRatingRepository(db.Pool(), logger)

	// Subscription repositories
	subPlanRepo := pg.NewSubscriptionPlanRepository(db.Pool())
	userSubRepo := pg.NewUserSubscriptionRepository(db.Pool())
	usageRepo := pg.NewSubscriptionUsageRepository(db.Pool())
	txRepo := pg.NewSubscriptionTransactionRepository(db.Pool())
	promoRepo := pg.NewPromoRepository(db.Pool())
	redemptionRepo := pg.NewPromoRedemptionRepository(db.Pool())
	familyRepo := pg.NewFamilyMemberRepository(db.Pool())

	notifRepo := pg.NewNotificationRepository(db.Pool())
	pushTokenRepo := pg.NewPushTokenRepository(db.Pool())
	savedOutfitRepo := pg.NewSavedOutfitRepository(db.Pool())
	catalogRepo := pg.NewCatalogRepository(db.Pool())
	achievementRepo := pg.NewAchievementRepository(db.Pool(), logger)
	achEngineRepo := pg.NewAchievementEngineRepository(db.Pool())
	auditRepo := pg.NewAuditRepository(db.Pool())

	// ---------- Services ----------
	// Пока не создаем ML клиент, передаем nil для него
	// var clothingItemService *services.ClothingItemService
	// clothingItemService = nil

	// ---------- Token Service с поддержкой RS256 ----------
	tokenConfig := services.TokenServiceConfig{
		JWTSecret:      cfg.Security.JWTSecret,
		PrivateKeyPath: cfg.Security.JWTPrivateKeyPath,
		PublicKeyPath:  cfg.Security.JWTPublicKeyPath,
		UseRS256:       cfg.Security.UseRS256,
		AccessTTL:      cfg.Security.AccessTokenTTL,
		RefreshTTL:     cfg.Security.RefreshTokenTTL,
	}
	tokenSvc, err := services.NewTokenService(tokenConfig)
	if err != nil {
		logger.Fatal("Failed to initialize token service", zap.Error(err))
	}

	if cfg.Security.UseRS256 {
		logger.Info("✅ JWT RS256 signing enabled")
	} else {
		logger.Info("ℹ️  JWT HS256 signing enabled (legacy)")
	}

	googleClient := ext.NewGoogleAuthClient(cfg.Security.GoogleClientID)

	// Создаём blacklist репозиторий для отзыв токенов
	tokenBlacklist := redisrepo.NewTokenBlacklistRepository(redisClient)

	authService := services.NewAuthService(userRepo, sessionRepo, tokenSvc, googleClient, tokenBlacklist, auditRepo, logger)

	// ---------- Firebase Admin Client (для проверки Firebase ID Token) ----------
	ctx := context.Background()
	firebaseAuthClient, firebaseErr := middleware.NewFirebaseAdminClient(ctx, logger)
	if firebaseErr != nil {
		logger.Warn("Firebase Admin SDK initialization failed, Firebase ID Token auth disabled",
			zap.Error(firebaseErr))
		firebaseAuthClient = nil
	} else if firebaseAuthClient != nil {
		logger.Info("Firebase Admin SDK initialized successfully")
	} else {
		logger.Info("Firebase Admin SDK not configured, Firebase ID Token auth disabled")
	}

	// ---------- Rate limit violation repository ----------
	rateLimitRepo := pg.NewRateLimitViolationRepository(db.Pool())

	// ---------- Rate limiter ----------
	limiter := middleware.NewRedisRateLimiter(redisClient, rateLimitRepo)

	// ---------- Account Lockout (защита от brute-force) ----------
	// Блокировка после 5 неудачных попыток на 15 минут
	lockoutDuration := 15 * time.Minute
	accountLockout := middleware.NewAccountLockout(
		redisClient,
		logger,
		5,               // max attempts
		lockoutDuration, // lockout duration
		15*time.Minute,  // window duration
	)

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

	// ---------- FCM Client (Firebase Cloud Messaging) ----------
	var fcmClient *push.FCMClient
	if cfg.Push.FCMCredentialsFile != "" {
		fcmClient, err = push.NewFCMClient(push.FCMClientConfig{
			CredentialsFile: cfg.Push.FCMCredentialsFile,
		}, logger)
		if err != nil {
			logger.Warn("FCM client initialization failed, push notifications disabled",
				zap.String("credentials_file", cfg.Push.FCMCredentialsFile),
				zap.Error(err),
			)
			fcmClient = nil
		} else {
			logger.Info("FCM client initialized successfully")
			defer func() {
				if err := fcmClient.Close(); err != nil {
					logger.Warn("FCM client close error", zap.Error(err))
				}
			}()
		}
	} else {
		logger.Info("FCM credentials not configured, push notifications disabled")
		fcmClient = nil
	}

	// ---------- Notification services ----------
	notifService := services.NewNotificationService(notifRepo, pushTokenRepo, qClient)

	// ---------- SMTP Service (для восстановления пароля) ----------
	smtpService := email.NewSMTPService(
		cfg.Email.SMTPHost,
		cfg.Email.SMTPPort,
		cfg.Email.SMTPUser,
		cfg.Email.SMTPPassword,
		cfg.Email.From,
	)

	// ---------- Personalization repository ----------
	personalizationRepo := pg.NewPersonalizationRepository(db.Pool())

	// ---------- Event Publisher ----------
	var eventPublisher eventing.EventPublisher
	var kafkaPublisher *eventing.KafkaEventPublisher
	if cfg.Eventing.Enabled && len(cfg.Eventing.KafkaBrokers) > 0 && cfg.Eventing.KafkaBrokers[0] != "" {
		kafkaPublisher = eventing.NewKafkaEventPublisher(cfg.Eventing.KafkaBrokers, cfg.Eventing.KafkaTopicRecommendations)
		eventPublisher = kafkaPublisher
		logger.Info("Event publisher enabled", zap.Strings("brokers", cfg.Eventing.KafkaBrokers), zap.String("topic", cfg.Eventing.KafkaTopicRecommendations))
	} else {
		// Заглушка для event publisher, если отключен
		eventPublisher = nil
		kafkaPublisher = nil
		logger.Info("Event publisher disabled")
	}

	// ---------- Weather Service Adapter ----------
	weatherServiceAdapter := adapters.NewWeatherServiceAdapter(weatherService, geo)

	// ---------- Use Cases ----------
	getRecommendationsUC := usecases.NewGetRecommendationsUseCase(
		userRepo,
		recommendationRepo,
		weatherServiceAdapter,
		mlService, // Using the ML service adapter instead of the raw client
		catalogRepo,
		clothingRepo,
		logger,
	)

	// ---------- Recommendation cache ----------
	recCache := cache.NewRecommendationCache(redisClient, logger, cfg.MLFallback.CacheTTL)

	// ---------- Fallback recommendation service ----------
	fallbackSvc := services.NewFallbackRecommendationService(logger)

	// ---------- Доменные сервисы ----------
	recommendationService := services.NewRecommendationService(
		recommendationRepo,
		clothingRepo,
		userRepo,
		weatherService,
		mlClient,
		personalizationRepo,
		ratingRepo,
		eventPublisher,
		recCache,
		fallbackSvc,
		logger,
	)

	achEngine := services.NewAchievementEngine(achEngineRepo, userRepo, notifService) // notifService может быть nil, если не включен

	userService := services.NewUserService(userRepo, logger)

	// ---------- Push Notification Service ----------
	var pushNotificationService *services.PushNotificationService
	if fcmClient != nil {
		pushNotificationService = services.NewPushNotificationService(
			fcmClient,
			notifRepo,
			pushTokenRepo,
			userRepo,
			logger,
		)
		logger.Info("Push notification service initialized")
	} else {
		logger.Info("Push notification service disabled (no FCM client)")
		pushNotificationService = nil
	}

	// ---------- Subscription service ----------
	// Сервис подписок требует доработки PromoRepository (см. issue #XXX)
	// subService := services.NewSubscriptionService(...)
	var subService *services.SubscriptionService

	// ---------- Payment gateways ----------
	// Используем только dummy gateway для разработки
	// Stripe и YooKassa требуют доработки для соответствия интерфейсу PaymentGateway
	gateways := map[string]domain.PaymentGateway{
		"dummy": ext.NewDummyGateway(),
		// "stripe":   ext.NewStripeGateway(cfg.Payments.StripeWebhookSecret),
		// "yookassa": ext.NewYooKassaGateway(cfg.Payments.YooKassaSecretKey),
	}

	// ---------- Billing service (updated to support multiple gateways) ----------
	billingRepo := pg.NewBillingRepository(db.Pool(), logger)
	// Billing service инициализирован, но пока не используется в роутах
	_ = services.NewBillingService(billingRepo, promoRepo, gateways)

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

	// ---------- Модуль 11: Saved Outfits, Catalog services ----------
	savedOutfitService := services.NewSavedOutfitService(savedOutfitRepo)
	catalogService := services.NewCatalogService(catalogRepo, redisClient)

	// ---------- Repositories for module 12 ----------
	uploadedRepo := pg.NewUploadedFilesRepository(db.Pool())
	exportRepo := pg.NewExportRepository(db.Pool())

	// ---------- Subscription repositories (требуют доработки, см. issue #XXX) ----------
	// Эти репозитории объявлены, но сервис подписок пока не активирован
	_ = subPlanRepo
	_ = userSubRepo
	_ = usageRepo
	_ = txRepo
	_ = promoRepo
	_ = redemptionRepo
	_ = familyRepo

	// ---------- Services for module 12 ----------
	fileService := services.NewFileService(s3, uploadedRepo, userRepo)
	exportService := services.NewExportService(exportRepo, uploadedRepo, s3)
	accountService := services.NewAccountService(userRepo, sessionRepo)

	// ---------- Rating service ----------
	// Rating service инициализирован, используется в recommendationHandler
	ratingService := services.NewRatingService(
		ratingRepo,
		recommendationRepo,
		clothingRepo,
		eventPublisher,
		logger,
	)

	// ---------- Rating handler ----------
	ratingHandler := handlers.NewRatingHandler(ratingService, achEngine, logger)

	// ---------- HTTP‑обработчики ----------
	recommendationHandler := handlers.NewRecommendationHandlerWithUseCases(recommendationService, achEngine, logger, getRecommendationsUC)
	authHandler := handlers.NewAuthHandler(authService, accountLockout, lockoutDuration, redisClient, userRepo, smtpService, logger, cfg.Security.CookieSecure)
	userHandler := handlers.NewUserHandler(userService, fileService, exportService, accountService, sessionRepo, logger)
	passwordHandler := handlers.NewPasswordHandler(userRepo, logger)
	weatherHandler := handlers.NewWeatherHandler(weatherService, userRepo, logger)
	subLimiter := middleware.NewSubscriptionLimiter(subService)
	notifHandler := handlers.NewNotificationHandler(notifService, pushNotificationService, logger)

	// ---------- Новые обработчики для модуля 4 ----------
	wardrobeHandler := handlers.NewWardrobeHandler(wardrobeService, logger)

	// ---------- Модуль 11: Handlers ----------
	savedOutfitHandler := handlers.NewSavedOutfitHandler(savedOutfitService)
	catalogHandler := handlers.NewCatalogHandler(catalogService)

	// ---------- Achievement handler ----------
	achievementService := services.NewAchievementsService(achievementRepo)
	achievementHandler := handlers.NewAchievementHandler(achievementService, logger)

	// ---------- Модуль 10: Share, Support, Feedback, Admin ----------
	shareRepo := pg.NewShareRepository(db.Pool())
	supportRepo := pg.NewSupportRepository(db.Pool())
	feedbackRepo := pg.NewFeedbackRepository(db.Pool())
	adminRepo := pg.NewAdminRepository(db.Pool())

	shareService := services.NewShareService(shareRepo)
	supportService := services.NewSupportService(supportRepo, feedbackRepo)
	adminService := services.NewAdminService(adminRepo)

	shareHandler := handlers.NewShareHandler(shareService, logger)
	supportHandler := handlers.NewSupportHandler(supportService)
	feedbackHandler := handlers.NewFeedbackHandler(supportService)
	adminHandler := handlers.NewAdminHandler(adminService, logger)

	// ---------- Модуль 13: API Keys, Feature Flags, Experiments ----------

	apiKeyRepo := pg.NewAPIKeyRepository(db.Pool())
	apiKeyService := services.NewAPIKeyService(apiKeyRepo, cfg.APIKeys.Pepper)
	apiKeyHandler := handlers.NewAPIKeyHandler(apiKeyService)

	ffRepo := pg.NewFeatureFlagRepository(db.Pool())
	ffService := services.NewFeatureFlagService(ffRepo)
	adminFFHandler := handlers.NewAdminFeatureFlagsHandler(ffService)

	expRepo := pg.NewExperimentRepository(db.Pool())
	expService := services.NewExperimentService(expRepo)

	// ---------- Classification Dashboard Handler ----------
	classificationHandler := handlers.NewClassificationHandler(db, logger)

	// ---------- Manual Correction Tool Handler ----------
	correctionHandler := handlers.NewCorrectionHandler(db, logger)

	// ---------- Health checks ----------
	checks := map[string]health.Checker{
		"database": db,
	}
	health.RegisterChecks(checks)

	// ---------- Роутер ----------
	router := setupRouter(cfg, authHandler, userHandler, passwordHandler, weatherHandler, limiter, logger, authService, firebaseAuthClient, subLimiter, notifHandler, wardrobeHandler, recommendationHandler, achievementHandler, savedOutfitHandler, catalogHandler, shareHandler, supportHandler, feedbackHandler, adminHandler, apiKeyHandler, adminFFHandler, expService, apiKeyService, geoHandler, auditRepo, db, mlClient, recCache, ratingHandler, redisClient, classificationHandler, correctionHandler)

	// ---------- HTTP‑сервер ----------
	addr := cfg.Server.Host + ":" + cfg.Server.Port
	srv := &stdhttp.Server{
		Addr:         addr,
		Handler:      router,
		ReadTimeout:  cfg.Server.ReadTimeout,
		WriteTimeout: cfg.Server.WriteTimeout,
		IdleTimeout:  120 * time.Second,
		// TLS Configuration: Enforce TLS 1.2+ with strong cipher suites
		TLSConfig: &tls.Config{
			MinVersion: tls.VersionTLS12,
			CipherSuites: []uint16{
				// TLS 1.3 cipher suites (preferred)
				tls.TLS_AES_128_GCM_SHA256,
				tls.TLS_AES_256_GCM_SHA384,
				tls.TLS_CHACHA20_POLY1305_SHA256,
				// TLS 1.2 cipher suites (strong)
				tls.TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,
				tls.TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,
				tls.TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,
				tls.TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,
				tls.TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256,
				tls.TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256,
			},
			PreferServerCipherSuites: true,
		},
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

	// Закрываем Kafka publisher
	if kafkaPublisher != nil {
		logger.Info("Closing Kafka publisher...")
		if err := kafkaPublisher.Close(); err != nil {
			logger.Error("Failed to close Kafka publisher", zap.Error(err))
		} else {
			logger.Info("Kafka publisher closed successfully")
		}
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
	passwordHandler *handlers.PasswordHandler,
	weatherHandler *handlers.WeatherHandler,
	limiter *middleware.RateLimiter,
	logger *zap.Logger,
	authService *services.AuthService,
	firebaseAuthClient middleware.FirebaseAuthClient,
	subLimiter *middleware.SubscriptionLimiter,
	notifHandler *handlers.NotificationHandler,
	wardrobeHandler *handlers.WardrobeHandler,
	recommendationHandler *handlers.RecommendationHandler,
	achievementHandler *handlers.AchievementHandler,
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
	db *dbpg.DB,
	mlClient *ext.MLClient,
	recCache *cache.RecommendationCache,
	ratingHandler *handlers.RatingHandler,
	redisClient *redis.Client,
	classificationHandler *handlers.ClassificationHandler,
	correctionHandler *handlers.CorrectionHandler,
) *mux.Router {
	router := mux.NewRouter()

	// Configure per-user rate limiting
	perUserRateLimitConfig := middleware.DefaultPerUserRateLimitConfig()

	router.Use(
		middleware.RecoveryMiddleware(logger),
		middleware.HTTPSRedirectMiddleware(cfg.Server.Environment),
		middleware.SecurityHeadersMiddleware(),
		middleware.CORSMiddleware(cfg.Security.CORSAllowedOrigins),
		middleware.LoggerMiddleware(logger),
		middleware.InputSanitizationMiddleware, // Security: Sanitize all JSON inputs
		middleware.PerUserRateLimitMiddleware(limiter, perUserRateLimitConfig),
		middleware.MetricsMiddleware(),
	)

	// Global OPTIONS handler для CORS preflight запросов
	router.Methods(stdhttp.MethodOptions).HandlerFunc(func(w stdhttp.ResponseWriter, r *stdhttp.Request) {
		w.WriteHeader(stdhttp.StatusNoContent)
	})

	router.HandleFunc("/health", func(w stdhttp.ResponseWriter, r *stdhttp.Request) {
		health.Handler(db.Pool(), mlClient)(w, r)
	}).Methods(stdhttp.MethodGet)
	router.PathPrefix("/swagger/").Handler(httpSwagger.WrapHandler)
	router.Handle("/metrics", promhttp.Handler()).Methods(stdhttp.MethodGet)

	api := router.PathPrefix("/api/v1").Subrouter()

	// /api/v1/auth/*
	auth := api.PathPrefix("/auth").Subrouter()
	// Security: применяем специфичные лимиты для auth endpoints
	auth.Use(middleware.AuthRateLimitMiddleware(redisClient, logger))
	authHandler.RegisterRoutes(auth)

	// protected
	protected := api.NewRoute().Subrouter()
	protected.Use(middleware.NewAuthMiddlewareWithFirebase(authService, apiKeyService, firebaseAuthClient, logger).Handler)

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

	// /api/v1/auth/logout должен быть protected
	authProtected := protected.PathPrefix("/auth").Subrouter()
	authProtected.HandleFunc("/logout", authHandler.Logout).Methods(stdhttp.MethodPost)

	// /api/v1/user/*
	user := protected.PathPrefix("/user").Subrouter()
	userHandler.RegisterRoutes(user)

	// /api/v1/user/set-password, /api/v1/user/change-password
	passwordHandler.RegisterRoutes(protected)

	// /api/v1/notifications/*
	notifs := protected.PathPrefix("/notifications").Subrouter()
	notifHandler.RegisterRoutes(notifs)

	// /api/v1/wardrobe/*
	wardrobe := protected.PathPrefix("/wardrobe").Subrouter()
	wardrobeHandler.RegisterRoutes(wardrobe)

	// /api/v1/recommendations/*
	recommendations := protected.PathPrefix("/recommendations").Subrouter()
	recommendationHandler.RegisterRoutes(recommendations)

	// /api/v1/ratings/*
	ratings := protected.PathPrefix("/ratings").Subrouter()
	ratingHandler.RegisterRoutes(ratings)

	// /api/v1/achievements/*
	ach := protected.PathPrefix("/achievements").Subrouter()
	achievementHandler.RegisterRoutes(ach)

	// /api/v1/outfits/*
	outfits := protected.PathPrefix("/outfits").Subrouter()
	savedOutfitHandler.RegisterRoutes(outfits)

	// /api/v1/catalog/*
	// catalog может быть public
	catalog := api.PathPrefix("/catalog").Subrouter()
	catalogHandler.RegisterRoutes(catalog)

	// /api/v1/classification/* (protected - for dashboard and monitoring)
	classification := protected.PathPrefix("/classification").Subrouter()
	classificationHandler.RegisterRoutes(classification)

	// /api/v1/clothing-items/* (protected - for manual correction tool)
	clothingItems := protected.PathPrefix("/clothing-items").Subrouter()
	correctionHandler.RegisterRoutes(clothingItems)

	// public weather (можно на onboarding)
	weather := api.PathPrefix("/weather").Subrouter()
	weatherHandler.RegisterRoutes(weather)

	// public geo (автокомплит городов)
	geoR := api.PathPrefix("/geo").Subrouter()
	geoHandler.RegisterRoutes(geoR)

	// public ml health (проверка доступности ML сервиса)
	mlHealth := api.PathPrefix("/ml").Subrouter()
	mlHealthHandler := handlers.NewMLHealthHandler(mlClient, recCache, logger, cfg.MLFallback.HealthCheckTTL)
	mlHealth.HandleFunc("/health", mlHealthHandler.GetHealth).Methods(stdhttp.MethodGet)
	mlHealth.HandleFunc("/health/detailed", mlHealthHandler.GetHealthDetailed).Methods(stdhttp.MethodGet)

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
