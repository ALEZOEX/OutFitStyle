package main

import (
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/joho/godotenv"

	"outfitstyle/server/api/config"
	"outfitstyle/server/api/handlers"
	"outfitstyle/server/api/middleware"
	"outfitstyle/server/api/services"
)

func main() {
	// Загружаем .env
	godotenv.Load()

	cfg := config.Load()

	log.Println("🚀 Starting OutfitStyle API...")
	log.Printf("📝 Config: Port=%s, Debug=%v", cfg.Port, cfg.Debug)

	// Инициализация сервисов
	weatherService := services.NewWeatherService(
		cfg.WeatherAPIKey,
		cfg.WeatherAPIURL,
		cfg.WeatherAPITimeout,
	)
	log.Println("✅ Weather service initialized")

	mlService := services.NewMLService(cfg.MLServiceURL)
	log.Println("✅ ML service initialized")

	//Проверяем ML сервис
	go func() {
		time.Sleep(2 * time.Second)
		if err := mlService.HealthCheck(); err != nil {
			log.Printf("⚠️ ML service not available: %v", err)
		} else {
			log.Println("✅ ML service is healthy")
		}
	}()

	// Database
	var dbService *services.DBService
	db, err := services.NewDBService(cfg.DatabaseURL())
	if err != nil {
		log.Printf("⚠️ Database unavailable: %v", err)
		log.Println("⚠️ Running without database")
	} else {
		dbService = db
		defer dbService.Close()
		log.Println("✅ Database connected")
	}

	// Handlers
	recommendHandler := handlers.NewRecommendationHandler(weatherService, mlService, dbService)
	userHandler := handlers.NewUserHandler(dbService)
	ratingHandler := handlers.NewRatingHandler(mlService)
	mlHandler := handlers.NewMLHandler(mlService)
	favoriteHandler := handlers.NewFavoriteHandler(dbService)
	achievementHandler := handlers.NewAchievementHandler(dbService) // Добавляем обработчик достижений

	// Routes
	mux := http.NewServeMux()

	// Main routes
	mux.HandleFunc("/", homeHandler)
	mux.HandleFunc("/health", healthHandler)

	// Recommendations
	mux.HandleFunc("/api/recommend", recommendHandler.GetRecommendations)
	mux.HandleFunc("/api/recommendations/history", recommendHandler.GetRecommendationHistory)
	mux.HandleFunc("/api/recommendations/get", recommendHandler.GetRecommendationByID)

	// Users
	mux.HandleFunc("/api/users/profile", func(w http.ResponseWriter, r *http.Request) {
		if r.Method == http.MethodGet {
			userHandler.GetProfile(w, r)
		} else if r.Method == http.MethodPut || r.Method == http.MethodPost {
			userHandler.UpdateProfile(w, r)
	} else {
			http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		}
	})
	mux.HandleFunc("/api/users/stats", userHandler.GetStats)

	// Ratings
	mux.HandleFunc("/api/ratings/rate", ratingHandler.RateRecommendation)

	// ML
	mux.HandleFunc("/api/ml/train", mlHandler.TrainModel)
	mux.HandleFunc("/api/ml/stats", mlHandler.GetStats)

	// Favorites
	mux.HandleFunc("POST /api/favorites", favoriteHandler.AddFavorite)
	mux.HandleFunc("GET /api/favorites", favoriteHandler.GetFavorites)
	mux.HandleFunc("DELETE /api/favorites", favoriteHandler.DeleteFavorite)

	// Achievements
	mux.HandleFunc("GET /api/achievements", achievementHandler.GetAchievements)

	// Middleware
	handler := middleware.CORS(middleware.Logger(mux))

	// Start server
	addr := ":" + cfg.Port
	
	printBanner(addr)

	log.Fatal(http.ListenAndServe(addr, handler))
}

