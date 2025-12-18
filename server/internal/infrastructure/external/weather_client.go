package external

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strings"
	"time"

	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/domain"
)

// ErrCityNotFound возвращается, если OpenWeatherMap вернул 404 по городу.
var ErrCityNotFound = fmt.Errorf("city not found")

// OpenWeatherClient инкапсулирует работу с OpenWeatherMap.
type OpenWeatherClient struct {
	baseURL string
	apiKey  string
	http    *http.Client
}

// NewOpenWeatherClient создаёт новый клиент OpenWeather.
func NewOpenWeatherClient(apiKey, baseURL string, timeout time.Duration) *OpenWeatherClient {
	baseURL = strings.TrimRight(baseURL, "/")

	return &OpenWeatherClient{
		baseURL: baseURL,
		apiKey:  apiKey,
		http: &http.Client{
			Timeout: timeout,
		},
	}
}

// структура ответа OpenWeatherMap для current weather
type owmCurrentResponse struct {
	Name  string `json:"name"`
	Coord struct {
		Lat float64 `json:"lat"`
		Lon float64 `json:"lon"`
	} `json:"coord"`
	Weather []struct {
		ID          int    `json:"id"`
		Main        string `json:"main"`
		Description string `json:"description"`
	} `json:"weather"`
	Main struct {
		Temp      float64 `json:"temp"`
		FeelsLike float64 `json:"feels_like"`
		TempMin   float64 `json:"temp_min"`
		TempMax   float64 `json:"temp_max"`
		Humidity  int     `json:"humidity"`
	} `json:"main"`
	Wind struct {
		Speed float64 `json:"speed"`
	} `json:"wind"`
	Dt int64 `json:"dt"`
}

// GetCurrent возвращает актуальную погоду по координатам.
func (c *OpenWeatherClient) GetCurrent(ctx context.Context, lat, lon float64) (domain.WeatherSnapshot, error) {
	if c.apiKey == "" || c.baseURL == "" {
		return domain.WeatherSnapshot{}, fmt.Errorf("openweather client is not configured: empty apiKey or baseURL")
	}

	endpoint := fmt.Sprintf("%s/weather?lat=%f&lon=%f&appid=%s&units=metric&lang=ru", c.baseURL, lat, lon, c.apiKey)

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, endpoint, nil)
	if err != nil {
		return domain.WeatherSnapshot{}, fmt.Errorf("create weather request: %w", err)
	}

	resp, err := c.http.Do(req)
	if err != nil {
		return domain.WeatherSnapshot{}, fmt.Errorf("weather api request failed: %w", err)
	}
	defer resp.Body.Close()

	body, _ := io.ReadAll(resp.Body)

	// Любой не 200 — ошибка провайдера или ключа
	if resp.StatusCode != http.StatusOK {
		return domain.WeatherSnapshot{}, fmt.Errorf("weather api error: status=%d, body=%s", resp.StatusCode, string(body))
	}

	var apiResp owmCurrentResponse
	if err := json.Unmarshal(body, &apiResp); err != nil {
		return domain.WeatherSnapshot{}, fmt.Errorf("decode weather response: %w", err)
	}

	weatherMain := ""
	weatherCode := ""
	if len(apiResp.Weather) > 0 {
		weatherMain = apiResp.Weather[0].Main
		weatherCode = fmt.Sprintf("%d", apiResp.Weather[0].ID)
	}

	weather := domain.WeatherSnapshot{
		Location:    apiResp.Name,
		Temperature: apiResp.Main.Temp,
		FeelsLike:   apiResp.Main.FeelsLike,
		Humidity:    apiResp.Main.Humidity,
		WindSpeed:   apiResp.Wind.Speed, // m/s при units=metric
		WeatherMain: weatherMain,
		WeatherCode: weatherCode,
	}

	return weather, nil
}

type Forecast3h struct {
	Location string `json:"location"`
	Hourly   []any  `json:"hourly"` // отдаём "как есть", чтобы не закапываться в контракт
	Daily    []any  `json:"daily"`  // сгруппировано по дням приблизительно
}

type owForecastResp struct {
	City struct {
		Name string `json:"name"`
	} `json:"city"`
	List []struct {
		Dt   int64 `json:"dt"`
		Main struct {
			Temp      float64 `json:"temp"`
			FeelsLike float64 `json:"feels_like"`
			Humidity  int     `json:"humidity"`
		} `json:"main"`
		Wind struct {
			Speed float64 `json:"speed"`
		} `json:"wind"`
		Weather []struct {
			ID   int    `json:"id"`
			Main string `json:"main"`
		} `json:"weather"`
	} `json:"list"`
}

