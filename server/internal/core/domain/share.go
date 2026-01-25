package domain

import "time"

type ShareCreateRequest struct {
	RecommendationID *ID   `json:"recommendation_id,omitempty"`
	SavedOutfitID    *ID   `json:"saved_outfit_id,omitempty"`
	ShowUserName     *bool `json:"show_user_name,omitempty"`
}

type ShareCreateResponse struct {
	ShareCode string `json:"share_code"`
	ShareURL  string `json:"share_url"`
}

type SharedOutfitPublicResponse struct {
	Outfit   any     `json:"outfit"`
	UserName *string `json:"user_name,omitempty"`
}

type ShareLink struct {
	ID           ID         `json:"id"`
	UserID       ID         `json:"user_id"`
	ResourceID   string     `json:"resource_id"`   // ID ресурса, который шарится (например, outfit ID)
	ResourceType string     `json:"resource_type"` // тип ресурса (outfit, wardrobe_item, etc.)
	ShareToken   string     `json:"share_token"`   // уникальный токен для доступа к шарингу
	IsPublic     bool       `json:"is_public"`
	ViewCount    int        `json:"view_count"`
	MaxViews     *int       `json:"max_views,omitempty"` // ограничение на количество просмотров
	ExpiresAt    *time.Time `json:"expires_at,omitempty"`
	CreatedAt    time.Time  `json:"created_at"`
	UpdatedAt    time.Time  `json:"updated_at"`
}
