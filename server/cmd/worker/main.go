package main

import (
	"context"
	"log"
	"os"
	"time"

	"github.com/hibiken/asynq"
	"go.uber.org/zap"

	"outfitstyle/server/internal/config"
	"outfitstyle/server/internal/infrastructure/external"
	dbpg "outfitstyle/server/internal/infrastructure/persistence/postgres"
	pg "outfitstyle/server/internal/infrastructure/persistence/postgres/pg"
	"outfitstyle/server/internal/infrastructure/queue"
)

func main() {
	logger, err := setupLogger()
	if err != nil {
		log.Fatalf("logger init failed: %v", err)
	}
	defer logger.Sync()

	cfg, err := config.Load()
	if err != nil {
		logger.Fatal("config load failed", zap.Error(err))
	}

	db, err := dbpg.NewDB(cfg.Database.DatabaseURL(), logger)
	if err != nil {
		logger.Fatal("db connect failed", zap.Error(err))
	}
	defer db.Close()

	// repos
	notifRepo := pg.NewNotificationRepository(db)
	tokenRepo := pg.NewPushTokenRepository(db)

	// push clients (optional)
	var fcm *external.FCMClient
	{
		c, err := external.NewFCMClient(context.Background(), cfg.Push.FCMCredentialsFile)
		if err != nil {
			logger.Warn("FCM disabled", zap.Error(err))
		} else {
			fcm = c
			logger.Info("FCM enabled")
		}
	}

	var apns *external.APNSClient
	{
		c, err := external.NewAPNSClient(cfg.Push.APNSKeyFile, cfg.Push.APNSKeyID, cfg.Push.APNSTeamID, cfg.Push.APNSBundleID, cfg.Push.APNSEnvironment)
		if err != nil {
			logger.Warn("APNs disabled", zap.Error(err))
		} else {
			apns = c
			logger.Info("APNs enabled", zap.String("env", cfg.Push.APNSEnvironment))
		}
	}

	pushMux := &external.PushMux{FCM: fcm, APNS: apns}

	redisOpt, err := queue.ParseRedisURLToAsynqOpt(cfg.Queue.RedisURL)
	if err != nil {
		logger.Fatal("parse redis url failed", zap.Error(err))
	}

	srv := asynq.NewServer(redisOpt, asynq.Config{
		Concurrency: 10,
		Queues: map[string]int{
			"push": 10,
		},
		ShutdownTimeout: 20 * time.Second,
	})

	mux := queue.NewMux(queue.WorkerDeps{
		Logger:    logger,
		NotifRepo: notifRepo,
		TokenRepo: tokenRepo,
		Push:      pushMux,
	})

	logger.Info("worker started")
	if err := srv.Run(mux); err != nil {
		logger.Fatal("worker run failed", zap.Error(err))
	}
}

func setupLogger() (*zap.Logger, error) {
	var cfg zap.Config
	if os.Getenv("ENVIRONMENT") == "production" {
		cfg = zap.NewProductionConfig()
	} else {
		cfg = zap.NewDevelopmentConfig()
	}
	return cfg.Build()
}
