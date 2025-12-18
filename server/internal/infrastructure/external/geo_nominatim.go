package external

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"strconv"
	"time"

	"github.com/pkg/errors"
	"github.com/redis/go-redis/v9"

	"outfitstyle/server/internal/core/domain"
)

type NominatimClient struct {
	baseURL string
	http    *http.Client
	ua      string
	redis   *redis.Client
	ttl     time.Duration
}

func NewNominatimClient(baseURL string, timeout time.Duration, userAgent string, redis *redis.Client, ttl time.Duration) *NominatimClient {
	if baseURL == "" {
		baseURL = "https://nominatim.openstreetmap.org"
	}
	if userAgent == "" {
		userAgent = "OutfitStyle/1.0 (contact: dev @outfitstyle.app)"
	}
	if ttl <= 0 {
		ttl = 7 * 24 * time.Hour
	}
	return &NominatimClient{
		baseURL: baseURL,
		http:    &http.Client{Timeout: timeout},
		ua:      userAgent,
		redis:   redis,
		ttl:     ttl,
	}
}

type nominatimItem struct {
	DisplayName string `json:"display_name"`
	Lat         string `json:"lat"`
	Lon         string `json:"lon"`
}

func (c *NominatimClient) Autocomplete(ctx context.Context, q string, limit int, lang string) ([]domain.GeoPlace, error) {
	if limit <= 0 || limit > 20 {
		limit = 8
	}
	if lang == "" {
		lang = "ru"
	}
	cacheKey := fmt.Sprintf("geo:nominatim:ac:%s:%d:%s", url.QueryEscape(q), limit, lang)

	if c.redis != nil {
		if v, err := c.redis.Get(ctx, cacheKey).Result(); err == nil && v != "" {
			var cached []domain.GeoPlace
			if e := json.Unmarshal([]byte(v), &cached); e == nil {
				return cached, nil
			}
		}
	}

	u := fmt.Sprintf("%s/search?format=json&q=%s&limit=%d&addressdetails=0&accept-language=%s",
		c.baseURL,
		url.QueryEscape(q),
		limit,
		url.QueryEscape(lang),
	)

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, u, nil)
	if err != nil {
		return nil, errors.Wrap(err, "new request")
	}
	req.Header.Set("User-Agent", c.ua)

	res, err := c.http.Do(req)
	if err != nil {
		return nil, errors.Wrap(err, "do request")
	}
	defer res.Body.Close()

	if res.StatusCode/100 != 2 {
		return nil, errors.Errorf("nominatim bad status: %d", res.StatusCode)
	}

	var items []nominatimItem
	if err := json.NewDecoder(res.Body).Decode(&items); err != nil {
		return nil, errors.Wrap(err, "decode response")
	}

	out := make([]domain.GeoPlace, 0, len(items))
	for _, it := range items {
		lat, err1 := strconv.ParseFloat(it.Lat, 64)
		lon, err2 := strconv.ParseFloat(it.Lon, 64)
		if err1 != nil || err2 != nil {
			continue
		}
		out = append(out, domain.GeoPlace{
			DisplayName: it.DisplayName,
			Latitude:    lat,
			Longitude:   lon,
		})
	}

	if c.redis != nil {
		if b, e := json.Marshal(out); e == nil {
			_ = c.redis.Set(ctx, cacheKey, string(b), c.ttl).Err()
		}
	}

	return out, nil
}