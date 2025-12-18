//go:build integration

package integration_test

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"testing"
	"time"

	"go.uber.org/zap"

	"outfitstyle/server/internal/api/handlers"
	"outfitstyle/server/internal/api/middleware"
	"outfitstyle/server/internal/config"
	"outfitstyle/server/internal/core/application/services"
	"outfitstyle/server/internal/infrastructure/external"
	dbpg "outfitstyle/server/internal/infrastructure/persistence/postgres"
	pg "outfitstyle/server/internal/infrastructure/persistence/postgres/pg"

	"github.com/gorilla/mux"
)

func TestSmoke_AuthWardrobeRecommendation(t *testing.T) {
	dsn := os.Getenv("DATABASE_URL")
	if dsn == "" {
		t.Skip("DATABASE_URL is not set")
	}

	logger := zap.NewNop()

	// Apply migrations (idempotent)
	if err := applyMigrations(t, dsn, filepath.Join(".", "migrations")); err != nil {
		t.Fatalf("apply migrations: %v", err)
	}

	db, err := dbpg.NewDB(dsn, logger)
	if err != nil {
		t.Fatalf("db connect: %v", err)
	}
	defer db.Close()

	// Stub OpenWeather
	weatherSrv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if strings.HasPrefix(r.URL.Path, "/weather") {
			_ = json.NewEncoder(w).Encode(map[string]any{
				"name": "Moscow",
				"weather": []map[string]any{
					{"id": 800, "main": "Clear"},
				},
				"main": map[string]any{
					"temp":       10.0,
					"feels_like":  8.0,
					"humidity":    60,
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

	// Stub ML rank
	mlSrv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/api/v1/rank" {
			http.NotFound(w, r)
			return
		}
		var req map[string]any
		_ = json.NewDecoder(r.Body).Decode(&req)

		cands, _ := req["candidates"].([]any)
		byCat := map[string][]string{}
		for _, c := range cands {
			m, _ := c.(map[string]any)
			cat, _ := m["category"].(string)
			id, _ := m["id"].(string)
			if cat != "" && id != "" {
				byCat[cat] = append(byCat[cat], id)
			}
		}

		rankings := map[string]any{}
		for _, cat := range []string{"outerwear", "upper", "lower", "footwear", "accessory"} {
			ids := byCat[cat]
			if len(ids) == 0 {
				rankings[cat] = []any{}
				continue
			}
			// pick first
			rankings[cat] = []any{
				map[string]any{
					"id":         ids[0],
					"score":      0.9,
					"confidence": 0.8,
					"factors":    map[string]any{"stub": true},
				},
			}
		}

		_ = json.NewEncoder(w).Encode(map[string]any{
			"request_id":          req["request_id"],
			"rankings":            rankings,
			"outfit_score":        0.75,
			"style_coherence":     0.6,
			"color_harmony":       0.6,
			"model_version":       "stub",
			"processing_time_ms":  5,
		})
	}))
	defer mlSrv.Close()

	// Config minimal (for JWT TTL)
	cfg := &config.AppConfig{
		Server: config.ServerConfig{
			Environment: "test",
		},
		Security: config.SecurityConfig{
			JWTSecret:          "test-secret-test-secret-test-secret-test-secret",
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
	userRepo := pg.NewUserRepository(db, logger)
	sessionRepo := pg.NewSessionRepository(db, logger)
	clothingRepo := pg.NewClothingRepository(db, logger)
	wardrobeRepo := pg.NewWardrobeRepository(db)
	recRepo := pg.NewRecommendationRepository(db, logger)
	subRepo := pg.NewSubscriptionRepository(db, logger)

	// Clients/services
	tokenSvc := services.NewTokenService(cfg.Security.JWTSecret, cfg.Security.AccessTokenTTL, cfg.Security.RefreshTokenTTL)
	authSvc := services.NewAuthService(userRepo, sessionRepo, tokenSvc)

	subSvc := services.NewSubscriptionService(subRepo)
	subLimiter := middleware.NewSubscriptionLimiter(subSvc)

	ow := external.NewOpenWeatherClient(cfg.OpenWeather.APIKey, cfg.OpenWeather.BaseURL, 5*time.Second)
	weatherSvc := external.NewWeatherService(ow, nil, 0)

	ml := external.NewMLClient(cfg.MLService.BaseURL, cfg.MLService.Timeout)

	wardrobeSvc := services.NewWardrobeService(wardrobeRepo, clothingRepo)
	recSvc := services.NewRecommendationService(recRepo, clothingRepo, wardrobeRepo, weatherSvc, ml, nil, logger)

	userSvc := services.NewUserService(userRepo, logger)

	// Handlers
	authH := handlers.NewAuthHandler(authSvc)
	userH := handlers.NewUserHandler(userSvc, nil, nil, nil, nil, logger) // only profile here, not testing for module 12
	wardrobeH := handlers.NewWardrobeHandler(wardrobeSvc, logger)
	recH := handlers.NewRecommendationHandler(recSvc, subSvc, weatherSvc, logger)
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

func applyMigrations(t *testing.T, dsn, dir string) error {
	t.Helper()

	ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
	defer cancel()

	pool, err := dbpg.NewPGXPool(ctx, dsn) // см. helper below
	if err != nil {
		return err
	}
	defer pool.Close()

	_, err = pool.Exec(ctx, `
CREATE TABLE IF NOT EXISTS schema_migrations (
version VARCHAR(64) PRIMARY KEY,
applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
)`)
	if err != nil {
		return err
	}

	type mig struct {
		version string
		path    string
		sql     []byte
	}

	var migs []mig
	entries, err := os.ReadDir(dir)
	if err != nil {
		return err
	}
	for _, e := range entries {
		if e.IsDir() {
			continue
		}
		name := e.Name()
		if !strings.HasSuffix(name, ".up.sql") {
			continue
		}
		b, err := os.ReadFile(filepath.Join(dir, name))
		if err != nil {
			return err
		}
		v := strings.SplitN(name, "_", 2)[0]
		migs = append(migs, mig{version: v, path: name, sql: b})
	}
	sort.Slice(migs, func(i, j int) bool { return migs[i].path < migs[j].path })

	applied := map[string]bool{}
	rows, err := pool.Query(ctx, `SELECT version FROM schema_migrations`)
	if err != nil {
		return err
	}
	for rows.Next() {
		var v string
		_ = rows.Scan(&v)
		applied[v] = true
	}
	rows.Close()

	for _, m := range migs {
		if applied[m.version] {
			continue
		}
		tx, err := pool.Begin(ctx)
		if err != nil {
			return err
		}
		if _, err := tx.Exec(ctx, string(m.sql)); err != nil {
			_ = tx.Rollback(ctx)
			return err
		}
		if _, err := tx.Exec(ctx, `INSERT INTO schema_migrations(version) VALUES ($1)`, m.version); err != nil {
			_ = tx.Rollback(ctx)
			return err
		}
		if err := tx.Commit(ctx); err != nil {
			return err
		}
	}

	return nil
}