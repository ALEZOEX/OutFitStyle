// Пакет validation предоставляет функции для валидации данных в приложении
// Содержит универсальные валидаторы и специфические функции для проверки различных типов данных
package validation

import (
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"net/url"
	"regexp"
	"strings"
	"time"

	"github.com/google/uuid"

	"outfitstyle/server/internal/core/domain"
	"outfitstyle/server/internal/validation/sanitization"
)

// SanitizeEmail очищает email адрес
func SanitizeEmail(email string) string {
	return sanitization.SanitizeEmail(email)
}

// SanitizeDisplayName очищает отображаемое имя
func SanitizeDisplayName(name string) string {
	return sanitization.SanitizeDisplayName(name)
}

// SanitizeUsername очищает имя пользователя
func SanitizeUsername(username string) string {
	return sanitization.SanitizeUsername(username)
}

// SanitizeString очищает строку от потенциально опасных HTML/JS вставок
func SanitizeString(input string) string {
	return sanitization.SanitizeString(input)
}

// ContainsDangerousPattern проверяет, содержит ли строка опасные паттерны
func ContainsDangerousPattern(input string) bool {
	return sanitization.ContainsDangerousPattern(input)
}

// Validator структура для хранения ошибок валидации
type Validator struct {
	Errors map[string]string // Карта ошибок валидации с ключом поля и сообщением об ошибке
}

// NewValidator создает новый экземпляр валидатора
// Инициализирует пустую карту ошибок
func NewValidator() *Validator {
	return &Validator{Errors: make(map[string]string)}
}

// Valid проверяет, есть ли ошибки валидации
// Возвращает true, если ошибок нет, иначе false
func (v *Validator) Valid() bool {
	return len(v.Errors) == 0
}

// AddError добавляет ошибку валидации для указанного ключа
// Не перезаписывает существующую ошибку для того же ключа
func (v *Validator) AddError(key, message string) {
	if _, exists := v.Errors[key]; !exists {
		v.Errors[key] = message
	}
}

// Check добавляет ошибку, если условие ложно
// Используется для проверки различных условий валидации
func (v *Validator) Check(ok bool, key, message string) {
	if !ok {
		v.AddError(key, message)
	}
}

// Matches проверяет, соответствует ли строка регулярному выражению
func (v *Validator) Matches(value string, rx *regexp.Regexp) bool {
	return rx.MatchString(value)
}

// In проверяет, содержится ли значение в списке допустимых значений
func (v *Validator) In(value string, checklist ...string) bool {
	for i := range checklist {
		if value == checklist[i] {
			return true
		}
	}
	return false
}

// Unique проверяет, являются ли все значения в срезе уникальными
func (v *Validator) Unique(values []string) bool {
	uniqueValues := make(map[string]bool)
	for _, value := range values {
		if uniqueValues[value] {
			return false
		}
		uniqueValues[value] = true
	}
	return true
}

// EmailRX регулярное выражение для валидации email-адресов
var EmailRX = regexp.MustCompile("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$")

// ValidateEmail проверяет корректность email-адреса
func ValidateEmail(v *Validator, email string) {
	v.Check(email != "", "email", "must be provided")
	v.Check(EmailRX.MatchString(email), "email", "must be a valid email address")
}

// ValidatePasswordPlaintext проверяет требования к паролю
// Security: минимальная длина 8 символов (баланс между безопасностью и UX)
// Максимальная длина 72 символа (ограничение bcrypt)
func ValidatePasswordPlaintext(v *Validator, password string) {
	v.Check(password != "", "password", "must be provided")
	v.Check(len(password) >= 8, "password", "must be at least 8 characters long")
	v.Check(len(password) <= 72, "password", "must not be more than 72 characters long")
	
	// Проверка сложности пароля
	hasUpper := false
	hasLower := false
	hasDigit := false
	hasSpecial := false
	
	for _, char := range password {
		switch {
		case char >= 'A' && char <= 'Z':
			hasUpper = true
		case char >= 'a' && char <= 'z':
			hasLower = true
		case char >= '0' && char <= '9':
			hasDigit = true
		case char == '!' || char == '@' || char == '#' || char == '$' || 
		     char == '%' || char == '^' || char == '&' || char == '*' || 
		     char == '(' || char == ')' || char == '-' || char == '_' || 
		     char == '=' || char == '+' || char == '[' || char == ']' || 
		     char == '{' || char == '}' || char == '|' || char == ';' || 
		     char == ':' || char == '"' || char == '\'' || char == '<' || 
		     char == '>' || char == ',' || char == '.' || char == '/' || 
		     char == '?' || char == '`' || char == '~' || char == '\\':
			hasSpecial = true
		}
	}
	
	v.Check(hasUpper, "password", "must contain at least one uppercase letter")
	v.Check(hasLower, "password", "must contain at least one lowercase letter")
	v.Check(hasDigit, "password", "must contain at least one number")
	v.Check(hasSpecial, "password", "must contain at least one special character")
}

