package services

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"
	"outfitstyle/server/api/models"
	"time"
)

type HourlyWeather struct {
	Time            string  `json:"time"`
	Temperature     float64 `json:"temperature"`
	Weather         string  `json:"weather"`
	RainProbability float64 `json:"rain_probability"`
}

type ExtendedWeatherData struct {
	models.WeatherData
	MinTemp        float64         `json:"min_temp"`
	MaxTemp        float64         `json:"max_temp"`
	HourlyForecast []HourlyWeather `json:"hourly_forecast,omitempty"`
	WillRain       bool            `json:"will_rain"`
	WillSnow       bool            `json:"will_snow"`
}

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

func (s *WeatherService) GetWeather(city string) (*ExtendedWeatherData, error) {
	if s.apiKey == "" {
		return nil, fmt.Errorf("WEATHER_API_KEY is not set")
	}

	// 1. Получаем текущую погоду
	currentWeather, err := s.getCurrentWeather(city)
	if err != nil {
		log.Printf("❌ Failed to get current weather: %v", err)
		return nil, fmt.Errorf("could not retrieve current weather: %w", err)
	}
	
	log.Printf("✅ Got current weather for %s", city)

	// 2. Получаем прогноз
	forecast, err := s.getForecast(city)
	if err != nil {
		log.Printf("⚠️ Failed to get forecast, using current weather only: %v", err)
		// Возвращаем только текущую погоду, если прогноз недоступен
		return currentWeather, nil
	}
	
	log.Printf("✅ Got forecast for %s", city)

	// 3. Объединяем данные
	currentWeather.HourlyForecast = forecast.HourlyForecast
	currentWeather.MinTemp = forecast.MinTemp
	currentWeather.MaxTemp = forecast.MaxTemp
	currentWeather.WillRain = forecast.WillRain
	currentWeather.WillSnow = forecast.WillSnow

	return currentWeather, nil
}

func (s *WeatherService) getCurrentWeather(city string) (*ExtendedWeatherData, error) {
	params := url.Values{}
	params.Add("q", city)
	params.Add("appid", s.apiKey)
	params.Add("units", "metric")
	params.Add("lang", "ru")

	requestURL := fmt.Sprintf("%s?%s", s.baseURL, params.Encode())
	log.Printf("Fetching current weather from: %s", requestURL)

	client := &http.Client{Timeout: s.timeout}
	resp, err := client.Get(requestURL)
	if err != nil {
		return nil, fmt.Errorf("request error: %w", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response body: %w", err)
	}

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("API returned status %d: %s", resp.StatusCode, string(body))
	}

	var apiResp struct {
		Name string `json:"name"`
		Main struct {
			Temp      float64 `json:"temp"`
			FeelsLike float64 `json:"feels_like"`
			Humidity  int     `json:"humidity"`
		} `json:"main"`
		Weather []struct {
			Main        string `json:"main"`
			Description string `json:"description"`
		} `json:"weather"`
		Wind struct {
			Speed float64 `json:"speed"`
		} `json:"wind"`
	}

	if err := json.Unmarshal(body, &apiResp); err != nil {
		return nil, fmt.Errorf("failed to parse response: %w", err)
	}

	weather := "Ясно"
	if len(apiResp.Weather) > 0 {
		weather = translateWeather(apiResp.Weather[0].Main)
	}

	return &ExtendedWeatherData{
		WeatherData: models.WeatherData{
			Location:    apiResp.Name,
			Temperature: apiResp.Main.Temp,
			FeelsLike:   apiResp.Main.FeelsLike,
			Weather:     weather,
			Humidity:    apiResp.Main.Humidity,
			WindSpeed:   apiResp.Wind.Speed,
		},
	}, nil
}

func (s *WeatherService) getForecast(city string) (*ExtendedWeatherData, error) {
	forecastURL := "https://api.openweathermap.org/data/2.5/forecast"
	
	params := url.Values{}
	params.Add("q", city)
	params.Add("appid", s.apiKey)
	params.Add("units", "metric")
	params.Add("lang", "ru")
	params.Add("cnt", "8") // 8 * 3-hour intervals = 24 hours

	requestURL := fmt.Sprintf("%s?%s", forecastURL, params.Encode())
	log.Printf("Fetching forecast from: %s", requestURL)

	client := &http.Client{Timeout: s.timeout}
	resp, err := client.Get(requestURL)
	if err != nil {
		return nil, fmt.Errorf("forecast request error: %w", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read forecast response: %w", err)
	}

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("forecast API returned status %d: %s", resp.StatusCode, string(body))
	}

	var forecastResponse struct {
		List []struct {
			Dt   int64 `json:"dt"`
			Main struct {
				TempMin float64 `json:"temp_min"`
				TempMax float64 `json:"temp_max"`
				Temp    float64 `json:"temp"`
			} `json:"main"`
			Weather []struct {
				Main        string `json:"main"`
				Description string `json:"description"`
			} `json:"weather"`
			Pop float64 `json:"pop"`
		} `json:"list"`
	}

	if err := json.Unmarshal(body, &forecastResponse); err != nil {
		return nil, fmt.Errorf("failed to parse forecast: %w", err)
	}
	
	if len(forecastResponse.List) == 0 {
		return nil, fmt.Errorf("forecast list is empty")
	}

	var hourlyForecast []HourlyWeather
	minTemp, maxTemp := forecastResponse.List[0].Main.TempMin, forecastResponse.List[0].Main.TempMax
	willRain := false
	willSnow := false

	for _, item := range forecastResponse.List {
		if item.Main.TempMin < minTemp {
			minTemp = item.Main.TempMin
		}
		if item.Main.TempMax > maxTemp {
			maxTemp = item.Main.TempMax
		}

		if len(item.Weather) > 0 {
			weatherMain := item.Weather[0].Main
			if weatherMain == "Rain" || weatherMain == "Drizzle" {
				willRain = true
			}
			if weatherMain == "Snow" {
				willSnow = true
			}
			hourlyForecast = append(hourlyForecast, HourlyWeather{
				Time:            time.Unix(item.Dt, 0).Format("15:04"),
				Temperature:     item.Main.Temp,
				Weather:         item.Weather[0].Description,
				RainProbability: item.Pop * 100,
			})
		}
	}

	return &ExtendedWeatherData{
		MinTemp:        minTemp,
		MaxTemp:        maxTemp,
		HourlyForecast: hourlyForecast,
		WillRain:       willRain,
		WillSnow:       willSnow,
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