//go:build integration

// Пакет integration_test содержит интеграционные тесты для приложения
// Эти тесты проверяют работу системы в целом, включая взаимодействие с базой данных
package integration_test

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/gorilla/mux"
	"github.com/redis/go-redis/v9"
	"go.uber.org/zap"

	"outfitstyle/server/internal/api/handlers"
	"outfitstyle/server/internal/api/middleware"
	"outfitstyle/server/internal/config"
	"outfitstyle/server/internal/core/application/services"
	"outfitstyle/server/internal/infrastructure/external"
	"outfitstyle/server/internal/infrastructure/eventing"
	dbpg "outfitstyle/server/internal/infrastructure/persistence/postgres"
	pg "outfitstyle/server/internal/infrastructure/persistence/postgres/pg"
)

// TestSmoke_AuthWardrobeRecommendation выполняет сквозной тест аутентификации, создания гардероба и получения рекомендаций
// Тест проверяет полный цикл работы приложения: регистрация пользователя, добавление вещей в гардероб, получение рекомендаций
func TestSmoke_AuthWardrobeRecommendation(t *testing.T) {
	dsn := os.Getenv("DATABASE_URL")
	if dsn == "" {
		t.Skip("DATABASE_URL is not set")
	}

	logger := zap.NewNop()

	db, err := dbpg.NewDB(dsn, logger)
	if err != nil {
		t.Fatalf("db connect: %v", err)
	}
	defer db.Close()

	// Apply migrations using the db pool
	applyMigrations(t, db.Pool())

	// Создаем заглушку OpenWeather API для тестирования
	weatherSrv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if strings.HasPrefix(r.URL.Path, "/weather") {
			_ = json.NewEncoder(w).Encode(map[string]any{
				"name": "Moscow",
				"weather": []map[string]any{
					{"id": 800, "main": "Clear"},
				},
				"main": map[string]any{
					"temp":       10.0,
					"feels_like": 8.0,
					"humidity":   60,
				},
				"wind": map[string]any{
					"speed": 3.0,
				},
			})
			return
		}
		if strings.HasPrefix(r.URL.Path, "/forecast") {
			_ = json.NewEncoder(w).Encode(map[string]any{
				"city": map[string]any{"name": "Moscow"},
				"list": []any{},
			})
			return
		}
		http.NotFound(w, r)
	}))
	defer weatherSrv.Close()

	// Создаем заглушку ML сервиса для тестирования
	mlSrv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/api/v1/rank" {
			http.NotFound(w, r)
			return
		}
		var req map[string]any
		_ = json.NewDecoder(r.Body).Decode(&req)

		cands, _ := req["candidates"].([]any)
		byCat := map[string][]int{}
		for _, c := range cands {
			m, _ := c.(map[string]any)
			cat, _ := m["category"].(string)
			id, _ := m["id"].(float64) // JSON numbers are parsed as float64
			if cat != "" {
				byCat[cat] = append(byCat[cat], int(id))
			}
		}

		rankings := map[string]any{}
		for _, cat := range []string{"outerwear", "upper", "lower", "footwear", "accessory"} {
			ids := byCat[cat]
			if len(ids) == 0 {
				rankings[cat] = []any{}
				continue
			}
			// выбираем первый элемент
			rankings[cat] = []any{
				map[string]any{
					"id":         float64(ids[0]), // Convert back to float64 for JSON
					"score":      0.9,
					"confidence": 0.8,
					"factors":    map[string]any{"stub": true},
				},
			}
		}

		_ = json.NewEncoder(w).Encode(map[string]any{
			"request_id":         req["request_id"],
			"rankings":           rankings,
			"outfit_score":       0.75,
			"style_coherence":    0.6,
			"color_harmony":      0.6,
			"model_version":      "stub",
			"processing_time_ms": 5,
		})
	}))
	defer mlSrv.Close()

	// Config minimal (for JWT TTL)
	cfg := &config.AppConfig{
		Server: config.ServerConfig{
			Environment: "test",
		},
		Security: config.SecurityConfig{
			JWTSecret:          "test-jwt-secret-change-in-production-123456",
			AccessTokenTTL:     15 * time.Minute,
			RefreshTokenTTL:    24 * time.Hour,
			CORSAllowedOrigins: []string{"*"},
			RateLimitPerMinute: 1000,
		},
		OpenWeather: config.OpenWeatherConfig{
			APIKey:   "x",
			BaseURL:  weatherSrv.URL,
			CacheTTL: 0,
		},
		MLService: config.MLServiceConfig{
			BaseURL: mlSrv.URL,
			Timeout: 5 * time.Second,
		},
		Database: config.DatabaseConfig{URL: dsn},
		Redis:    config.RedisConfig{URL: ""},
	}

	// Repos
	userRepo := pg.NewUserRepository(db.Pool(), logger)
	sessionRepo := pg.NewSessionRepository(db.Pool(), logger)
	clothingRepo := pg.NewClothingRepository(db.Pool(), nil, logger)
	wardrobeRepo := pg.NewWardrobeRepository(db.Pool())
	recRepo := pg.NewRecommendationRepository(db.Pool(), nil, logger)
	subRepo := pg.NewSubscriptionRepository(db.Pool(), logger)

	// Clients/services
	tokenSvc := services.NewTokenService(cfg.Security.JWTSecret, cfg.Security.AccessTokenTTL, cfg.Security.RefreshTokenTTL)
	googleClient := external.NewGoogleAuthClient(cfg.Security.GoogleClientID)
	authSvc := services.NewAuthService(userRepo, sessionRepo, tokenSvc, googleClient, logger)

	// Account lockout stub для тестов
	accountLockout := &mockAccountLockout{}
	lockoutDuration := 30 * time.Minute
	var redisClient *redis.Client = nil // Redis не требуется для базовых тестов

	subSvc := services.NewSubscriptionService(subRepo)
	subLimiter := middleware.NewSubscriptionLimiter(subSvc)

	ow := external.NewOpenWeatherClient(cfg.OpenWeather.APIKey, cfg.OpenWeather.BaseURL, 5*time.Second)
	provider := external.NewOpenWeatherProvider(ow)
	weatherSvc := external.NewWeatherService(provider, nil, 0, "") // Pass empty provider name

	ml := external.NewMLClient(cfg.MLService.BaseURL, cfg.MLService.Timeout)

	wardrobeSvc := services.NewWardrobeService(wardrobeRepo, clothingRepo)
	personalizationRepo := pg.NewPersonalizationRepository(db.Pool())
	var eventPublisher eventing.EventPublisher = nil // No event publisher for tests
	recSvc := services.NewRecommendationService(recRepo, clothingRepo, userRepo, weatherSvc, ml, personalizationRepo, eventPublisher, logger)

	userSvc := services.NewUserService(userRepo, logger)

	// Handlers
	authH := handlers.NewAuthHandler(authSvc, accountLockout, lockoutDuration, redisClient, userRepo, nil, logger)
	userH := handlers.NewUserHandler(userSvc, nil, nil, nil, nil, logger) // only profile here, not testing for module 12
	wardrobeH := handlers.NewWardrobeHandler(wardrobeSvc, logger)
	recH := handlers.NewRecommendationHandlerWithUseCases(recSvc, nil, logger, nil) // Using new constructor with use cases
	subH := handlers.NewSubscriptionHandler(subSvc, logger)

	// Router
	router := mux.NewRouter()
	api := router.PathPrefix("/api/v1").Subrouter()

	// public
	auth := api.PathPrefix("/auth").Subrouter()
	authH.RegisterRoutes(auth)

	subPublic := api.PathPrefix("/subscription").Subrouter()
	subH.RegisterPublic(subPublic)

	// protected
	protected := api.NewRoute().Subrouter()
	protected.Use(middleware.AuthMiddleware(authSvc, nil))
	protected.Use(subLimiter.EnforceRecommendationsLimit())
	protected.Use(subLimiter.EnforceWardrobeLimit())

	user := protected.PathPrefix("/user").Subrouter()
	userH.RegisterRoutes(user)

	wardrobe := protected.PathPrefix("/wardrobe").Subrouter()
	wardrobeH.RegisterRoutes(wardrobe)

	recs := protected.PathPrefix("/recommendations").Subrouter()
	recH.RegisterRoutes(recs)

	srv := httptest.NewServer(router)
	defer srv.Close()

	// 1) register
	email := "it_" + time.Now().Format("20060102150405") + "@example.com"
	regBody := map[string]any{"email": email, "password": "Password123!"}
	regRes := doJSON(t, srv.URL+"/api/v1/auth/register", "", regBody)
	access := regRes["tokens"].(map[string]any)["access_token"].(string)

	// 2) create 5 wardrobe items (manual) across categories
	cats := []struct {
		name, category, subcategory, style string
	}{
		{"Jacket", "outerwear", "coat", "casual"},
		{"Tee", "upper", "tshirt", "casual"},
		{"Jeans", "lower", "jeans", "casual"},
		{"Sneakers", "footwear", "sneakers", "casual"},
		{"Hat", "accessory", "hat", "casual"},
	}
	for _, c := range cats {
		doJSON(t, srv.URL+"/api/v1/wardrobe", access, map[string]any{
			"name": c.name, "category": c.category, "subcategory": c.subcategory, "style": c.style,
		})
	}

	// 3) create recommendation
	recRes := doJSON(t, srv.URL+"/api/v1/recommendations", access, map[string]any{
		"latitude":  55.7558,
		"longitude": 37.6173,
		"occasion":  "daily",
	})
	rec := recRes["recommendation"].(map[string]any)
	recID := rec["id"].(string)

	// 4) list recommendations
	listRes := doGET(t, srv.URL+"/api/v1/recommendations?limit=10", access)
	if int(listRes["count"].(float64)) < 1 {
		t.Fatalf("expected at least 1 recommendation, got %#v", listRes)
	}

	// 5) rate recommendation
	doJSON(t, srv.URL+"/api/v1/recommendations/"+recID+"/rate", access, map[string]any{"rating": 5})
}

