// Пакет sanitization предоставляет функции для санитизации входных данных
// Защита от XSS (Cross-Site Scripting) и injection атак
package sanitization

import (
	"html"
	"regexp"
	"strings"
)

// Регулярные выражения для опасных паттернов
var (
	// Script теги и их вариации
	scriptRegex = regexp.MustCompile(`(?i)<\s*script[^>]*>.*?<\s*/\s*script\s*>`)
	
	// Event handlers (onclick, onerror, onload и т.д.)
	eventHandlerRegex = regexp.MustCompile(`(?i)\s+on\w+\s*=\s*["'][^"']*["']`)
	
	// JavaScript URI
	javascriptURIRegex = regexp.MustCompile(`(?i)javascript\s*:`)
	
	// Data URI с потенциально опасным контентом
	dataURIRegex = regexp.MustCompile(`(?i)data\s*:\s*text/html`)
	
	// HTML теги (для полной очистки)
	htmlTagsRegex = regexp.MustCompile(`<[^>]*>`)
)

// SanitizeString очищает строку от потенциально опасных HTML/JS вставок
// Возвращает безопасную строку
func SanitizeString(input string) string {
	if input == "" {
		return ""
	}
	
	// 1. Удаляем script теги
	sanitized := scriptRegex.ReplaceAllString(input, "")
	
	// 2. Удаляем event handlers
	sanitized = eventHandlerRegex.ReplaceAllString(sanitized, "")
	
	// 3. Удаляем javascript: URI
	sanitized = javascriptURIRegex.ReplaceAllString(sanitized, "")
	
	// 4. Удаляем опасные data: URI
	sanitized = dataURIRegex.ReplaceAllString(sanitized, "")
	
	// 5. HTML escape для оставшихся специальных символов
	sanitized = html.EscapeString(sanitized)
	
	// 6. Trim пробелов
	sanitized = strings.TrimSpace(sanitized)
	
	return sanitized
}

// SanitizeEmail очищает email адрес
// Email не должен содержать HTML, только символы email
func SanitizeEmail(email string) string {
	if email == "" {
		return ""
	}
	
	// Trim пробелов
	email = strings.TrimSpace(email)
	
	// Приводим к нижнему регистру
	email = strings.ToLower(email)
	
	// Удаляем все HTML теги
	email = htmlTagsRegex.ReplaceAllString(email, "")
	
	// HTML escape для специальных символов
	email = html.EscapeString(email)
	
	return email
}

// SanitizeUsername очищает имя пользователя
// Разрешены только буквы, цифры, подчёркивания и пробелы
func SanitizeUsername(username string) string {
	if username == "" {
		return ""
	}
	
	// Базовая санитизация
	sanitized := SanitizeString(username)
	
	// Удаляем все кроме букв, цифр, подчёркиваний, пробелов и дефисов
	allowedChars := regexp.MustCompile(`[^\w\s\-а-яА-ЯёЁ]`)
	sanitized = allowedChars.ReplaceAllString(sanitized, "")
	
	// Trim и нормализация пробелов
	spaces := regexp.MustCompile(`\s+`)
	sanitized = spaces.ReplaceAllString(sanitized, " ")
	sanitized = strings.TrimSpace(sanitized)
	
	// Ограничение длины
	if len(sanitized) > 50 {
		sanitized = sanitized[:50]
	}
	
	return sanitized
}

// SanitizeDisplayName очищает отображаемое имя
// Более мягкая версия, разрешает больше символов
func SanitizeDisplayName(name string) string {
	if name == "" {
		return ""
	}
	
	// Базовая санитизация
	sanitized := SanitizeString(name)
	
	// Ограничение длины
	if len(sanitized) > 100 {
		sanitized = sanitized[:100]
	}
	
	return sanitized
}

// SanitizeURL очищает URL
// Разрешены только http и https протоколы
func SanitizeURL(inputURL string) string {
	if inputURL == "" {
		return ""
	}
	
	// Trim
	inputURL = strings.TrimSpace(inputURL)
	
	// Проверяем протокол
	if !strings.HasPrefix(inputURL, "http://") && !strings.HasPrefix(inputURL, "https://") {
		return "" // Неподдерживаемый протокол
	}
	
	// HTML escape
	inputURL = html.EscapeString(inputURL)
	
	return inputURL
}

// SanitizeTextInput очищает текстовый ввод (описания, комментарии и т.д.)
func SanitizeTextInput(text string, maxLength int) string {
	if text == "" {
		return ""
	}
	
	// Базовая санитизация
	sanitized := SanitizeString(text)
	
	// Ограничение длины
	if maxLength > 0 && len(sanitized) > maxLength {
		sanitized = sanitized[:maxLength]
	}
	
	return sanitized
}

// ContainsDangerousPattern проверяет, содержит ли строка опасные паттерны
// Возвращает true если найдены подозрительные вставки
func ContainsDangerousPattern(input string) bool {
	if input == "" {
		return false
	}
	
	// Проверяем на script теги
	if scriptRegex.MatchString(input) {
		return true
	}
	
	// Проверяем на event handlers
	if eventHandlerRegex.MatchString(input) {
		return true
	}
	
	// Проверяем на javascript: URI
	if javascriptURIRegex.MatchString(input) {
		return true
	}
	
	return false
}

// SanitizeJSONValue очищает значение JSON от опасных вставок
func SanitizeJSONValue(value interface{}) interface{} {
	switch v := value.(type) {
	case string:
		return SanitizeString(v)
	case map[string]interface{}:
		sanitized := make(map[string]interface{})
		for key, val := range v {
			sanitized[key] = SanitizeJSONValue(val)
		}
		return sanitized
	case []interface{}:
		sanitized := make([]interface{}, len(v))
		for i, val := range v {
			sanitized[i] = SanitizeJSONValue(val)
		}
		return sanitized
	default:
		return value
	}
}
