package services

import (
	"database/sql"
	"fmt"
	"log"

	"outfitstyle/server/api/models"

	_ "github.com/lib/pq"
)

type DBService struct {
	db *sql.DB
}

func NewDBService(connString string) (*DBService, error) {
	db, err := sql.Open("postgres", connString)
	if err != nil {
		return nil, err
	}

	if err := db.Ping(); err != nil {
		return nil, err
	}

	log.Println("✅ Connected to PostgreSQL")
	return &DBService{db: db}, nil
}

func (s *DBService) Close() error {
	return s.db.Close()
}

// GetUserProfile получает профиль пользователя
func (s *DBService) GetUserProfile(userID int) (*models.UserProfile, error) {
	var profile models.UserProfile

	err := s.db.QueryRow(`
		SELECT 
			id, user_id, gender, age_range, style_preference, 
			temperature_sensitivity, preferred_categories
		FROM user_profiles
		WHERE user_id = $1
	`, userID).Scan(
		&profile.ID,
		&profile.UserID,
		&profile.Gender,
		&profile.AgeRange,
		&profile.StylePreference,
		&profile.TemperatureSensitivity,
		&profile.PreferredCategories,
	)

	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("profile not found for user %d", userID)
	}
	if err != nil {
		return nil, err
	}

	return &profile, nil
}

// CreateUserProfile создает профиль пользователя
func (s *DBService) CreateUserProfile(profile *models.UserProfile) error {
	return s.db.QueryRow(`
		INSERT INTO user_profiles 
		(user_id, gender, age_range, style_preference, temperature_sensitivity, preferred_categories)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING id
	`,
		profile.UserID,
		profile.Gender,
		profile.AgeRange,
		profile.StylePreference,
		profile.TemperatureSensitivity,
		profile.PreferredCategories,
	).Scan(&profile.ID)
}

// UpdateUserProfile обновляет профиль пользователя
func (s *DBService) UpdateUserProfile(profile *models.UserProfile) error {
	_, err := s.db.Exec(`
		UPDATE user_profiles
		SET 
			gender = $1,
			age_range = $2,
			style_preference = $3,
			temperature_sensitivity = $4,
			preferred_categories = $5,
			updated_at = NOW()
		WHERE user_id = $6
	`,
		profile.Gender,
		profile.AgeRange,
		profile.StylePreference,
		profile.TemperatureSensitivity,
		profile.PreferredCategories,
		profile.UserID,
	)
	return err
}

// GetUser получает пользователя по ID
func (s *DBService) GetUser(userID int) (*models.User, error) {
	var user models.User

	err := s.db.QueryRow(`
		SELECT id, email, name, created_at
		FROM users
		WHERE id = $1
	`, userID).Scan(&user.ID, &user.Email, &user.Name, &user.CreatedAt)

	if err != nil {
		return nil, err
	}

	return &user, nil
}

// GetUserByEmail получает пользователя по email
func (s *DBService) GetUserByEmail(email string) (*models.User, error) {
	var user models.User

	err := s.db.QueryRow(`
		SELECT id, email, name, created_at
		FROM users
		WHERE email = $1
	`, email).Scan(&user.ID, &user.Email, &user.Name, &user.CreatedAt)

	if err != nil {
		return nil, err
	}

	return &user, nil
}

// CreateUser создает нового пользователя
func (s *DBService) CreateUser(email, name string) (*models.User, error) {
	var user models.User

	err := s.db.QueryRow(`
		INSERT INTO users (email, name)
		VALUES ($1, $2)
		RETURNING id, email, name, created_at
	`, email, name).Scan(&user.ID, &user.Email, &user.Name, &user.CreatedAt)

	if err != nil {
		return nil, err
	}

	return &user, nil
}

// GetRecommendation получает рекомендацию по ID
func (s *DBService) GetRecommendation(recommendationID int) (*models.RecommendationDB, error) {
	var rec models.RecommendationDB

	err := s.db.QueryRow(`
		SELECT 
			id, user_id, location, temperature, feels_like, 
			weather, humidity, wind_speed, algorithm_version, 
			ml_confidence, created_at
		FROM recommendations
		WHERE id = $1
	`, recommendationID).Scan(
		&rec.ID,
		&rec.UserID,
		&rec.Location,
		&rec.Temperature,
		&rec.FeelsLike,
		&rec.Weather,
		&rec.Humidity,
		&rec.WindSpeed,
		&rec.AlgorithmVersion,
		&rec.MLConfidence,
		&rec.CreatedAt,
	)

	if err != nil {
		return nil, err
	}

	// Получаем предметы одежды для этой рекомендации
	rows, err := s.db.Query(`
		SELECT 
			ci.id, ci.name, ci.category, ci.subcategory, 
			ci.icon_emoji, ri.ml_score
		FROM recommendation_items ri
		JOIN clothing_items ci ON ri.clothing_item_id = ci.id
		WHERE ri.recommendation_id = $1
		ORDER BY ri.position
	`, recommendationID)

	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		var item models.ClothingItem
		err := rows.Scan(
			&item.ID,
			&item.Name,
			&item.Category,
			&item.Subcategory,
			&item.IconEmoji,
			&item.Score,
		)
		if err != nil {
			log.Printf("Error scanning item: %v", err)
			continue
		}
		rec.Items = append(rec.Items, item)
	}

	return &rec, nil
}

