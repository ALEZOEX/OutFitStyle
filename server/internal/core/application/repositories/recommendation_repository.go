package repositories

import (
	"context"
	"outfitstyle/server/internal/core/domain"
)

// RecommendationRepository defines the interface for recommendation data operations
type RecommendationRepository interface {
	// Recommendation operations
	CreateRecommendation(ctx context.Context, recommendation *domain.RecommendationResponse) (int, error)
	GetRecommendationByID(ctx context.Context, id int) (*domain.RecommendationResponse, error)
	GetUserRecommendations(ctx context.Context, userID int, limit int) ([]domain.RecommendationResponse, error)

	// Outfit operations
	CreateOutfitSet(ctx context.Context, outfit *domain.OutfitSet) (int, error)
	GetOutfitSetByID(ctx context.Context, id int) (*domain.OutfitSet, error)
	// Clothing item operations
	GetClothingItemByID(ctx context.Context, id int) (*domain.ClothingItem, error)
	GetUserClothingItems(ctx context.Context, userID int) ([]domain.ClothingItem, error)
	CreateClothingItem(ctx context.Context, item *domain.ClothingItem) (int, error)
}

// Since we don't have the domain package, we'll define the structs here for now
type RecommendationResponse struct {
	ID          int         `json:"id"`
	UserID      int         `json:"user_id"`
	Location    string      `json:"location"`
	Temperature float64     `json:"temperature"`
	Weather     string      `json:"weather"`
	Humidity    int         `json:"humidity"`
	WindSpeed   float64     `json:"wind_speed"`
	Message     string      `json:"message"`
	Items       []OutfitSet `json:"items"`
	Timestamp   string      `json:"timestamp"`
}

type OutfitSet struct {
	ID          int            `json:"id"`
	Name        string         `json:"name"`
	Description string         `json:"description"`
	Items       []ClothingItem `json:"items"`
	Confidence  float64        `json:"confidence"`
	WeatherType string         `json:"weather_type"`
	Temperature float64        `json:"temperature"`
	Season      string         `json:"season"`
}

type ClothingItem struct {
	ID          int     `json:"id"`
	Name        string  `json:"name"`
	Category    string  `json:"category"`
	Description string  `json:"description"`
	IconEmoji   string  `json:"icon_emoji"`
	MLScore     float64 `json:"ml_score,omitempty"`
}