// ValidateUser проверяет поля пользователя
func ValidateUser(v *Validator, name, email, password string) {
	v.Check(name != "", "name", "must be provided")
	v.Check(len(name) <= 500, "name", "must not be more than 500 bytes long")

	ValidateEmail(v, email)
	ValidatePasswordPlaintext(v, password)
}

// ValidateWardrobeItem проверяет поля элемента гардероба
func ValidateWardrobeItem(v *Validator, name, category, color string, warmthLevel int) {
	v.Check(name != "", "name", "must be provided")
	v.Check(len(name) <= 200, "name", "must not be more than 200 characters long")

	v.Check(category != "", "category", "must be provided")
	validCategories := []string{"top", "bottom", "shoes", "outerwear", "accessory", "dress", "suit"}
	v.Check(v.In(category, validCategories...), "category", "must be a valid category")

	v.Check(color != "", "color", "must be provided")
	v.Check(len(color) <= 50, "color", "must not be more than 50 characters long")

	v.Check(warmthLevel >= 0 && warmthLevel <= 5, "warmth_level", "must be between 0 and 5")
}

// ValidateJSONBody декодирует JSON-тело запроса в указанный объект
// Проверяет корректность JSON-формата и ограничивает размер тела запроса
func ValidateJSONBody(w http.ResponseWriter, r *http.Request, dst interface{}) error {
	const maxBytes = 1_048_576 // 1MB

	r.Body = http.MaxBytesReader(w, r.Body, maxBytes)
	dec := json.NewDecoder(r.Body)
	dec.DisallowUnknownFields()

	err := dec.Decode(dst)
	if err != nil {
		var syntaxError *json.SyntaxError
		var unmarshalTypeError *json.UnmarshalTypeError

		switch {
		case errors.As(err, &syntaxError):
			return fmt.Errorf("body contains badly-formed JSON (at character %d)", syntaxError.Offset)

		case errors.As(err, &unmarshalTypeError):
			if unmarshalTypeError.Field != "" {
				return fmt.Errorf("body contains incorrect JSON type for field %q", unmarshalTypeError.Field)
			}
			return fmt.Errorf("body contains incorrect JSON type (at character %d)", unmarshalTypeError.Offset)

		case strings.HasPrefix(err.Error(), "json: unknown field "):
			fieldName := strings.TrimPrefix(err.Error(), "json: unknown field ")
			return fmt.Errorf("body contains unknown field %s", fieldName)

		case err.Error() == "http: request body too large":
			return fmt.Errorf("body must not be larger than 1MB")

		default:
			return err
		}
	}

	return nil
}

// ValidateUserRegistration проверяет данные регистрации пользователя
func ValidateUserRegistration(v *Validator, reg domain.UserRegistration) {
	ValidateEmail(v, reg.Email)
	ValidatePasswordPlaintext(v, reg.Password)

	if reg.DisplayName != nil {
		v.Check(len(*reg.DisplayName) <= 500, "display_name", "must not be more than 500 bytes long")
	}

	if reg.Locale != nil && *reg.Locale != "" {
		// Базовая валидация локали - должна быть в формате "en", "en_US" и т.д.
		v.Check(len(*reg.Locale) >= 2, "locale", "must be at least 2 characters long")
		v.Check(len(*reg.Locale) <= 10, "locale", "must be more than 10 characters long")
	}
}

// ValidateClothingItem проверяет поля элемента одежды
func ValidateClothingItem(v *Validator, item domain.ClothingItem) {
	// Проверка обязательных полей
	v.Check(item.Name != "", "name", "must be provided")
	v.Check(len(item.Name) <= 200, "name", "must not be more than 200 characters long")

	v.Check(item.Category != "", "category", "must be provided")
	v.Check(len(item.Category) <= 100, "category", "must not be more than 100 characters long")

	v.Check(item.Subcategory != "", "subcategory", "must be provided")
	v.Check(len(item.Subcategory) <= 100, "subcategory", "must not be more than 100 characters long")

	// Проверка диапазона температур
	if item.MinTemp != nil && item.MaxTemp != nil {
		v.Check(*item.MinTemp <= *item.MaxTemp, "temperature_range", "min_temp cannot be greater than max_temp")
	}

	// Проверка уровня теплоты
	if item.WarmthLevel != nil {
		v.Check(*item.WarmthLevel >= 1 && *item.WarmthLevel <= 10, "warmth_level", "must be between 1 and 10")
	}

	// Проверка уровня формальности
	if item.FormalityLevel != nil {
		v.Check(*item.FormalityLevel >= 1 && *item.FormalityLevel <= 5, "formality_level", "must be between 1 and 5")
	}

	// Проверка необязательных полей
	if item.Description != nil {
		v.Check(len(*item.Description) <= 1000, "description", "must not be more than 1000 characters long")
	}

	if item.BaseColour != nil {
		v.Check(len(*item.BaseColour) <= 50, "base_colour", "must not be more than 50 characters long")
	}

	if item.Brand != nil {
		v.Check(len(*item.Brand) <= 100, "brand", "must not be more than 100 characters long")
	}

	if item.ImageURL != nil {
		v.Check(len(*item.ImageURL) <= 500, "image_url", "must not be more than 500 characters long")
	}

	if item.ThumbnailURL != nil {
		v.Check(len(*item.ThumbnailURL) <= 500, "thumbnail_url", "must not be more than 500 characters long")
	}

	if item.IconEmoji != nil {
		v.Check(len(*item.IconEmoji) <= 10, "icon_emoji", "must not be more than 10 characters long")
	}
}