// GetWeather возвращает доменную погоду по имени города.
func (c *OpenWeatherClient) GetWeather(ctx context.Context, city string) (*domain.ExtendedWeatherData, error) {
	if c.apiKey == "" || c.baseURL == "" {
		return nil, fmt.Errorf("openweather client is not configured: empty apiKey or baseURL")
	}

	endpoint := c.baseURL + "/weather"

	// Собираем query-параметры
	q := url.Values{}
	q.Set("q", city)
	q.Set("appid", c.apiKey)
	q.Set("units", "metric")
	q.Set("lang", "ru")

	u, err := url.Parse(endpoint)
	if err != nil {
		return nil, fmt.Errorf("parse weather endpoint: %w", err)
	}
	u.RawQuery = q.Encode()

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, u.String(), nil)
	if err != nil {
		return nil, fmt.Errorf("create weather request: %w", err)
	}

	resp, err := c.http.Do(req)
	if err != nil {
		return nil, fmt.Errorf("weather api request failed: %w", err)
	}
	defer resp.Body.Close()

	body, _ := io.ReadAll(resp.Body)

	// 404 — такого города нет
	if resp.StatusCode == http.StatusNotFound {
		return nil, ErrCityNotFound
	}

	// Любой не 200 — ошибка провайдера или ключа
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("weather api error: status=%d, body=%s", resp.StatusCode, string(body))
	}

	var apiResp owmCurrentResponse
	if err := json.Unmarshal(body, &apiResp); err != nil {
		return nil, fmt.Errorf("decode weather response: %w", err)
	}

	desc := ""
	if len(apiResp.Weather) > 0 {
		if apiResp.Weather[0].Description != "" {
			desc = apiResp.Weather[0].Description
		} else {
			desc = apiResp.Weather[0].Main
		}
	}

	weather := &domain.ExtendedWeatherData{
		WeatherData: domain.WeatherData{
			Location:       apiResp.Name,
			Temperature:    apiResp.Main.Temp,
			FeelsLike:      apiResp.Main.FeelsLike,
			Weather:        desc,
			Humidity:       apiResp.Main.Humidity,
			WindSpeed:      apiResp.Wind.Speed, // m/s при units=metric
			MinTemp:        apiResp.Main.TempMin,
			MaxTemp:        apiResp.Main.TempMax,
			WillRain:       false,
			WillSnow:       false,
			HourlyForecast: []domain.WeatherHourly{},
		},
		Timestamp: time.Now().UTC(),
	}

	return weather, nil
}

func (c *OpenWeatherClient) GetForecast3h(ctx context.Context, lat, lon float64) (Forecast3h, error) {
	u := fmt.Sprintf("%s/forecast?lat=%f&lon=%f&appid=%s&units=metric&lang=ru", c.baseURL, lat, lon, c.apiKey)

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, u, nil)
	if err != nil {
		return Forecast3h{}, errors.Wrap(err, "new request")
	}

	res, err := c.http.Do(req)
	if err != nil {
		return Forecast3h{}, errors.Wrap(err, "do request")
	}
	defer res.Body.Close()

	if res.StatusCode/100 != 2 {
		return Forecast3h{}, errors.Errorf("openweather forecast bad status: %d", res.StatusCode)
	}

	var payload owForecastResp
	if err := json.NewDecoder(res.Body).Decode(&payload); err != nil {
		return Forecast3h{}, errors.Wrap(err, "decode forecast")
	}

	// hourly: список точек
	hourly := make([]any, 0, len(payload.List))
	// daily: сгруппируем по YYYY-MM-DD (упрощённо)
	dailyMap := map[string]map[string]any{}

	for _, it := range payload.List {
		wid := 0
		wm := ""
		if len(it.Weather) > 0 {
			wid = it.Weather[0].ID
			wm = it.Weather[0].Main
		}

		point := map[string]any{
			"dt":         it.Dt,
			"temp":       it.Main.Temp,
			"feels_like": it.Main.FeelsLike,
			"humidity":   it.Main.Humidity,
			"wind_speed": it.Wind.Speed,
			"weather_id": wid,
			"weather":    wm,
		}
		hourly = append(hourly, point)

		dayKey := time.Unix(it.Dt, 0).UTC().Format("2006-01-02")
		agg, ok := dailyMap[dayKey]
		if !ok {
			agg = map[string]any{
				"date":       dayKey,
				"temp_min":   it.Main.Temp,
				"temp_max":   it.Main.Temp,
				"weather":    wm,
				"weather_id": wid,
			}
			dailyMap[dayKey] = agg
		} else {
			if it.Main.Temp < agg["temp_min"].(float64) {
				agg["temp_min"] = it.Main.Temp
			}
			if it.Main.Temp > agg["temp_max"].(float64) {
				agg["temp_max"] = it.Main.Temp
			}
		}
	}

	daily := make([]any, 0, len(dailyMap))
	for _, v := range dailyMap {
		daily = append(daily, v)
	}

	return Forecast3h{
		Location: payload.City.Name,
		Hourly:   hourly,
		Daily:    daily,
	}, nil
}
