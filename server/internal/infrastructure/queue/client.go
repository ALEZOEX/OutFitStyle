package queue

import (
	"encoding/json"

	"github.com/hibiken/asynq"
	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/domain"
)

type Client struct {
	c *asynq.Client
}

func NewClient(redisOpt asynq.RedisClientOpt) *Client {
	return &Client{c: asynq.NewClient(redisOpt)}
}

func (c *Client) Close() error { return c.c.Close() }

type SendNotificationPayload struct {
	NotificationID domain.ID `json:"notification_id"`
}

func (c *Client) EnqueueSendNotification(notificationID domain.ID) error {
	p := SendNotificationPayload{NotificationID: notificationID}
	b, err := json.Marshal(p)
	if err != nil {
		return errors.Wrap(err, "marshal payload")
	}
	task := asynq.NewTask(TaskSendNotification, b)
	_, err = c.c.Enqueue(task, asynq.Queue("push"), asynq.MaxRetry(10))
	return errors.Wrap(err, "enqueue task")
}
