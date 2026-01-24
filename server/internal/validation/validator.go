package validation

import (
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"regexp"
	"strings"

	"outfitstyle/server/internal/core/domain"
)

type Validator struct {
	Errors map[string]string
}

func NewValidator() *Validator {
	return &Validator{Errors: make(map[string]string)}
}

func (v *Validator) Valid() bool {
	return len(v.Errors) == 0
}

func (v *Validator) AddError(key, message string) {
	if _, exists := v.Errors[key]; !exists {
		v.Errors[key] = message
	}
}

func (v *Validator) Check(ok bool, key, message string) {
	if !ok {
		v.AddError(key, message)
	}
}

func (v *Validator) Matches(value string, rx *regexp.Regexp) bool {
	return rx.MatchString(value)
}

func (v *Validator) In(value string, checklist ...string) bool {
	for i := range checklist {
		if value == checklist[i] {
			return true
		}
	}
	return false
}

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

// EmailRX is a regular expression for validating email addresses.
var EmailRX = regexp.MustCompile("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$")

func ValidateEmail(v *Validator, email string) {
	v.Check(email != "", "email", "must be provided")
	v.Check(EmailRX.MatchString(email), "email", "must be a valid email address")
}

func ValidatePasswordPlaintext(v *Validator, password string) {
	v.Check(password != "", "password", "must be provided")
	v.Check(len(password) >= 8, "password", "must be at least 8 characters long")
	v.Check(len(password) <= 72, "password", "must not be more than 72 characters long")
}

func ValidateUser(v *Validator, name, email, password string) {
	v.Check(name != "", "name", "must be provided")
	v.Check(len(name) <= 500, "name", "must not be more than 500 bytes long")

	ValidateEmail(v, email)
	ValidatePasswordPlaintext(v, password)
}

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

func ValidateUserRegistration(v *Validator, reg domain.UserRegistration) {
	ValidateEmail(v, reg.Email)
	ValidatePasswordPlaintext(v, reg.Password)

	if reg.DisplayName != nil {
		v.Check(len(*reg.DisplayName) <= 500, "display_name", "must not be more than 500 bytes long")
	}

	if reg.Locale != nil && *reg.Locale != "" {
		// Basic locale validation - should be in format like "en", "en_US", etc.
		v.Check(len(*reg.Locale) >= 2, "locale", "must be at least 2 characters long")
		v.Check(len(*reg.Locale) <= 10, "locale", "must be more than 10 characters long")
	}
}

func ValidateClothingItem(v *Validator, item domain.ClothingItem) {
	// Validate required fields
	v.Check(item.Name != "", "name", "must be provided")
	v.Check(len(item.Name) <= 200, "name", "must not be more than 200 characters long")

	v.Check(item.Category != "", "category", "must be provided")
	v.Check(len(item.Category) <= 100, "category", "must not be more than 100 characters long")

	v.Check(item.Subcategory != "", "subcategory", "must be provided")
	v.Check(len(item.Subcategory) <= 100, "subcategory", "must not be more than 100 characters long")

	// Validate temperature range
	if item.MinTemp != nil && item.MaxTemp != nil {
		v.Check(*item.MinTemp <= *item.MaxTemp, "temperature_range", "min_temp cannot be greater than max_temp")
	}

	// Validate warmth level
	if item.WarmthLevel != nil {
		v.Check(*item.WarmthLevel >= 1 && *item.WarmthLevel <= 10, "warmth_level", "must be between 1 and 10")
	}

	// Validate formality level
	if item.FormalityLevel != nil {
		v.Check(*item.FormalityLevel >= 1 && *item.FormalityLevel <= 5, "formality_level", "must be between 1 and 5")
	}

	// Validate optional fields
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
