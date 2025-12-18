package handlers

import (
	"net/http"
	"strconv"
	"strings"

	"github.com/gorilla/mux"
	"github.com/pkg/errors"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/domain"
	"outfitstyle/server/internal/infrastructure/external"
	resp "outfitstyle/server/internal/pkg/http"
)

type GeoHandler struct {
	geo *external.NominatimClient
	log *zap.Logger
}

func NewGeoHandler(geo *external.NominatimClient, log *zap.Logger) *GeoHandler {
	return &GeoHandler{geo: geo, log: log}
}

func (h *GeoHandler) RegisterRoutes(r *mux.Router) {
	r.HandleFunc("/autocomplete", h.Autocomplete).Methods(http.MethodGet)
}

func (h *GeoHandler) Autocomplete(w http.ResponseWriter, r *http.Request) {
	q := strings.TrimSpace(r.URL.Query().Get("q"))
	if q == "" {
		resp.Error(w, http.StatusBadRequest, errors.New("q is required"))
		return
	}

	limit := 8
	if v := r.URL.Query().Get("limit"); v != "" {
		if n, err := strconv.Atoi(v); err == nil && n > 0 && n <= 20 {
			limit = n
		}
	}
	lang := r.URL.Query().Get("lang")
	if lang == "" {
		lang = "ru"
	}

	places, err := h.geo.Autocomplete(r.Context(), q, limit, lang)
	if err != nil {
		h.log.Warn("geo autocomplete failed", zap.Error(err))
		resp.Error(w, http.StatusBadGateway, errors.New("geo service unavailable"))
		return
	}

	resp.Success(w, domain.GeoAutocompleteResponse{Places: places})
}