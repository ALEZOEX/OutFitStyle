package pg

import (
	"context"

	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/application/repositories"
	dbpkg "outfitstyle/server/internal/infrastructure/persistence/postgres"
)

type AuditRepository struct {
	db *dbpkg.DB
}

func NewAuditRepository(db *dbpkg.DB) repositories.AuditRepository {
	return &AuditRepository{db: db}
}

func (r *AuditRepository) Create(ctx context.Context, a repositories.AuditCreate) error {
	_, err := r.db.Pool().Exec(ctx, `
INSERT INTO audit_logs (
user_id,
action,
resource_type,
resource_id,
old_value,
new_value,
ip_address,
user_agent,
success,
error_message
)
VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
`, a.UserID, a.Action, a.ResourceType, a.ResourceID, nullJSON(a.OldValue), nullJSON(a.NewValue), a.IPAddress, a.UserAgent, a.Success, a.ErrorMessage)
	return errors.Wrap(err, "insert audit_log")
}