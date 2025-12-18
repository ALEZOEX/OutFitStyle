package observability

import (
	"time"

	"github.com/getsentry/sentry-go"
	"github.com/pkg/errors"
)

type SentryConfig struct {
	DSN         string
	Environment string
	Release     string
}

func InitSentry(cfg SentryConfig) error {
	if cfg.DSN == "" {
		return nil
	}
	if err := sentry.Init(sentry.ClientOptions{
		Dsn:         cfg.DSN,
		Environment: cfg.Environment,
		Release:     cfg.Release,
	}); err != nil {
		return errors.Wrap(err, "sentry init")
	}
	return nil
}

func Flush(timeout time.Duration) {
	if timeout <= 0 {
		timeout = 2 * time.Second
	}
	sentry.Flush(timeout)
}

func CapturePanic(v any) {
	sentry.CurrentHub().Recover(v)
}