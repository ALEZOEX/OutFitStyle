package validation

import (
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"regexp"
	"strings"
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
