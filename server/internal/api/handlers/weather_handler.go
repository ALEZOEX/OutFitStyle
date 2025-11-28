package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/pkg/errors"
	"go.uber.org/zap"

	"outfitstyle/server/internal/infrastructure/external"
)

type WeatherHandler struct {
	weather *external.WeatherService
	logger  *zap.Logger
}

func NewWeatherHandler(weather *external.WeatherService, logger *zap.Logger) *WeatherHandler {
	return &WeatherHandler{weather: weather, logger: logger}
}

func (h *WeatherHandler) GetWeather(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	city := r.URL.Query().Get("city")
	if city == "" {
		http.Error(w, "city is required", http.StatusBadRequest)
		return
	}

	data, err := h.weather.GetWeather(ctx, city)
	if err != nil {
		if errors.Is(err, external.ErrCityNotFound) {
			http.Error(w, "city not found", http.StatusBadRequest)
			return
		}
		h.logger.Error("failed to get weather", zap.Error(err))
		http.Error(w, "failed to get weather", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(data); err != nil {
		h.logger.Error("failed to encode weather response", zap.Error(err))
	}
}
