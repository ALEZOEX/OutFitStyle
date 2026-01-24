package domain

import "time"

// AuditEvent структура для хранения информации об аудитных событиях
type AuditEvent struct {
	ID          ID        `json:"id"`                    // Уникальный идентификатор аудитного события
	Action      string    `json:"action"`                // Действие, которое было выполнено (например, "user_update", "item_create")
	EntityID    string    `json:"entity_id"`             // Идентификатор сущности, над которой было выполнено действие
	EntityType  string    `json:"entity_type"`           // Тип сущности (например, "user", "clothing_item", "recommendation")
	UserID      *ID       `json:"user_id,omitempty"`     // Идентификатор пользователя, инициировавшего действие (если применимо)
	IPAddress   string    `json:"ip_address"`            // IP-адрес, с которого было выполнено действие
	UserAgent   string    `json:"user_agent"`            // User-Agent браузера или приложения
	OldValues   any       `json:"old_values"`            // Значения полей до изменения (для операций обновления)
	NewValues   any       `json:"new_values"`            // Значения полей после изменения (для операций обновления)
	CreatedAt   time.Time `json:"created_at"`            // Время создания аудитной записи
}