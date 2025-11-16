package services

import(
	"database/sql"
	"encoding/json"
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

func (s *DBService) Close()error {
	return s.db.Close()
}

// DBвозвращает соединение с базой данных
func (s *DBService) DB() *sql.DB {
	return s.db
}

// GetUserProfile получает профиль пользователя
func(s *DBService) GetUserProfile(userID int) (*models.UserProfile, error) {
	var profile models.UserProfile

	err := s.db.QueryRow(`
		SELECT 
			id, user_id, gender,age_range, style_preference, 
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
		return nil, fmt.Errorf("profile not foundfor user %d", userID)
	}
	if err != nil {
		return nil, err
	}

	return &profile, nil
}

// CreateUserProfile создает профиль пользователя
func (s *DBService) CreateUserProfile(profile *models.UserProfile) error {
	return s.db.QueryRow(`
INSERTINTO user_profiles 
		(user_id, gender, age_range, style_preference, temperature_sensitivity, preferred_categories)
	VALUES ($1, $2,$3, $4, $5, $6)
		RETURNINGid
	`,
		profile.UserID,
		profile.Gender,
		profile.AgeRange,
		profile.StylePreference,
		profile.TemperatureSensitivity,
		profile.PreferredCategories,
).Scan(&profile.ID)
}

//UpdateUserProfile обновляет профиль пользователя
func (s *DBService) UpdateUserProfile(profile *models.UserProfile) error {
	_,err := s.db.Exec(`
		UPDATE user_profiles
		SET 
			gender = $1,
			age_range =$2,
			style_preference = $3,
temperature_sensitivity = $4,
			preferred_categories = $5,
			updated_at = NOW()
		WHERE user_id =$6`,
		profile.Gender,
		profile.AgeRange,
		profile.StylePreference,
		profile.TemperatureSensitivity,
		profile.PreferredCategories,
	profile.UserID,
	)
	return err
}

// GetUserполучает пользователя по ID
func (s *DBService) GetUser(userID int) (*models.User, error) {
	var user models.User

	err := s.db.QueryRow(`
		SELECT id, email, name, created_at
		FROM users
	WHERE id= $1
	`, userID).Scan(&user.ID, &user.Email, &user.Name, &user.CreatedAt)

	if err!= nil{
		return nil, err
	}

	return &user, nil
}

// GetUserByEmail получает пользователя по email
func (s *DBService) GetUserByEmail(email string) (*models.User, error) {
	var user models.User

	err := s.db.QueryRow(`
		SELECT id,email, name, created_atFROM users
		WHERE email = $1
	`, email).Scan(&user.ID, &user.Email, &user.Name, &user.CreatedAt)

	if err!=nil {
		return nil, err
	}

	return &user,nil
}

// CreateUserсоздает новогопользователя
func(s *DBService) CreateUser(email, name string) (*models.User, error) {
	var user models.User

	err := s.db.QueryRow(`
		INSERT INTO users (email, name)
		VALUES ($1,$2)
	RETURNING id, email, name,created_at
	`,email,name).Scan(&user.ID, &user.Email, &user.Name, &user.CreatedAt)

	if err != nil {
		return nil, err
	}

	return &user,nil
}

// GetRecommendation получаетрекомендацию по ID
func (s *DBService) GetRecommendation(recommendationID int) (*models.RecommendationDB, error) {
	var rec models.RecommendationDB

	err := s.db.QueryRow(`
		SELECT 
			id, user_id, location,temperature, feels_like, 
weather, humidity, wind_speed, algorithm_version,ml_confidence, created_at
FROM recommendations
WHERE id=$1
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

	//Получаем предметы одежды для этой рекомендации
	rows, err :=s.db.Query(`
		SELECTci.id, ci.name, ci.category, ci.subcategory, 
			ci.icon_emoji, ri.ml_score
		FROM recommendation_items ri
JOINclothing_items ci ON ri.clothing_item_id = ci.id
		WHERE ri.recommendation_id =$1
		ORDER BY ri.position`, recommendationID)

	if err !=nil {
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
			log.Printf("Error scanning item:%v", err)
			continue
		}
rec.Items = append(rec.Items, item)
	}

return &rec,nil
}

// GetUserRecommendations получает всерекомендации пользователя
func (s *DBService) GetUserRecommendations(userID int, limit int) ([]models.RecommendationDB, error){
	rows, err := s.db.Query(`
		SELECT 
			id, user_id, location, temperature, feels_like,weather, humidity, wind_speed, algorithm_version,ml_confidence, created_at
	FROMrecommendations
		WHERE user_id = $1
		ORDER BY created_atDESC
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
			log.Printf("Errorscanning recommendation: %v", err)
			continue
		}

		//Получаем предметы для каждой рекомендации
itemRows, err := s.db.Query(`
			SELECT 
			ci.id, ci.name, ci.category, ci.subcategory, 
				ci.icon_emoji, ri.ml_score
                        FROM recommendation_items ri
			JOIN clothing_items ci ON ri.clothing_item_id = ci.id WHERE ri.recommendation_id = $1
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
					rec.Items =append(rec.Items, item)
				}
			}
			itemRows.Close()
}

		recommendations = append(recommendations, rec)
	}

	return recommendations, nil
}

