package queue

import (
	"encoding/json"

	"github.com/hibiken/asynq"
	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/domain"
)

// Client представляет клиент для работы с очередью задач
// Использует библиотеку asynq для асинхронной обработки задач
type Client struct {
	c *asynq.Client // Внутренний клиент asynq для взаимодействия с Redis очередью
}

// NewClient создает новый экземпляр клиента очереди
// Принимает параметры подключения к Redis и возвращает указатель на Client
func NewClient(redisOpt asynq.RedisClientOpt) *Client {
	return &Client{c: asynq.NewClient(redisOpt)}
}

// Close закрывает соединение с очередью
// Освобождает ресурсы, связанные с клиентом очереди
func (c *Client) Close() error { return c.c.Close() }

// SendNotificationPayload представляет полезную нагрузку для задачи отправки уведомления
// Содержит идентификатор уведомления, которое нужно отправить
type SendNotificationPayload struct {
	NotificationID domain.ID `json:"notification_id"` // Идентификатор уведомления для отправки
}

// EnqueueSendNotification добавляет задачу отправки уведомления в очередь
// Принимает идентификатор уведомления и помещает его в очередь с названием "push" с максимальным количеством повторов 10
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
