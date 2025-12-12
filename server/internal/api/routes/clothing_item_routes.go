package routes

import (
	"github.com/gorilla/mux"

	"outfitstyle/server/internal/api/handlers"
)

// RegisterClothingItemRoutes registers clothing item-related routes
func RegisterClothingItemRoutes(router *mux.Router, handler *handlers.ClothingItemHandler) {
	// Подмаршрут для вещей
	clothing := router.PathPrefix("/api/v1/clothing-items").Subrouter()

	// GET /api/v1/clothing-items/{id} - Получить вещь по ID
	clothing.HandleFunc("/{id:[0-9]+}", handler.GetClothingItem).Methods("GET")

	// POST /api/v1/clothing-items - Создать новую вещь
	clothing.HandleFunc("", handler.CreateClothingItem).Methods("POST")

	// PUT /api/v1/clothing-items/{id} - Обновить вещь
	clothing.HandleFunc("/{id:[0-9]+}", handler.UpdateClothingItem).Methods("PUT")

	// DELETE /api/v1/clothing-items/{id} - Удалить вещь
	clothing.HandleFunc("/{id:[0-9]+}", handler.DeleteClothingItem).Methods("DELETE")

	// GET /api/v1/users/{user_id}/wardrobe - Получить вещи из гардероба пользователя
	clothing.HandleFunc("/users/{user_id:[0-9]+}/wardrobe", handler.GetWardrobeItems).Methods("GET")

	// GET /api/v1/users/{user_id}/clothing-items - Получить все вещи пользователя
	clothing.HandleFunc("/users/{user_id:[0-9]+}/all", handler.GetAllClothingItems).Methods("GET")

	// POST /api/v1/users/{user_id}/wardrobe/{item_id} - Добавить вещь в гардероб
	clothing.HandleFunc("/users/{user_id:[0-9]+}/wardrobe/{item_id:[0-9]+}", handler.AddItemToWardrobe).Methods("POST")

	// DELETE /api/v1/users/{user_id}/wardrobe/{item_id} - Удалить вещь из гардероба
	clothing.HandleFunc("/users/{user_id:[0-9]+}/wardrobe/{item_id:[0-9]+}", handler.RemoveItemFromWardrobe).Methods("DELETE")
}