// GetUserRecommendations получает все рекомендации пользователя
func (s *DBService) GetUserRecommendations(userID int, limit int) ([]models.RecommendationDB, error) {
	rows, err := s.db.Query(`
		SELECT 
			id, user_id, location, temperature, feels_like, 
			weather, humidity, wind_speed, algorithm_version, 
			ml_confidence, created_at
		FROM recommendations
		WHERE user_id = $1
		ORDER BY created_at DESC
		LIMIT $2
	`, userID, limit)

	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var recommendations []models.RecommendationDB

	for rows.Next() {
		var rec models.RecommendationDB
		err := rows.Scan(
			&rec.ID,
			&rec.UserID,
			&rec.Location,
			&rec.Temperature,
			&rec.FeelsLike,
			&rec.Weather,
			&rec.Humidity,
			&rec.WindSpeed,
			&rec.AlgorithmVersion,
			&rec.MLConfidence,
			&rec.CreatedAt,
		)
		if err != nil {
			log.Printf("Error scanning recommendation: %v", err)
			continue
		}

		// Получаем предметы для каждой рекомендации
		itemRows, err := s.db.Query(`
			SELECT 
				ci.id, ci.name, ci.category, ci.subcategory, 
				ci.icon_emoji, ri.ml_score
			FROM recommendation_items ri
			JOIN clothing_items ci ON ri.clothing_item_id = ci.id
			WHERE ri.recommendation_id = $1
			ORDER BY ri.position
		`, rec.ID)

		if err == nil {
			for itemRows.Next() {
				var item models.ClothingItem
				err := itemRows.Scan(
					&item.ID,
					&item.Name,
					&item.Category,
					&item.Subcategory,
					&item.IconEmoji,
					&item.Score,
				)
				if err == nil {
					rec.Items = append(rec.Items, item)
				}
			}
			itemRows.Close()
		}

		recommendations = append(recommendations, rec)
	}

	return recommendations, nil
}

// GetUserStats получает статистику пользователя
func (s *DBService) GetUserStats(userID int) (*models.UserStats, error) {
	var stats models.UserStats
	stats.UserID = userID

	// Общее количество рекомендаций
	err := s.db.QueryRow(`
		SELECT COUNT(*) FROM recommendations WHERE user_id = $1
	`, userID).Scan(&stats.TotalRecommendations)
	if err != nil {
		return nil, err
	}

	// Количество оценок
	err = s.db.QueryRow(`
		SELECT COUNT(*) FROM ratings WHERE user_id = $1
	`, userID).Scan(&stats.TotalRatings)
	if err != nil {
		return nil, err
	}

	// Средняя оценка
	err = s.db.QueryRow(`
		SELECT COALESCE(AVG(overall_rating), 0) FROM ratings WHERE user_id = $1
	`, userID).Scan(&stats.AverageRating)
	if err != nil {
		return nil, err
	}

	// Любимые категории (топ-3)
	rows, err := s.db.Query(`
		SELECT ci.category, COUNT(*) as cnt
		FROM ratings r
		JOIN clothing_items ci ON r.clothing_item_id = ci.id
		WHERE r.user_id = $1 AND r.overall_rating >= 4
		GROUP BY ci.category
		ORDER BY cnt DESC
		LIMIT 3
	`, userID)

	if err == nil {
		defer rows.Close()
		for rows.Next() {
			var category string
			var count int
			if err := rows.Scan(&category, &count); err == nil {
				stats.FavoriteCategories = append(stats.FavoriteCategories, category)
			}
		}
	}

	return &stats, nil
}

// SaveUsageHistory сохраняет историю взаимодействия
func (s *DBService) SaveUsageHistory(userID, recommendationID int, clicked bool, viewedDuration int) error {
	_, err := s.db.Exec(`
		INSERT INTO usage_history (user_id, recommendation_id, clicked, viewed_duration)
		VALUES ($1, $2, $3, $4)
	`, userID, recommendationID, clicked, viewedDuration)
	return err
}
