package middleware

import (
	"encoding/json"
	"net"
	"net/http"
	"strings"
	"time"

	"github.com/gorilla/mux"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

type auditRW struct {
	http.ResponseWriter
	status int
}

func (w *auditRW) WriteHeader(code int) {
	w.status = code
	w.ResponseWriter.WriteHeader(code)
}

func AuditMiddleware(repo repositories.AuditRepository, logger *zap.Logger) mux.MiddlewareFunc {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			if repo == nil {
				next.ServeHTTP(w, r)
				return
			}

			// Создаем и добавляем AuditEnvelope в контекст
			env := &AuditEnvelope{}
			ctx := WithAuditEnvelope(r.Context(), env)
			r = r.WithContext(ctx)

			arw := &auditRW{ResponseWriter: w, status: http.StatusOK}
			start := time.Now()

			next.ServeHTTP(arw, r)

			// best-effort: не ломаем ответ, если аудит не записался
			userID, hasUser := GetUserIDFromContext(r.Context())
			var uid *domain.ID
			if hasUser {
				uid = &userID
			}

			action := r.Method + " " + pathTemplateOrPath(r)

			// Используем AuditEnvelope для получения данных
			env = AuditFromContext(r.Context())
			var resTypePtr *string
			var resIDPtr *domain.ID
			var oldJSON []byte
			var newJSON []byte

			if env != nil {
				if env.ResourceType != "" {
					resTypePtr = &env.ResourceType
				}
				if env.ResourceID != nil {
					resIDPtr = env.ResourceID
				}
				oldJSON = env.OldJSON
				newJSON = env.NewJSON
			}

			// Если newJSON не задан — оставляем метаданные как раньше
			if len(newJSON) == 0 {
				newJSON, _ = json.Marshal(map[string]interface{}{
					"path":        r.URL.Path,
					"status":      arw.status,
					"duration_ms": time.Since(start).Milliseconds(),
				})
			}

			ip := extractIP(r.RemoteAddr)
			ua := r.UserAgent()
			var uaPtr *string
			if ua != "" {
				uaPtr = &ua
			}

			success := arw.status < 400
			var errMsg *string
			if !success {
				msg := http.StatusText(arw.status)
				if msg == "" {
					msg = "request failed"
				}
				errMsg = &msg
			}

			if err := repo.Create(r.Context(), repositories.AuditCreate{
				UserID: uid,

				Action:       action,
				ResourceType: resTypePtr,
				ResourceID:   resIDPtr,

				OldValues: oldJSON,
				NewValues: newJSON,

				IPAddress: ip,
				UserAgent: uaPtr,

				Success:      success,
				ErrorMessage: errMsg,
			}); err != nil {
				logger.Debug("audit insert failed", zap.Error(err))
			}
		})
	}
}

func pathTemplateOrPath(r *http.Request) string {
	if rt := mux.CurrentRoute(r); rt != nil {
		if tpl, err := rt.GetPathTemplate(); err == nil && tpl != "" {
			return tpl
		}
	}
	return r.URL.Path
}

func resourceTypeFromPath(p string) string {
	// /api/v1/{resource}/...
	p = strings.TrimPrefix(p, "/")
	parts := strings.Split(p, "/")
	if len(parts) >= 3 && parts[0] == "api" && parts[1] == "v1" {
		return parts[2]
	}
	if len(parts) > 0 {
		return parts[0]
	}
	return ""
}

func extractFirstUUIDFromVars(vars map[string]string) *domain.ID {
	for _, v := range vars {
		id, err := domain.ParseID(v)
		if err == nil {
			return &id
		}
	}
	return nil
}

func extractIP(remoteAddr string) *string {
	if remoteAddr == "" {
		return nil
	}
	host, _, err := net.SplitHostPort(remoteAddr)
	if err != nil {
		host = remoteAddr
	}
	host = strings.TrimSpace(host)
	if host == "" {
		return nil
	}
	return &host
}
