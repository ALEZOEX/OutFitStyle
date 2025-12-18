package handlers

import (
	"net/http"
	"strconv"

	"github.com/gorilla/mux"
	"github.com/pkg/errors"
	"go.uber.org/zap"

	"outfitstyle/server/internal/api/middleware"
	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/infrastructure/external"
	resp "outfitstyle/server/internal/pkg/http"
)

type WeatherHandler struct {
	svc *external.WeatherService
	userRepo repositories.UserRepository
	log *zap.Logger
}

func NewWeatherHandler(svc *external.WeatherService, userRepo repositories.UserRepository, log *zap.Logger) *WeatherHandler {
	return &WeatherHandler{svc: svc, userRepo: userRepo, log: log}
}

func (h *WeatherHandler) RegisterRoutes(r *mux.Router) {
	r.HandleFunc("", h.GetCurrent).Methods(http.MethodGet)
	r.HandleFunc("/forecast", h.GetForecast).Methods(http.MethodGet)
}

func (h *WeatherHandler) GetCurrent(w http.ResponseWriter, r *http.Request) {
	q := r.URL.Query()
	latStr := q.Get("lat")
	lonStr := q.Get("lon")

	var lat, lon float64
	if latStr != "" && lonStr != "" {
		var err1, err2 error
		lat, err1 = strconv.ParseFloat(latStr, 64)
		lon, err2 = strconv.ParseFloat(lonStr, 64)
		if err1 != nil || err2 != nil {
			resp.Error(w, http.StatusBadRequest, errors.New("invalid lat or lon"))
			return
		}
	} else {
		userID, ok := middleware.GetUserIDFromContext(r.Context())
		if !ok {
			resp.Error(w, http.StatusBadRequest, errors.New("lat and lon are required"))
			return
		}
		dLat, dLon, err := h.userRepo.GetDefaultCoords(r.Context(), userID)
		if err != nil || dLat == nil || dLon == nil {
			resp.Error(w, http.StatusBadRequest, errors.New("set default location in profile first"))
			return
		}
		lat, lon = *dLat, *dLon
	}

	current, updatedAt, err := h.svc.GetCurrent(r.Context(), lat, lon)
	if err != nil {
		h.log.Warn("weather current failed", zap.Error(err))
		resp.Error(w, http.StatusBadGateway, errors.New("weather service unavailable"))
		return
	}

	resp.Success(w, map[string]any{
		"current":    current,
		"location":   current.Location,
		"updated_at": updatedAt,
	})
}

func (h *WeatherHandler) GetForecast(w http.ResponseWriter, r *http.Request) {
	q := r.URL.Query()
	latStr := q.Get("lat")
	lonStr := q.Get("lon")

	var lat, lon float64
	if latStr != "" && lonStr != "" {
		var err1, err2 error
		lat, err1 = strconv.ParseFloat(latStr, 64)
		lon, err2 = strconv.ParseFloat(lonStr, 64)
		if err1 != nil || err2 != nil {
			resp.Error(w, http.StatusBadRequest, errors.New("invalid lat or lon"))
			return
		}
	} else {
		userID, ok := middleware.GetUserIDFromContext(r.Context())
		if !ok {
			resp.Error(w, http.StatusBadRequest, errors.New("lat and lon are required"))
			return
		}
		dLat, dLon, err := h.userRepo.GetDefaultCoords(r.Context(), userID)
		if err != nil || dLat == nil || dLon == nil {
			resp.Error(w, http.StatusBadRequest, errors.New("set default location in profile first"))
			return
		}
		lat, lon = *dLat, *dLon
	}

	days := 3
	if v := q.Get("days"); v != "" {
		if n, err := strconv.Atoi(v); err == nil && n > 0 && n <= 7 {
			days = n
		}
	}

	location, daily, hourly, updatedAt, err := h.svc.GetForecast(r.Context(), lat, lon, days)
	if err != nil {
		h.log.Warn("weather forecast failed", zap.Error(err))
		resp.Error(w, http.StatusBadGateway, errors.New("weather service unavailable"))
		return
	}

	resp.Success(w, map[string]any{
		"location":   location,
		"daily":      daily,
		"hourly":     hourly,
		"updated_at": updatedAt,
	})
}