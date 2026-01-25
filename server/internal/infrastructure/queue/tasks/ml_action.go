// Пакет tasks содержит определения задач для очереди
// Определяет структуры полезной нагрузки и создание задач для различных типов действий
package tasks

import (
	"encoding/json"

	"github.com/hibiken/asynq"
)

// TypeMLAction константа типа задачи для ML-действий
const TypeMLAction = "ml:action"

// MLActionPayload структура полезной нагрузки для задачи ML-действия
// Содержит информацию о действии пользователя, которое нужно обработать ML-сервисом
type MLActionPayload struct {
	RequestID  string         `json:"request_id"`     // Идентификатор запроса для трассировки
	UserID     string         `json:"user_id"`        // Идентификатор пользователя
	ActionType string         `json:"action_type"`    // Тип действия: click/add_to_outfit/wear/purchase/like
	EntityType string         `json:"entity_type"`    // Тип сущности: item/outfit
	EntityID   string         `json:"entity_id"`      // Идентификатор сущности: clothing_item_id или external_id
	Meta       map[string]any `json:"meta,omitempty"` // Дополнительные метаданные действия
}

// NewMLActionTask создает новую задачу для ML-действия
// Принимает полезную нагрузку и возвращает задачу asynq
func NewMLActionTask(p MLActionPayload) (*asynq.Task, error) {
	b, err := json.Marshal(p)
	if err != nil {
		return nil, err
	}
	return asynq.NewTask(TypeMLAction, b), nil
}
