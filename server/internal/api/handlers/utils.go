package handlers

import "strconv"

// atoi converts string to int with optional default value
func AtoiWithDefault(s string, def int) int {
	n, err := strconv.Atoi(s)
	if err != nil {
		return def
	}
	return n
}

// atoi converts string to int, returning 0 on error
func Atoi(s string) int {
	n, err := strconv.Atoi(s)
	if err != nil {
		return 0
	}
	return n
}