// doJSON отправляет JSON-запрос на указанный URL с токеном доступа
// Используется для тестирования API-эндпоинтов, требующих авторизации
func doJSON(t *testing.T, url string, accessToken string, body any) map[string]any {
	t.Helper()
	b, _ := json.Marshal(body)
	req, _ := http.NewRequest(http.MethodPost, url, bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	if accessToken != "" {
		req.Header.Set("Authorization", "Bearer "+accessToken)
	}
	res, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatalf("http do: %v", err)
	}
	defer res.Body.Close()
	var out map[string]any
	_ = json.NewDecoder(res.Body).Decode(&out)
	if res.StatusCode/100 != 2 {
		t.Fatalf("status %d body=%v", res.StatusCode, out)
	}
	return out
}

// doGET отправляет GET-запрос на указанный URL с токеном доступа
// Используется для тестирования GET-эндпоинтов, требующих авторизации
func doGET(t *testing.T, url string, accessToken string) map[string]any {
	t.Helper()
	req, _ := http.NewRequest(http.MethodGet, url, nil)
	if accessToken != "" {
		req.Header.Set("Authorization", "Bearer "+accessToken)
	}
	res, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatalf("http do: %v", err)
	}
	defer res.Body.Close()
	var out map[string]any
	_ = json.NewDecoder(res.Body).Decode(&out)
	if res.StatusCode/100 != 2 {
		t.Fatalf("status %d body=%v", res.StatusCode, out)
	}
	return out
}

// mockAccountLockout — заглушка для тестов
type mockAccountLockout struct{}

func (m *mockAccountLockout) CheckLoginAttempt(ctx context.Context, email string) (bool, int, *time.Time, error) {
	return true, 5, nil, nil
}

func (m *mockAccountLockout) RecordFailedAttempt(ctx context.Context, email string) error {
	return nil
}

func (m *mockAccountLockout) Reset(ctx context.Context, email string) error {
	return nil
}

