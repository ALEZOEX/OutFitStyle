package domain

// WeatherSnapshot — минимум, что нужно для рекомендаций.
type WeatherSnapshot struct {
	Location    string  `json:"location"`
	Temperature float64 `json:"temperature"`
	FeelsLike   float64 `json:"feels_like"`
	Humidity    int     `json:"humidity"`
	WindSpeed   float64 `json:"wind_speed"`
	WeatherCode string  `json:"weather_code"`
	WeatherMain string  `json:"weather_main"`
}