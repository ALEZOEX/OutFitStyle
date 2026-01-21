package tasks

import (
	"encoding/json"

	"github.com/hibiken/asynq"
)

const TypeMLAction = "ml:action"

type MLActionPayload struct {
	RequestID  string                 `json:"request_id"`
	UserID     string                 `json:"user_id"`
	ActionType string                 `json:"action_type"` // click/add_to_outfit/wear/purchase/like
	EntityType string                 `json:"entity_type"` // item/outfit
	EntityID   string                 `json:"entity_id"`   // clothing_item_id или external_id
	Meta       map[string]any         `json:"meta,omitempty"`
}

func NewMLActionTask(p MLActionPayload) (*asynq.Task, error) {
	b, err := json.Marshal(p)
	if err != nil {
		return nil, err
	}
	return asynq.NewTask(TypeMLAction, b), nil
}