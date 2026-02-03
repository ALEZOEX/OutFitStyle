package validation

import (
	"testing"
)

func TestValidateStringLength(t *testing.T) {
	tests := []struct {
		name     string
		value    string
		minLen   int
		maxLen   int
		expected bool
	}{
		{"Valid length", "hello", 3, 10, true},
		{"Too short", "hi", 3, 10, false},
		{"Too long", "this is a very long string", 3, 10, false},
		{"Exactly min length", "abc", 3, 10, true},
		{"Exactly max length", "abcdefghij", 3, 10, true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			v := NewValidator()
			ValidateStringLength(v, tt.value, tt.minLen, tt.maxLen, "field", "Field")
			
			if v.Valid() != tt.expected {
				t.Errorf("Expected Valid()=%v, got Valid()=%v", tt.expected, v.Valid())
			}
		})
	}
}

func TestValidateIntegerRange(t *testing.T) {
	tests := []struct {
		name     string
		value    int
		min      int
		max      int
		expected bool
	}{
		{"Within range", 5, 1, 10, true},
		{"Below minimum", 0, 1, 10, false},
		{"Above maximum", 15, 1, 10, false},
		{"Exactly minimum", 1, 1, 10, true},
		{"Exactly maximum", 10, 1, 10, true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			v := NewValidator()
			ValidateIntegerRange(v, tt.value, tt.min, tt.max, "field", "Field")
			
			if v.Valid() != tt.expected {
				t.Errorf("Expected Valid()=%v, got Valid()=%v", tt.expected, v.Valid())
			}
		})
	}
}

func TestValidateFloatRange(t *testing.T) {
	tests := []struct {
		name     string
		value    float64
		min      float64
		max      float64
		expected bool
	}{
		{"Within range", 5.5, 1.0, 10.0, true},
		{"Below minimum", 0.5, 1.0, 10.0, false},
		{"Above maximum", 15.5, 1.0, 10.0, false},
		{"Exactly minimum", 1.0, 1.0, 10.0, true},
		{"Exactly maximum", 10.0, 1.0, 10.0, true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			v := NewValidator()
			ValidateFloatRange(v, tt.value, tt.min, tt.max, "field", "Field")
			
			if v.Valid() != tt.expected {
				t.Errorf("Expected Valid()=%v, got Valid()=%v", tt.expected, v.Valid())
			}
		})
	}
}

func TestValidateLatitude(t *testing.T) {
	tests := []struct {
		name     string
		lat      *float64
		expected bool
	}{
		{"Valid latitude", floatPtr(45.5), true},
		{"Zero latitude", floatPtr(0.0), true},
		{"Maximum latitude", floatPtr(90.0), true},
		{"Minimum latitude", floatPtr(-90.0), true},
		{"Above maximum", floatPtr(95.0), false},
		{"Below minimum", floatPtr(-95.0), false},
		{"Nil latitude", nil, true}, // Should pass since it's optional
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			v := NewValidator()
			ValidateLatitude(v, tt.lat)
			
			if v.Valid() != tt.expected {
				t.Errorf("Expected Valid()=%v, got Valid()=%v", tt.expected, v.Valid())
			}
		})
	}
}

func TestValidateLongitude(t *testing.T) {
	tests := []struct {
		name     string
		lng      *float64
		expected bool
	}{
		{"Valid longitude", floatPtr(-122.4), true},
		{"Zero longitude", floatPtr(0.0), true},
		{"Maximum longitude", floatPtr(180.0), true},
		{"Minimum longitude", floatPtr(-180.0), true},
		{"Above maximum", floatPtr(185.0), false},
		{"Below minimum", floatPtr(-185.0), false},
		{"Nil longitude", nil, true}, // Should pass since it's optional
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			v := NewValidator()
			ValidateLongitude(v, tt.lng)
			
			if v.Valid() != tt.expected {
				t.Errorf("Expected Valid()=%v, got Valid()=%v", tt.expected, v.Valid())
			}
		})
	}
}

func TestValidateInSlice(t *testing.T) {
	validValues := []string{"option1", "option2", "option3"}

	tests := []struct {
		name     string
		value    string
		expected bool
	}{
		{"Valid option", "option1", true},
		{"Another valid option", "option2", true},
		{"Invalid option", "option4", false},
		{"Case sensitive", "Option1", false},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			v := NewValidator()
			ValidateInSlice(v, tt.value, validValues, "field", "Field")
			
			if v.Valid() != tt.expected {
				t.Errorf("Expected Valid()=%v, got Valid()=%v", tt.expected, v.Valid())
			}
		})
	}
}

func TestValidateDate(t *testing.T) {
	tests := []struct {
		name     string
		date     string
		expected bool
	}{
		{"Valid date", "2023-12-25", true},
		{"Invalid format", "25-12-2023", false},
		{"Invalid date", "2023-02-30", false}, // February 30th doesn't exist
		{"Leap year", "2024-02-29", true},     // 2024 is a leap year
		{"Non-leap year", "2023-02-29", false}, // 2023 is not a leap year
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			v := NewValidator()
			ValidateDate(v, tt.date, "field", "Field")
			
			if v.Valid() != tt.expected {
				t.Errorf("Expected Valid()=%v, got Valid()=%v", tt.expected, v.Valid())
			}
		})
	}
}

func floatPtr(f float64) *float64 {
	return &f
}