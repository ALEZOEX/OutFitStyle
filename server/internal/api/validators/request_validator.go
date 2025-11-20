package validators

import (
	"net/url"
	"strconv"
)

// ValidationError represents a validation error
type ValidationError struct {
	Field   string `json:"field"`
	Message string `json:"message"`
}

func (e ValidationError) Error() string {
	return e.Message
}

// ValidationErrors represents a collection of validation errors
type ValidationErrors []ValidationError

func (ve ValidationErrors) Error() string {
	if len(ve) == 0 {
		return ""
	}
	return ve[0].Message
}

// RecommendationRequestValidator validates recommendation request parameters
type RecommendationRequestValidator struct{}

func NewRecommendationRequestValidator() *RecommendationRequestValidator {
	return &RecommendationRequestValidator{}
}

func (v *RecommendationRequestValidator) ValidateGetRecommendations(query url.Values) error {
	var errs ValidationErrors

	city := query.Get("city")
	if city == "" {
		errs = append(errs, ValidationError{
			Field:   "city",
			Message: "city parameter is required",
		})
	}

	userIDStr := query.Get("user_id")
	if userIDStr != "" {
		if _, err := strconv.Atoi(userIDStr); err != nil {
			errs = append(errs, ValidationError{
				Field:   "user_id",
				Message: "user_id must be a valid integer",
			})
		}
	}

	if len(errs) > 0 {
		return errs
	}

	return nil
}

func (v *RecommendationRequestValidator) ValidateGetRecommendationHistory(query url.Values) error {
	var errs ValidationErrors

	userIDStr := query.Get("user_id")
	if userIDStr == "" {
		errs = append(errs, ValidationError{
			Field:   "user_id",
			Message: "user_id parameter is required",
		})
	} else if _, err := strconv.Atoi(userIDStr); err != nil {
		errs = append(errs, ValidationError{
			Field:   "user_id",
			Message: "user_id must be a valid integer",
		})
	}

	limitStr := query.Get("limit")
	if limitStr != "" {
		if limit, err := strconv.Atoi(limitStr); err != nil || limit <= 0 {
			errs = append(errs, ValidationError{
				Field:   "limit",
				Message: "limit must be a positive integer",
			})
		}
	}

	if len(errs) > 0 {
		return errs
	}

	return nil
}
