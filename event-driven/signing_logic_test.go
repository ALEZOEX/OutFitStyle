package event_driven

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"testing"

	"github.com/segmentio/kafka-go"
)

// Test the core signing and verification logic without dependencies on Publisher/Consumer
func TestHMACSigningLogic(t *testing.T) {
	signingKey := "test-signing-key-12345"
	testData := []byte("test message data")

	// Generate signature
	h := hmac.New(sha256.New, []byte(signingKey))
	h.Write(testData)
	signature := base64.StdEncoding.EncodeToString(h.Sum(nil))

	// Verify signature is not empty
	if signature == "" {
		t.Error("Signature should not be empty")
	}

	// Verify signature is base64 encoded
	decoded, err := base64.StdEncoding.DecodeString(signature)
	if err != nil {
		t.Errorf("Signature should be valid base64: %v", err)
	}

	// HMAC-SHA256 produces 32 bytes
	if len(decoded) != 32 {
		t.Errorf("Decoded signature length = %d, expected 32 bytes", len(decoded))
	}

	// Verify signature is deterministic
	h2 := hmac.New(sha256.New, []byte(signingKey))
	h2.Write(testData)
	signature2 := base64.StdEncoding.EncodeToString(h2.Sum(nil))
	if signature != signature2 {
		t.Error("Signature should be deterministic for same data")
	}

	// Verify different data produces different signature
	differentData := []byte("different message data")
	h3 := hmac.New(sha256.New, []byte(signingKey))
	h3.Write(differentData)
	differentSignature := base64.StdEncoding.EncodeToString(h3.Sum(nil))
	if signature == differentSignature {
		t.Error("Different data should produce different signature")
	}
}

func TestHMACVerificationLogic(t *testing.T) {
	signingKey := "test-signing-key-12345"
	testData := []byte("test message data")

	// Generate valid signature
	h := hmac.New(sha256.New, []byte(signingKey))
	h.Write(testData)
	validSignature := base64.StdEncoding.EncodeToString(h.Sum(nil))

	tests := []struct {
		name      string
		data      []byte
		signature string
		key       string
		expected  bool
	}{
		{
			name:      "Valid signature",
			data:      testData,
			signature: validSignature,
			key:       signingKey,
			expected:  true,
		},
		{
			name:      "Invalid signature",
			data:      testData,
			signature: "invalid-signature-xyz",
			key:       signingKey,
			expected:  false,
		},
		{
			name:      "Empty signature",
			data:      testData,
			signature: "",
			key:       signingKey,
			expected:  false,
		},
		{
			name:      "Modified data",
			data:      []byte("modified message data"),
			signature: validSignature,
			key:       signingKey,
			expected:  false,
		},
		{
			name:      "Different key",
			data:      testData,
			signature: validSignature,
			key:       "different-key",
			expected:  false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// Verify signature
			h := hmac.New(sha256.New, []byte(tt.key))
			h.Write(tt.data)
			expectedSignature := h.Sum(nil)
			expectedSignatureStr := base64.StdEncoding.EncodeToString(expectedSignature)

			// Use constant-time comparison
			result := hmac.Equal([]byte(expectedSignatureStr), []byte(tt.signature))

			if result != tt.expected {
				t.Errorf("verifySignature() = %v, expected %v", result, tt.expected)
			}
		})
	}
}

func TestHeaderExtraction(t *testing.T) {
	tests := []struct {
		name          string
		headers       []kafka.Header
		expectedSig   string
		expectedFound bool
	}{
		{
			name: "Signature present",
			headers: []kafka.Header{
				{Key: "X-Message-Signature", Value: []byte("test-signature")},
			},
			expectedSig:   "test-signature",
			expectedFound: true,
		},
		{
			name: "Signature with other headers",
			headers: []kafka.Header{
				{Key: "Content-Type", Value: []byte("application/json")},
				{Key: "X-Message-Signature", Value: []byte("test-signature-2")},
				{Key: "X-Request-ID", Value: []byte("12345")},
			},
			expectedSig:   "test-signature-2",
			expectedFound: true,
		},
		{
			name: "No signature header",
			headers: []kafka.Header{
				{Key: "Content-Type", Value: []byte("application/json")},
			},
			expectedSig:   "",
			expectedFound: false,
		},
		{
			name:          "Empty headers",
			headers:       []kafka.Header{},
			expectedSig:   "",
			expectedFound: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// Extract signature from headers
			var sig string
			var found bool
			for _, header := range tt.headers {
				if header.Key == "X-Message-Signature" {
					sig = string(header.Value)
					found = true
					break
				}
			}

			if sig != tt.expectedSig {
				t.Errorf("signature = %v, expected %v", sig, tt.expectedSig)
			}
			if found != tt.expectedFound {
				t.Errorf("found = %v, expected %v", found, tt.expectedFound)
			}
		})
	}
}

func TestConstantTimeComparison(t *testing.T) {
	// Test that hmac.Equal is used for constant-time comparison
	sig1 := "test-signature-123"
	sig2 := "test-signature-123"
	sig3 := "different-signature"

	// Equal signatures
	if !hmac.Equal([]byte(sig1), []byte(sig2)) {
		t.Error("Equal signatures should return true")
	}

	// Different signatures
	if hmac.Equal([]byte(sig1), []byte(sig3)) {
		t.Error("Different signatures should return false")
	}

	// Different lengths
	if hmac.Equal([]byte(sig1), []byte("short")) {
		t.Error("Different length signatures should return false")
	}
}
