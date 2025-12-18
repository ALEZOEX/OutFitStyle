package services

import (
	"time"
)

func TimeOfDayInTZ(now time.Time, tz string) string {
	loc, err := time.LoadLocation(tz)
	if err != nil {
		loc = time.UTC
	}
	h := now.In(loc).Hour()
	switch {
	case h >= 5 && h < 11:
		return "morning"
	case h >= 11 && h < 17:
		return "day"
	case h >= 17 && h < 23:
		return "evening"
	default:
		return "night"
	}
}