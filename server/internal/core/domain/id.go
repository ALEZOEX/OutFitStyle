package domain

import "github.com/google/uuid"

// ID is a UUID identifier across the whole system (TZ-aligned).
type ID = uuid.UUID

func NewID() ID { return uuid.New() }

func ParseID(s string) (ID, error) { return uuid.Parse(s) }

// IDToInt64 converts a domain.ID (UUID) to int64 by taking the first 8 bytes and interpreting them as int64.
// Note: This conversion is not 1:1 due to size difference (UUID=128bit vs int64=64bit) and can cause collisions.
// This should be used with caution, typically for temporary ID mapping scenarios.
func IDToInt64(id ID) int64 {
	// Get the byte representation of the UUID
	bytes := id[:]

	// Interpret first 8 bytes as a little-endian int64
	var result int64
	for i := 0; i < 8 && i < len(bytes); i++ {
		result |= int64(bytes[i]) << (i * 8)
	}
	return result
}
