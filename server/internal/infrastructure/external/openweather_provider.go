package external

import (
	"context"

	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/domain"
)

type OpenWeatherProvider struct {
	client *OpenWeatherClient
}

func NewOpenWeatherProvider(client *OpenWeatherClient) *OpenWeatherProvider {
	return &OpenWeatherProvider{client: client}
}

func (p *OpenWeatherProvider) Current(ctx context.Context, lat, lon float64) (domain.WeatherSnapshot, error) {
	return p.client.GetCurrent(ctx, lat, lon)
}

func (p *OpenWeatherProvider) Forecast(ctx context.Context, lat, lon float64, days int) (string, []any, []any, error) {
	fc, err := p.client.GetForecast3h(ctx, lat, lon)
	if err != nil {
		return "", nil, nil, errors.Wrap(err, "openweather forecast")
	}
	return fc.Location, fc.Daily, fc.Hourly, nil
}