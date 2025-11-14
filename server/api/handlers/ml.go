package handlers

import (
	"log"
	"net/http"

	"outfitstyle/server/api/services"
	"outfitstyle/server/api/utils"
)

type MLHandler struct {
	mlService *services.MLService
}

func NewMLHandler(ml *services.MLService) *MLHandler {
	return &MLHandler{mlService: ml}
}

func (h *MLHandler) TrainModel(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		utils.JSONError(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	log.Println("🎓 Training ML model...")

	result, err := h.mlService.TrainModel()
	if err != nil {
		log.Printf("❌ Training failed: %v", err)
		utils.JSONError(w, err.Error(), http.StatusInternalServerError)
		return
	}

	log.Printf("✅ Training completed: %d samples", result.TrainingSamples)

	utils.JSONResponse(w, result, http.StatusOK)
}

func (h *MLHandler) GetStats(w http.ResponseWriter, r *http.Request) {
	stats, err := h.mlService.GetStats()
	if err != nil {
		log.Printf("❌ Error getting stats: %v", err)
		utils.JSONError(w, "Ошибка получения статистики", http.StatusInternalServerError)
		return
	}

	utils.JSONResponse(w, stats, http.StatusOK)
}
