package domain

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