// GetUserStats получаетстатистику пользователя
func(s *DBService) GetUserStats(userID int) (*models.UserStats, error) {
	var stats models.UserStats
	stats.UserID = userID

// Общее количество рекомендаций
	err:= s.db.QueryRow(`
		SELECT COUNT(*) FROMrecommendations WHEREuser_id = $1`, userID).Scan(&stats.TotalRecommendations)
	if err != nil {
return nil, err
}

	// Количество оценок
	err = s.db.QueryRow(`
		SELECT COUNT(*) FROM ratings WHERE user_id =$1
	`, userID).Scan(&stats.TotalRatings)
if err != nil {
		return nil, err}

	// Средняяоценка
	err = s.db.QueryRow(`
		SELECTCOALESCE(AVG(overall_rating), 0) FROM ratings WHERE user_id = $1
`, userID).Scan(&stats.AverageRating)
	if err !=nil {
		return nil, err
	}

	// Любимые категории (топ-3)
	rows, err:= s.db.Query(`
		SELECTci.category, COUNT(*) as cntFROM ratings r
		JOIN clothing_items ci ON r.clothing_item_id = ci.id
		WHERE r.user_id = $1 AND r.overall_rating >= 4GROUPBY ci.category
		ORDER BYcnt DESC
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
func (s *DBService) SaveUsageHistory(userID, recommendationID int, clicked bool, viewedDuration int)error {
	_, err := s.db.Exec(`
		INSERT INTO usage_history (user_id, recommendation_id, clicked, viewed_duration)
		VALUES ($1, $2,$3, $4)
	`, userID, recommendationID, clicked, viewedDuration)
	return err
}

// AddFavorite добавляет рекомендацию в избранное
func (dbs *DBService) AddFavorite(userID, recommendationID int) (int, error) {
	var id int
	query :=`
		INSERT INTO favorite_outfits (user_id,recommendation_id)
		VALUES ($1, $2)
ON CONFLICT (user_id, recommendation_id) DO NOTHING
		RETURNING id
	`
	err :=dbs.db.QueryRow(query, userID, recommendationID).Scan(&id)
	if err == sql.ErrNoRows {
		// Запись ужесуществует, это не ошибка
		return 0,nil
	}
	return id, err
}

//GetFavoritesByUserID получает все избранные комплекты пользователя
func (dbs *DBService) GetFavoritesByUserID(userID int) ([]map[string]interface{}, error) {
	query := `
	SELECT
			fo.id as favorite_id,
fo.created_at as saved_at,
			r.location,
		r.temperature,
			r.weather,
			json_agg(
				json_build_object(
					'id', ci.id,
					'name', ci.name,
					'icon_emoji', ci.icon_emoji
				) ORDER BY ri.position
			) as items
FROM favorite_outfits fo
		JOIN recommendations r ON fo.recommendation_id =r.id
JOIN recommendation_items ri ON r.id = ri.recommendation_id
	JOIN clothing_items ci ON ri.clothing_item_id = ci.id
		WHERE fo.user_id = $1
		GROUP BY fo.id, r.id
		ORDER BY fo.created_at DESC
	`
	rows, err := dbs.db.Query(query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var favorites []map[string]interface{}
	for rows.Next(){
		var (
			favoriteID                          int
			savedAt string
			location, weather                     string
			temperature                           float64
			itemsJSON                             []byte
		)

		if err := rows.Scan(&favoriteID, &savedAt, &location, &temperature, &weather, &itemsJSON); err != nil {
log.Printf("⚠️ Error scanning favorite row: %v", err)
			continue
		}

		var items []map[string]interface{}
		if err := json.Unmarshal(itemsJSON, &items); err!= nil {
			log.Printf("⚠️ Error unmarshalling favorite items JSON: %v", err)
                       continue}
		
                favorite := map[string]interface{}{
			"favorite_id": favoriteID,
			"saved_at":    savedAt,
			"location":    location,
                        "temperature": temperature,
			"weather":     weather,
			"items":       items,
                }
	favorites= append(favorites, favorite)
	}

	return favorites, nil
}

// DeleteFavorite удаляет комплект из избранного
func (dbs *DBService) DeleteFavorite(favoriteID int) error {
	query := "DELETE FROM favorite_outfits WHERE id = $1"
	_, err := dbs.db.Exec(query, favoriteID)
	return err
}
