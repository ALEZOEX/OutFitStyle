package pg

// nullJSON converts a byte slice to an interface{} that's either nil or the byte slice
// Used for database operations where JSON fields might be empty
func nullJSON(b []byte) interface{} {
	if len(b) == 0 {
		return nil
	}
	return b
}

// itoa converts int to string without importing fmt
func itoa(i int) string {
	// tiny helper, no fmt import here
	if i <= 0 {
		return "0"
	}
	var b [32]byte
	pos := len(b)
	for i > 0 {
		pos--
		b[pos] = byte('0' + (i % 10))
		i /= 10
	}
	return string(b[pos:])
}