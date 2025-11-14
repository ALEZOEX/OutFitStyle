package services

import (
	"encoding/json"
	"fmt"
	"net/http"
	"outfitstyle/server/api/models"
	"time"
)

type WeatherService struct {
	apiKey  string
	baseURL string
	timeout time.Duration
}

func NewWeatherService(apiKey, baseURL string, timeout int) *WeatherService {
	return &WeatherService{
		apiKey:  apiKey,
		baseURL: baseURL,
		timeout: time.Duration(timeout) * time.Second,
	}
}

func (s *WeatherService) GetWeather(city string) (*models.WeatherData, error) {
	url := fmt.Sprintf("%s?q=%s&appid=%s&units=metric&lang=ru", s.baseURL, city, s.apiKey)

	client := &http.Client{Timeout: s.timeout}
	resp, err := client.Get(url)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("weather API returned status %d", resp.StatusCode)
	}

	var apiResp struct {
		Name string `json:"name"`
		Main struct {
			Temp      float64 `json:"temp"`
			FeelsLike float64 `json:"feels_like"`
			Humidity  int     `json:"humidity"`
		} `json:"main"`
		Weather []struct {
			Main string `json:"main"`
		} `json:"weather"`
		Wind struct {
			Speed float64 `json:"speed"`
		} `json:"wind"`
	}

	if err := json.NewDecoder(resp.Body).Decode(&apiResp); err != nil {
		return nil, err
	}

	weather := "Ясно"
	if len(apiResp.Weather) > 0 {
		weather = translateWeather(apiResp.Weather[0].Main)
	}

	return &models.WeatherData{
		Location:    apiResp.Name,
		Temperature: apiResp.Main.Temp,
		FeelsLike:   apiResp.Main.FeelsLike,
		Weather:     weather,
		Humidity:    apiResp.Main.Humidity,
		WindSpeed:   apiResp.Wind.Speed,
	}, nil
}

func translateWeather(condition string) string {
	translations := map[string]string{
		"Clear":        "Ясно",
		"Clouds":       "Облачно",
		"Rain":         "Дождь",
		"Drizzle":      "Морось",
		"Thunderstorm": "Гроза",
		"Snow":         "Снег",
		"Mist":         "Туман",
	}
	if translated, ok := translations[condition]; ok {
		return translated
	}
	return condition
}