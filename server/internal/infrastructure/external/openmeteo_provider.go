package external

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/domain"
)

type OpenMeteoProvider struct {
	baseURL string
	http    *http.Client
}

func NewOpenMeteoProvider(baseURL string, timeout time.Duration) *OpenMeteoProvider {
	if baseURL == "" {
		baseURL = "https://api.open-meteo.com"
	}
	return &OpenMeteoProvider{
		baseURL: baseURL,
		http:    &http.Client{Timeout: timeout},
	}
}

type omCurrentResp struct {
	Current struct {
		Temperature float64 `json:"temperature_2m"`
		FeelsLike   float64 `json:"apparent_temperature"`
		Humidity    int     `json:"relative_humidity_2m"`
		WindSpeed   float64 `json:"wind_speed_10m"`
		WeatherCode int     `json:"weather_code"`
	} `json:"current"`
}

type omForecastResp struct {
	Daily struct {
		Time []string  `json:"time"`
		Min  []float64 `json:"temperature_2m_min"`
		Max  []float64 `json:"temperature_2m_max"`
	} `json:"daily"`
	Hourly struct {
		Time []string  `json:"time"`
		Temp []float64 `json:"temperature_2m"`
		Pop  []int     `json:"precipitation_probability"`
	} `json:"hourly"`
}

func (p *OpenMeteoProvider) Current(ctx context.Context, lat, lon float64) (domain.WeatherSnapshot, error) {
	u := fmt.Sprintf("%s/v1/forecast?latitude=%f&longitude=%f&current=temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,weather_code&timezone=auto",
		p.baseURL, lat, lon)

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, u, nil)
	if err != nil {
		return domain.WeatherSnapshot{}, errors.Wrap(err, "new request")
	}

	res, err := p.http.Do(req)
	if err != nil {
		return domain.WeatherSnapshot{}, errors.Wrap(err, "do request")
	}
	defer res.Body.Close()

	if res.StatusCode/100 != 2 {
		return domain.WeatherSnapshot{}, errors.Errorf("open-meteo bad status: %d", res.StatusCode)
	}

	var payload omCurrentResp
	if err := json.NewDecoder(res.Body).Decode(&payload); err != nil {
		return domain.WeatherSnapshot{}, errors.Wrap(err, "decode")
	}

	code := payload.Current.WeatherCode
	main := openMeteoMainFromCode(code)

	return domain.WeatherSnapshot{
		Location:    fmt.Sprintf("%.4f,%.4f", lat, lon),
		Temperature: payload.Current.Temperature,
		FeelsLike:   payload.Current.FeelsLike,
		Humidity:    payload.Current.Humidity,
		WindSpeed:   payload.Current.WindSpeed,
		WeatherCode: fmt.Sprintf("%d", code),
		WeatherMain: main,
	}, nil
}

func (p *OpenMeteoProvider) Forecast(ctx context.Context, lat, lon float64, days int) (string, []any, []any, error) {
	if days <= 0 || days > 7 {
		days = 3
	}

	u := fmt.Sprintf("%s/v1/forecast?latitude=%f&longitude=%f&daily=temperature_2m_min,temperature_2m_max&hourly=temperature_2m,precipitation_probability&forecast_days=%d&timezone=auto",
		p.baseURL, lat, lon, days)

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, u, nil)
	if err != nil {
		return "", nil, nil, errors.Wrap(err, "new request")
	}

	res, err := p.http.Do(req)
	if err != nil {
		return "", nil, nil, errors.Wrap(err, "do request")
	}
	defer res.Body.Close()

	if res.StatusCode/100 != 2 {
		return "", nil, nil, errors.Errorf("open-meteo bad status: %d", res.StatusCode)
	}

	var payload omForecastResp
	if err := json.NewDecoder(res.Body).Decode(&payload); err != nil {
		return "", nil, nil, errors.Wrap(err, "decode")
	}

	daily := make([]any, 0, len(payload.Daily.Time))
	for i := range payload.Daily.Time {
		minT := 0.0
		maxT := 0.0
		if i < len(payload.Daily.Min) {
			minT = payload.Daily.Min[i]
		}
		if i < len(payload.Daily.Max) {
			maxT = payload.Daily.Max[i]
		}
		daily = append(daily, map[string]any{
			"date":     payload.Daily.Time[i],
			"temp_min": minT,
			"temp_max": maxT,
		})
	}

	hourly := make([]any, 0, min(len(payload.Hourly.Time), 48))
	for i := range payload.Hourly.Time {
		if i >= 48 {
			break
		}
		temp := 0.0
		pop := 0
		if i < len(payload.Hourly.Temp) {
			temp = payload.Hourly.Temp[i]
		}
		if i < len(payload.Hourly.Pop) {
			pop = payload.Hourly.Pop[i]
		}
		hourly = append(hourly, map[string]any{
			"time":                      payload.Hourly.Time[i],
			"temp":                      temp,
			"precipitation_probability": pop,
		})
	}

	return fmt.Sprintf("%.4f,%.4f", lat, lon), daily, hourly, nil
}

// Упрощённый маппинг в "rain/snow/clear/clouds/mist/thunderstorm"
// (достаточно для логики fallback и tips; не претендует на полную точность всех кодов).
func openMeteoMainFromCode(code int) string {
	switch {
	case code >= 50 && code < 70:
		return "Rain"
	case code >= 70 && code < 90:
		return "Snow"
	case code >= 90:
		return "Thunderstorm"
	case code >= 40 && code < 50:
		return "Mist"
	case code == 0:
		return "Clear"
	default:
		return "Clouds"
	}
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}
