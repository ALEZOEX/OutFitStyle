// Пакет queue предоставляет функциональность для работы с очередью задач
// Использует библиотеку asynq для асинхронной обработки задач через Redis
package queue

const (
	// TaskSendNotification константа для задачи отправки уведомления
	TaskSendNotification = "push:send_notification"
)