// ValidateUUID validates that a string is a valid UUID
func ValidateUUID(v *Validator, uuidStr, fieldName string) {
	_, err := uuid.Parse(uuidStr)
	v.Check(err == nil, fieldName, fmt.Sprintf("%s must be a valid UUID", fieldName))
}

// ValidateIntegerRange проверяет, находится ли целое число в заданном диапазоне
func ValidateIntegerRange(v *Validator, value int, min, max int, fieldName, fieldLabel string) {
	v.Check(value >= min, fieldName, fmt.Sprintf("%s must be greater than or equal to %d", fieldLabel, min))
	v.Check(value <= max, fieldName, fmt.Sprintf("%s must be less than or equal to %d", fieldLabel, max))
}

// ValidateStringLength проверяет длину строки
func ValidateStringLength(v *Validator, value string, minLen, maxLen int, fieldName, fieldLabel string) {
	v.Check(len(value) >= minLen, fieldName, fmt.Sprintf("%s must be at least %d characters long", fieldLabel, minLen))
	v.Check(len(value) <= maxLen, fieldName, fmt.Sprintf("%s must not be more than %d characters long", fieldLabel, maxLen))
}

// ValidateFloatRange проверяет, находится ли число с плавающей точкой в заданном диапазоне
func ValidateFloatRange(v *Validator, value float64, min, max float64, fieldName, fieldLabel string) {
	v.Check(value >= min, fieldName, fmt.Sprintf("%s must be greater than or equal to %.2f", fieldLabel, min))
	v.Check(value <= max, fieldName, fmt.Sprintf("%s must be less than or equal to %.2f", fieldLabel, max))
}

// ValidateLatitude проверяет, находится ли широта в допустимом диапазоне [-90, 90]
func ValidateLatitude(v *Validator, lat *float64) {
	if lat != nil {
		ValidateFloatRange(v, *lat, -90.0, 90.0, "latitude", "latitude")
	}
}

// ValidateLongitude проверяет, находится ли долгота в допустимом диапазоне [-180, 180]
func ValidateLongitude(v *Validator, lng *float64) {
	if lng != nil {
		ValidateFloatRange(v, *lng, -180.0, 180.0, "longitude", "longitude")
	}
}

// ValidateURL проверяет, является ли строка допустимым URL
func ValidateURL(v *Validator, urlStr *string, fieldName, fieldLabel string) {
	if urlStr != nil && *urlStr != "" {
		_, err := url.ParseRequestURI(*urlStr)
		v.Check(err == nil, fieldName, fmt.Sprintf("%s must be a valid URL", fieldLabel))
	}
}

// ValidateEnumValue проверяет, является ли значение одним из разрешенных значений
func ValidateEnumValue(v *Validator, value, validValue string, fieldName, fieldLabel string) {
	v.Check(value == validValue, fieldName, fmt.Sprintf("%s must be %s", fieldLabel, validValue))
}

// ValidateInSlice проверяет, содержится ли значение в срезе допустимых значений
func ValidateInSlice(v *Validator, value string, validValues []string, fieldName, fieldLabel string) {
	inSlice := false
	for _, validValue := range validValues {
		if value == validValue {
			inSlice = true
			break
		}
	}
	v.Check(inSlice, fieldName, fmt.Sprintf("%s must be one of [%s]", fieldLabel, strings.Join(validValues, ", ")))
}

// ValidatePositiveInt проверяет, является ли целое число положительным
func ValidatePositiveInt(v *Validator, value *int, fieldName, fieldLabel string) {
	if value != nil {
		v.Check(*value > 0, fieldName, fmt.Sprintf("%s must be positive", fieldLabel))
	}
}

// ValidateNonNegativeInt проверяет, является ли целое число неотрицательным
func ValidateNonNegativeInt(v *Validator, value *int, fieldName, fieldLabel string) {
	if value != nil {
		v.Check(*value >= 0, fieldName, fmt.Sprintf("%s must be non-negative", fieldLabel))
	}
}

// ValidateDate проверяет, является ли строка допустимой датой в формате YYYY-MM-DD
func ValidateDate(v *Validator, dateStr string, fieldName, fieldLabel string) {
	_, err := time.Parse("2006-01-02", dateStr)
	v.Check(err == nil, fieldName, fmt.Sprintf("%s must be a valid date in YYYY-MM-DD format", fieldLabel))
}

// ValidateDateTime проверяет, является ли строка допустимой датой и временем
func ValidateDateTime(v *Validator, dateTimeStr string, fieldName, fieldLabel string) {
	_, err := time.Parse(time.RFC3339, dateTimeStr)
	v.Check(err == nil, fieldName, fmt.Sprintf("%s must be a valid datetime in RFC3339 format", fieldLabel))
}
