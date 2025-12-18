package middleware

import (
	"outfitstyle/server/internal/core/domain"
)

// Re-export domain context functions to maintain API compatibility
var (
	WithUserID = domain.WithUserID
	GetUserIDFromContext = domain.GetUserIDFromContext
	WithSessionID = domain.WithSessionID
	GetSessionIDFromContext = domain.GetSessionIDFromContext
	WithAPIKeyID = domain.WithAPIKeyID
	GetAPIKeyIDFromContext = domain.GetAPIKeyIDFromContext
	WithABVariant = domain.WithABVariant
	GetABVariantFromContext = domain.GetABVariantFromContext
)