func printBanner(addr string) {
	fmt.Printf("\n")
	fmt.Printf("╔═══════════════════════════════════════════════════════════╗\n")
	fmt.Printf("║                                                           ║\n")
	fmt.Printf("║            👔 OUTFITSTYLE API v2.0 🧠                   ║\n")
	fmt.Printf("║                  ML-Powered Recommendations               ║\n")
	fmt.Printf("║                                                           ║\n")
	fmt.Printf("╚═══════════════════════════════════════════════════════════╝\n")
	fmt.Printf("\n")
	fmt.Printf("📍 Server:      http://localhost%s\n", addr)
	fmt.Printf("💚 Health:      http://localhost%s/health\n", addr)
	fmt.Printf("\n")
	fmt.Printf("🌐 ENDPOINTS:\n")
	fmt.Printf("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
	fmt.Printf("  GET  /api/recommend?city=Moscow&user_id=1\n")
	fmt.Printf("  GET  /api/recommendations/history?user_id=1\n")
fmt.Printf("  GET  /api/users/profile?user_id=1\n")
	fmt.Printf("  PUT  /api/users/profile\n")
	fmt.Printf("  POST /api/ratings/rate\n")
	fmt.Printf("  POST /api/ml/train\n")
	fmt.Printf("  GET  /api/ml/stats\n")
fmt.Printf("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
	fmt.Printf("\n")
}

func homeHandler(w http.ResponseWriter, r *http.Request) {
	html := `<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OutfitStyle API v2.0</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
          min-height: 100vh;
            padding: 20px;
        }
        .container {
            max-width: 900px;
            margin: 0auto;
        }
        .card {
            background: rgba(255, 255, 255,0.1);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 40px;
            margin: 20px 0;
            box-shadow: 0 8px 32px rgba(0, 0, 0,0.1);
        }
        h1 { font-size: 2.5em; margin-bottom: 10px; }
        .badge {
            display: inline-block;
            background: rgba(255, 215, 0, 0.3);
            color: gold;
           padding: 5px 15px;
            border-radius: 20px;
            font-size: 0.9em;
            margin: 10px5px;
        }
        .endpoint {
            background: rgba(255, 255, 255, 0.15);
            padding: 15px;
            margin: 10px 0;
            border-radius: 10px;
            font-family: 'Courier New', monospace;
            font-size: 0.95em;
        }
        .method {
            display: inline-block;
            padding:3px 10px;
            border-radius: 5px;
            font-weight: bold;
            margin-right: 10px;
}
        .get { background: #4CAF50; }
        .post { background: #2196F3; }
        .put { background: #FF9800; }
        a {
            color: #FFD700;
            text-decoration: none;
            transition: all 0.3s;
        }
        a:hover {
            text-decoration: underline;
            color: #FFF;
        }
        .feature {
display:inline-block;
            margin: 10px;
            padding: 10px 20px;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 15px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="card">
            <h1>👔 OutfitStyle API</h1>
<p style="font-size: 1.2em; opacity: 0.9;">Умные рекомендации одежды с ML персонализацией</p>
            
            <div style="margin-top: 20px;">
                <span class="badge">🧠 ML-Powered</span>
                <span class="badge">🎯 Персонализация</span>
                <span class="badge">🌤 Погода</span>
               <spanclass="badge">⭐ Рейтинги</span>
            </div>
        </div>

        <div class="card">
           <h2>📡 API Endpoints</h2>
            
            <h3 style="margin-top: 20px;">Рекомендации</h3>
           <div class="endpoint">
                <span class="method get">GET</span>
                <a href="/api/recommend?city=Moscow&user_id=1">/api/recommend?city=Moscow&user_id=1</a>
            </div>
            <div class="endpoint">
<span class="method get">GET</span>
                <a href="/api/recommendations/history?user_id=1">/api/recommendations/history?user_id=1</a>
            </div>
            
            <h3 style="margin-top: 20px;">Профили</h3>
            <div class="endpoint">
                <span class="method get">GET</span>
                <a href="/api/users/profile?user_id=1">/api/users/profile?user_id=1</a>
            </div>
            <div class="endpoint">
                <span class="methodput">PUT</span>
                /api/users/profile
            </div>
            <div class="endpoint">
                <span class="methodget">GET</span>
                <a href="/api/users/stats?user_id=1">/api/users/stats?user_id=1</a>
            </div>
<h3 style="margin-top: 20px;">ML</h3>
            <div class="endpoint">
                <span class="method post">POST</span>
                /api/ratings/rate
            </div>
            <div class="endpoint">
                <span class="method post">POST</span>
                /api/ml/train
            </div>
            <div class="endpoint">
                <span class="method get">GET</span>
                <a href="/api/ml/stats">/api/ml/stats</a>
            </div>
        </div>

        <div class="card">
           <h2>✨ Возможности</h2>
            <div class="feature">🌍 Погода в реальном времени</div>
            <div class="feature">🧠 Машинное обучение</div>
            <div class="feature">👤 Персональные профили</div>
            <div class="feature">⭐ Система рейтингов</div>
            <div class="feature">📊 Статистика</div>
            <div class="feature">🔄Автообучение</div>
        </div>

        <div class="card" style="text-align:center;">
            <p>Made with ❤️ for научно-исследовательская работа</p>
            <p style="opacity: 0.7; margin-top: 10px;">v2.0.0 | 2024</p>
        </div>
    </div>
</body>
</html>`
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	w.Write([]byte(html))
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.Write([]byte(`{
		"status": "ok",
		"service": "OutfitStyle API",
		"version": "2.0.0",
		"features": ["ml", "personalization", "weather", "ratings"]
	}`))
}