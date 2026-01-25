// Пакет pg содержит реализацию репозиториев для работы с PostgreSQL
// Реализует интерфейсы репозиториев с использованием библиотеки pgx
package pg

import (
	"context"
	"encoding/json"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/pkg/errors"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

// AuditRepository репозиторий для работы с аудитными логами
type AuditRepository struct {
	db     *pgxpool.Pool // Пул подключений к базе данных PostgreSQL
	logger *zap.Logger   // Логгер для записи событий
}

// NewAuditRepository создает новый экземпляр репозитория аудита
func NewAuditRepository(db *pgxpool.Pool) repositories.AuditRepository {
	return &AuditRepository{db: db, logger: zap.NewNop()}
}

// Create создает новую запись аудита
func (r *AuditRepository) Create(ctx context.Context, a repositories.AuditCreate) error {
	query := `
		INSERT INTO audit_log (
			id, action, entity_id, entity_type, user_id, ip_address, user_agent,
			old_values, new_values, created_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
	`

	// Convert values to JSON
	var oldValuesJSON, newValuesJSON []byte
	var err error

	if a.OldValues != nil {
		oldValuesJSON, err = json.Marshal(a.OldValues)
		if err != nil {
			return errors.Wrap(err, "failed to marshal old values")
		}
	}

	if a.NewValues != nil {
		newValuesJSON, err = json.Marshal(a.NewValues)
		if err != nil {
			return errors.Wrap(err, "failed to marshal new values")
		}
	}

	// Convert user ID to domain.ID
	var userID *uuid.UUID
	if a.UserID != nil {
		uid := uuid.UUID(*a.UserID)
		userID = &uid
	}

	id := uuid.New()
	createdAt := time.Now()

	_, err = r.db.Exec(ctx, query,
		id,
		a.Action,
		a.EntityID,
		a.EntityType,
		userID,
		a.IPAddress,
		a.UserAgent,
		oldValuesJSON,
		newValuesJSON,
		createdAt,
	)

	if err != nil {
		return errors.Wrap(err, "failed to insert audit log entry")
	}

	return nil
}

// GetByEntity returns audit events for a specific entity
func (r *AuditRepository) GetByEntity(ctx context.Context, entityID string, entityType string) ([]domain.AuditEvent, error) {
	query := `
		SELECT
			id, action, entity_id, entity_type, user_id, ip_address, user_agent,
			old_values, new_values, created_at
		FROM audit_log
		WHERE entity_id = $1 AND entity_type = $2
		ORDER BY created_at DESC
	`

	rows, err := r.db.Query(ctx, query, entityID, entityType)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query audit log by entity")
	}
	defer rows.Close()

	var events []domain.AuditEvent
	for rows.Next() {
		var event domain.AuditEvent
		var userID *uuid.UUID
		var oldValues, newValues []byte
		var createdAt time.Time

		err := rows.Scan(
			&event.ID,
			&event.Action,
			&event.EntityID,
			&event.EntityType,
			&userID,
			&event.IPAddress,
			&event.UserAgent,
			&oldValues,
			&newValues,
			&createdAt,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan audit event")
		}

		// Convert user ID back to domain.ID
		if userID != nil {
			uid := domain.ID(*userID)
			event.UserID = &uid
		}

		event.OldValues = oldValues
		event.NewValues = newValues
		event.CreatedAt = createdAt

		events = append(events, event)
	}

	return events, nil
}

// GetByUser returns audit events for a specific user
func (r *AuditRepository) GetByUser(ctx context.Context, userID domain.ID) ([]domain.AuditEvent, error) {
	query := `
		SELECT
			id, action, entity_id, entity_type, user_id, ip_address, user_agent,
			old_values, new_values, created_at
		FROM audit_log
		WHERE user_id = $1
		ORDER BY created_at DESC
	`

	rows, err := r.db.Query(ctx, query, uuid.UUID(userID))
	if err != nil {
		return nil, errors.Wrap(err, "failed to query audit log by user")
	}
	defer rows.Close()

	var events []domain.AuditEvent
	for rows.Next() {
		var event domain.AuditEvent
		var userIDPtr *uuid.UUID
		var oldValues, newValues []byte
		var createdAt time.Time

		err := rows.Scan(
			&event.ID,
			&event.Action,
			&event.EntityID,
			&event.EntityType,
			&userIDPtr,
			&event.IPAddress,
			&event.UserAgent,
			&oldValues,
			&newValues,
			&createdAt,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan audit event")
		}

		// Convert user ID back to domain.ID
		if userIDPtr != nil {
			uid := domain.ID(*userIDPtr)
			event.UserID = &uid
		}

		event.OldValues = oldValues
		event.NewValues = newValues
		event.CreatedAt = createdAt

		events = append(events, event)
	}

	return events, nil
}
