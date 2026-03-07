// Пакет middleware предоставляет HTTP middleware для обработки аутентификации
// Включая установку httpOnly cookie с refresh token
package middleware

import (
	"net/http"
	"time"
)

// CookieConfig конфигурация для cookie
type CookieConfig struct {
	Name     string
	Path     string
	Domain   string
	MaxAge   int           // Время жизни в секундах
	Secure   bool          // Только HTTPS
	HttpOnly bool          // Недоступен для JavaScript
	SameSite http.SameSite // Защита от CSRF
}

// DefaultRefreshCookieConfig возвращает конфигурацию по умолчанию для refresh token cookie
func DefaultRefreshCookieConfig() CookieConfig {
	return CookieConfig{
		Name:     "refresh_token",
		Path:     "/api/v1/auth",
		Domain:   "", // Пустой = текущий домен
		MaxAge:   int((90 * 24 * time.Hour).Seconds()), // 90 дней
		Secure:   true,
		HttpOnly: true,
		SameSite: http.SameSiteStrictMode,
	}
}
// DefaultAccessCookieConfig возвращает конфигурацию по умолчанию для access token cookie
func DefaultAccessCookieConfig() CookieConfig {
	return CookieConfig{
		Name:     "access_token",
		Path:     "/",                                      // Доступен для всех API endpoints
		Domain:   "",                                       // Пустой = текущий домен
		MaxAge:   int((24 * time.Hour).Seconds()),          // 24 часа (как access token)
		Secure:   true,
		HttpOnly: true,
		SameSite: http.SameSiteStrictMode,
	}
}


// SetRefreshTokenCookie устанавливает httpOnly cookie с refresh token
// Cookie устанавливается через заголовок Set-Cookie
func SetRefreshTokenCookie(w http.ResponseWriter, refreshToken string, config CookieConfig) {
	cookie := &http.Cookie{
		Name:     config.Name,
		Value:    refreshToken,
		Path:     config.Path,
		Domain:   config.Domain,
		MaxAge:   config.MaxAge,
		Secure:   config.Secure,
		HttpOnly: config.HttpOnly,
		SameSite: config.SameSite,
	}

	http.SetCookie(w, cookie)
}
// SetAccessTokenCookie устанавливает httpOnly cookie с access token
// Cookie устанавливается через заголовок Set-Cookie
func SetAccessTokenCookie(w http.ResponseWriter, accessToken string, config CookieConfig) {
	cookie := &http.Cookie{
		Name:     config.Name,
		Value:    accessToken,
		Path:     config.Path,
		Domain:   config.Domain,
		MaxAge:   config.MaxAge,
		Secure:   config.Secure,
		HttpOnly: config.HttpOnly,
		SameSite: config.SameSite,
	}

	http.SetCookie(w, cookie)
}


// ClearRefreshTokenCookie удаляет refresh token cookie
func ClearRefreshTokenCookie(w http.ResponseWriter, config CookieConfig) {
	cookie := &http.Cookie{
		Name:     config.Name,
		Value:    "",
		Path:     config.Path,
		Domain:   config.Domain,
		MaxAge:   -1, // Удаляем cookie
		Secure:   config.Secure,
		HttpOnly: config.HttpOnly,
		SameSite: config.SameSite,
	}

	http.SetCookie(w, cookie)
}
// ClearAccessTokenCookie удаляет access token cookie
func ClearAccessTokenCookie(w http.ResponseWriter, config CookieConfig) {
	cookie := &http.Cookie{
		Name:     config.Name,
		Value:    "",
		Path:     config.Path,
		Domain:   config.Domain,
		MaxAge:   -1, // Удаляем cookie
		Secure:   config.Secure,
		HttpOnly: config.HttpOnly,
		SameSite: config.SameSite,
	}

	http.SetCookie(w, cookie)
}


// GetRefreshTokenFromCookie извлекает refresh token из cookie
func GetRefreshTokenFromCookie(r *http.Request, config CookieConfig) (string, error) {
	cookie, err := r.Cookie(config.Name)
	if err != nil {
		return "", err
	}
	return cookie.Value, nil
}

// RefreshTokenMiddleware извлекает refresh token из cookie и добавляет в context
// Если refresh token в cookie, он добавляется в request header для дальнейшей обработки
func RefreshTokenMiddleware(config CookieConfig) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			// Пробуем получить refresh token из cookie
			cookie, err := r.Cookie(config.Name)
			if err == nil && cookie.Value != "" {
				// Добавляем в header для совместимости с существующей логикой
				// Но не перезаписываем если уже есть в body
				r.Header.Set("X-Refresh-Token", cookie.Value)
			}

			next.ServeHTTP(w, r)
		})
	}
}
