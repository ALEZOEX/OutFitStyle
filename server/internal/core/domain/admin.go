package domain

// AdminStats структура для хранения статистики администратора
type AdminStats struct {
	TotalUsers           int `json:"total_users"`           // Общее количество пользователей
	ActiveUsers          int `json:"active_users"`          // Количество активных пользователей
	TotalRecommendations int `json:"total_recommendations"` // Общее количество рекомендаций
	TotalOutfitsSaved    int `json:"total_outfits_saved"`   // Общее количество сохраненных нарядов
	TotalWardrobeItems   int `json:"total_wardrobe_items"`  // Общее количество вещей в гардеробах
	TotalAchievements    int `json:"total_achievements"`    // Общее количество полученных достижений
	TotalPayments        int `json:"total_payments"`        // Общее количество платежей
	TotalSupportTickets  int `json:"total_support_tickets"` // Общее количество тикетов поддержки
	TotalFeedback        int `json:"total_feedback"`        // Общее количество отзывов
}
