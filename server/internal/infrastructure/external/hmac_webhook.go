package external

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"

	"github.com/pkg/errors"
)

func VerifyHMACSHA256Hex(payload []byte, signatureHex string, secret string) error {
	if secret == "" {
		return errors.New("webhook secret not configured")
	}
	if signatureHex == "" {
		return errors.New("missing signature header")
	}
	m := hmac.New(sha256.New, []byte(secret))
	m.Write(payload)
	expected := hex.EncodeToString(m.Sum(nil))
	if !hmac.Equal([]byte(expected), []byte(signatureHex)) {
		return errors.New("signature verification failed")
	}
	return nil
}
