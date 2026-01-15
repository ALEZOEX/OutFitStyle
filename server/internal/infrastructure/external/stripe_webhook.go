package external

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
	"strings"
	"time"

	"github.com/pkg/errors"
)

func VerifyStripeSignature(payload []byte, stripeSignatureHeader string, webhookSecret string, tolerance time.Duration) error {
	// Stripe-Signature: t=timestamp,v1=signature[,v0=...]
	if webhookSecret == "" {
		return errors.New("stripe webhook secret not configured")
	}
	if stripeSignatureHeader == "" {
		return errors.New("missing Stripe-Signature header")
	}

	var ts string
	var v1 []string

	parts := strings.Split(stripeSignatureHeader, ",")
	for _, p := range parts {
		p = strings.TrimSpace(p)
		if strings.HasPrefix(p, "t=") {
			ts = strings.TrimPrefix(p, "t=")
		}
		if strings.HasPrefix(p, "v1=") {
			v1 = append(v1, strings.TrimPrefix(p, "v1="))
		}
	}
	if ts == "" || len(v1) == 0 {
		return errors.New("invalid Stripe-Signature header")
	}

	tInt, err := parseInt64(ts)
	if err != nil {
		return errors.New("invalid stripe timestamp")
	}
	tm := time.Unix(tInt, 0)
	now := time.Now()
	if tolerance > 0 {
		if tm.Before(now.Add(-tolerance)) || tm.After(now.Add(tolerance)) {
			return errors.New("stripe signature timestamp outside tolerance")
		}
	}

	signedPayload := []byte(ts + "." + string(payload))
	mac := hmac.New(sha256.New, []byte(webhookSecret))
	mac.Write(signedPayload)
	expected := hex.EncodeToString(mac.Sum(nil))

	for _, sig := range v1 {
		if secureEqual(expected, sig) {
			return nil
		}
	}
	return errors.New("stripe signature verification failed")
}

func secureEqual(a, b string) bool {
	ab := []byte(a)
	bb := []byte(b)
	return hmac.Equal(ab, bb)
}

func parseInt64(s string) (int64, error) {
	var n int64
	for i := 0; i < len(s); i++ {
		c := s[i]
		if c < '0' || c > '9' {
			return 0, errors.New("non-digit")
		}
		n = n*10 + int64(c-'0')
	}
	return n, nil
}
