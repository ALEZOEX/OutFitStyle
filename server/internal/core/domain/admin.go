package domain

type AdminStats struct {
	TotalUsers        int `json:"total_users"`
	ActiveUsers       int `json:"active_users"`
	TotalRecommendations int `json:"total_recommendations"`
	TotalOutfitsSaved int `json:"total_outfits_saved"`
	TotalWardrobeItems int `json:"total_wardrobe_items"`
	TotalAchievements int `json:"total_achievements"`
	TotalPayments     int `json:"total_payments"`
	TotalSupportTickets int `json:"total_support_tickets"`
	TotalFeedback     int `json:"total_feedback"`
}