package domain

import "time"

// APIKey структура для представления API-ключа
type APIKey struct {
	ID ID `json:"id"` // Уникальный идентификатор API-ключа

	ClientID ID `json:"client_id"` // Идентификатор владельца ключа (партнер)

	KeyPrefix   string  `json:"key_prefix"`            // Префикс ключа для идентификации
	Name        *string `json:"name,omitempty"`        // Название ключа (опционально)
	Description *string `json:"description,omitempty"` // Описание ключа (опционально)

	Permissions []string `json:"permissions,omitempty"` // Разрешения, связанные с ключом

	// Лимиты на уровне клиента, а не ключа
	RateLimitPerMinute int `json:"rate_limit_per_minute"` // Ограничение запросов в минуту
	RateLimitPerDay    int `json:"rate_limit_per_day"`    // Ограничение запросов в день

	IsActive bool `json:"is_active"` // Активен ли ключ

	LastUsedAt *time.Time `json:"last_used_at,omitempty"` // Время последнего использования
	ExpiresAt  *time.Time `json:"expires_at,omitempty"`  // Время истечения срока действия

	CreatedAt time.Time `json:"created_at"` // Время создания
	UpdatedAt time.Time `json:"updated_at"` // Время последнего обновления

	// Добавляем поле для хэша ключа
	KeyHash []byte `json:"-"` // Хеш ключа (не передается в JSON, так как это чувствительная информация)
}

// APIKeyCreateRequest структура запроса на создание API-ключа
type APIKeyCreateRequest struct {
	Name        *string  `json:"name,omitempty"`        // Название ключа (опционально)
	Description *string  `json:"description,omitempty"` // Описание ключа (опционально)
	Permissions []string `json:"permissions,omitempty"` // Разрешения для ключа
	ClientID    ID       `json:"client_id"`             // Идентификатор владельца ключа
}

// APIKeyCreateResponse структура ответа на создание API-ключа
type APIKeyCreateResponse struct {
	APIKey APIKey `json:"api_key"` // Созданный API-ключ
	Token  string `json:"token"`   // Сам токен ключа (обычно возвращается только при создании)
}

// APIKeyListResponse структура ответа на запрос списка API-ключей
type APIKeyListResponse struct {
	Keys []APIKey `json:"keys"` // Список API-ключей
}
