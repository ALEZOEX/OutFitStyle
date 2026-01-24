package pg

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

// APIKeyRepository represents the API key repository
type APIKeyRepository struct {
	db *pgxpool.Pool
}

// NewAPIKeyRepository creates a new API key repository
func NewAPIKeyRepository(db *pgxpool.Pool) *APIKeyRepository {
	return &APIKeyRepository{db: db}
}

// GetForAuthByPrefix retrieves the API key record for authentication purposes
func (r *APIKeyRepository) GetForAuthByPrefix(ctx context.Context, prefix string) (*repositories.APIKeyAuthRecord, error) {
	query := `
		SELECT
			ak.id AS api_key_id,
			ic.id AS client_id,
			ak.key_hash,
			COALESCE(ak.permissions, '[]'::jsonb) AS permissions,
			ak.is_active AS api_key_is_active,
			ak.expires_at AS api_key_expires_at,
			ic.is_active AS client_is_active,
			ic.rate_limit_per_minute,
			ic.rate_limit_per_day
		FROM api_keys ak
		JOIN integration_clients ic ON ic.id = ak.client_id
		WHERE ak.key_prefix = $1
		  AND ak.is_active = true
		  AND ic.is_active = true
		  AND (ak.expires_at IS NULL OR ak.expires_at > NOW())
		LIMIT 1;
	`

	var rec repositories.APIKeyAuthRecord
	var permissionsBytes []byte
	var apiKeyActive bool
	var clientActive bool

	row := r.db.QueryRow(ctx, query, prefix)
	err := row.Scan(
		&rec.APIKeyID,
		&rec.ClientID,
		&rec.KeyHash,
		&permissionsBytes,
		&apiKeyActive,
		&rec.ExpiresAt,
		&clientActive,
		&rec.RateLimitPerMinute,
		&rec.RateLimitPerDay,
	)

	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil // No key found
		}
		return nil, errors.Wrap(err, "failed to get API key by prefix")
	}

	// IsActive is true only if both api key and client are active
	rec.IsActive = apiKeyActive && clientActive

	// Parse permissions from JSONB
	if len(permissionsBytes) > 0 {
		var perms []string
		if err := json.Unmarshal(permissionsBytes, &perms); err != nil {
			return nil, errors.Wrap(err, "failed to parse permissions")
		}
		rec.Permissions = perms
	}

	return &rec, nil
}

// TouchLastUsed updates the last used timestamp for an API key
func (r *APIKeyRepository) TouchLastUsed(ctx context.Context, apiKeyID domain.ID, at time.Time) error {
	query := `
		UPDATE api_keys
		SET last_used_at = $1
		WHERE id = $2;
	`

	tag, err := r.db.Exec(ctx, query, at, apiKeyID)
	if err != nil {
		return errors.Wrap(err, "failed to update last used timestamp")
	}

	if tag.RowsAffected() == 0 {
		return fmt.Errorf("no API key found with id %s", apiKeyID)
	}

	return nil
}

// Create creates a new API key
func (r *APIKeyRepository) Create(ctx context.Context, rec repositories.APIKeyCreateRecord) (domain.ID, error) {
	query := `
		INSERT INTO api_keys (
			client_id, key_prefix, key_hash, name, description,
			permissions, is_active, expires_at, created_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
		RETURNING id;
	`

	permissionsJSON, err := json.Marshal(rec.Permissions)
	if err != nil {
		return domain.ID{}, errors.Wrap(err, "failed to marshal permissions")
	}

	var id domain.ID
	err = r.db.QueryRow(ctx, query,
		rec.ClientID,
		rec.KeyPrefix,
		rec.KeyHash,
		rec.Name,
		rec.Description,
		permissionsJSON,
		rec.IsActive,
		rec.ExpiresAt,
		time.Now(),
	).Scan(&id)

	if err != nil {
		return domain.ID{}, errors.Wrap(err, "failed to create API key")
	}

	return id, nil
}

// ListByClient returns API keys for a specific client
func (r *APIKeyRepository) ListByClient(ctx context.Context, clientID domain.ID) ([]repositories.APIKeyRecord, error) {
	query := `
		SELECT
			id, client_id, key_prefix, name, description,
			permissions, is_active, last_used_at, expires_at, created_at
		FROM api_keys
		WHERE client_id = $1
		ORDER BY created_at DESC;
	`

	rows, err := r.db.Query(ctx, query, clientID)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query API keys")
	}
	defer rows.Close()

	var apiKeys []repositories.APIKeyRecord
	for rows.Next() {
		var apiKey repositories.APIKeyRecord
		var permissionsBytes []byte

		err := rows.Scan(
			&apiKey.ID,
			&apiKey.ClientID,
			&apiKey.KeyPrefix,
			&apiKey.Name,
			&apiKey.Description,
			&permissionsBytes,
			&apiKey.IsActive,
			&apiKey.LastUsedAt,
			&apiKey.ExpiresAt,
			&apiKey.CreatedAt,
		)

		if err != nil {
			return nil, errors.Wrap(err, "failed to scan API key")
		}

		// Parse permissions from JSONB
		if len(permissionsBytes) > 0 {
			var perms []string
			if err := json.Unmarshal(permissionsBytes, &perms); err != nil {
				return nil, errors.Wrap(err, "failed to parse permissions")
			}
			apiKey.Permissions = perms
		}

		apiKeys = append(apiKeys, apiKey)
	}

	return apiKeys, nil
}

// Deactivate sets an API key as inactive
func (r *APIKeyRepository) Deactivate(ctx context.Context, clientID domain.ID, apiKeyID domain.ID) error {
	query := `
		UPDATE api_keys
		SET is_active = false, updated_at = NOW()
		WHERE id = $1 AND client_id = $2;
	`

	tag, err := r.db.Exec(ctx, query, apiKeyID, clientID)
	if err != nil {
		return errors.Wrap(err, "failed to deactivate API key")
	}

	if tag.RowsAffected() == 0 {
		return fmt.Errorf("no API key found with id %s for client %s", apiKeyID, clientID)
	}

	return nil
}