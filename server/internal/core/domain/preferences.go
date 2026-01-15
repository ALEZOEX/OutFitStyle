package domain

type UserPreferences struct {
	PreferredStyles        []string `json:"preferred_styles,omitempty"`
	AvoidStyles            []string `json:"avoid_styles,omitempty"`
	ColorPreferences       []string `json:"color_preferences,omitempty"`
	AvoidColors            []string `json:"avoid_colors,omitempty"`
	PreferredCategories    []string `json:"preferred_categories,omitempty"`
	FormalityDefault       *int     `json:"formality_default,omitempty"`
	TemperatureSensitivity *int     `json:"temperature_sensitivity,omitempty"`
	NotificationsEnabled   *bool    `json:"notifications_enabled,omitempty"`
	MorningReminderTime    *string  `json:"morning_reminder_time,omitempty"` // "08:00"
	WeeklyDigest           *bool    `json:"weekly_digest,omitempty"`
}

type BodyMeasurements struct {
	Height *int `json:"height,omitempty"`
	Weight *int `json:"weight,omitempty"`

	Sizes *struct {
		Top        *string `json:"top,omitempty"`
		Bottom     *string `json:"bottom,omitempty"`
		Shoes      *string `json:"shoes,omitempty"`
		SizeSystem *string `json:"size_system,omitempty"` // EU/US/UK/RU
	} `json:"sizes,omitempty"`
}
