package event_driven

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"testing"

	"github.com/segmentio/kafka-go"
)

const testSigningKey = "test-signing-key-12345"

func TestNewKafkaConsumer(t *testing.T) {
	tests := []struct {
		name       string
		signingKey string
		wantErr    bool
	}{
		{
			name:       "Valid signing key",
			signingKey: testSigningKey,
			wantErr:    false,
		},
		{
			name:       "Empty signing key",
			signingKey: "",
			wantErr:    true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			consumer, err := NewKafkaConsumer([]string{"localhost:9092"}, "test-topic", "test-group", tt.signingKey)
			if (err != nil) != tt.wantErr {
				t.Errorf("NewKafkaConsumer() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			if !tt.wantErr && consumer == nil {
				t.Error("NewKafkaConsumer() returned nil consumer")
			}
			if consumer != nil {
				consumer.Close()
			}
		})
	}
}

func TestVerifySignature(t *testing.T) {
	consumer, err := NewKafkaConsumer([]string{"localhost:9092"}, "test-topic", "test-group", testSigningKey)
	if err != nil {
		t.Fatalf("Failed to create consumer: %v", err)
	}
	defer consumer.Close()

	testData := []byte("test message data")

	// Generate valid signature
	h := hmac.New(sha256.New, []byte(testSigningKey))
	h.Write(testData)
	validSignature := base64.StdEncoding.EncodeToString(h.Sum(nil))

	tests := []struct {
		name      string
		data      []byte
		signature string
		expected  bool
	}{
		{
			name:      "Valid signature",
			data:      testData,
			signature: validSignature,
			expected:  true,
		},
		{
			name:      "Invalid signature",
			data:      testData,
			signature: "invalid-signature-xyz",
			expected:  false,
		},
		{
			name:      "Empty signature",
			data:      testData,
			signature: "",
			expected:  false,
		},
		{
			name:      "Modified data",
			data:      []byte("modified message data"),
			signature: validSignature,
			expected:  false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := consumer.verifySignature(tt.data, tt.signature)
			if result != tt.expected {
				t.Errorf("verifySignature() = %v, expected %v", result, tt.expected)
			}
		})
	}
}

func TestGetSignatureFromHeaders(t *testing.T) {
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
			sig, found := getSignatureFromHeaders(tt.headers)
			if sig != tt.expectedSig {
				t.Errorf("getSignatureFromHeaders() signature = %v, expected %v", sig, tt.expectedSig)
			}
			if found != tt.expectedFound {
				t.Errorf("getSignatureFromHeaders() found = %v, expected %v", found, tt.expectedFound)
			}
		})
	}
}

func TestVerifySignatureWithDifferentKeys(t *testing.T) {
	key1 := "signing-key-1"
	key2 := "signing-key-2"

	// Create signature with key1
	h := hmac.New(sha256.New, []byte(key1))
	testData := []byte("test message")
	h.Write(testData)
	signature := base64.StdEncoding.EncodeToString(h.Sum(nil))

	// Try to verify with consumer using key2
	consumer, err := NewKafkaConsumer([]string{"localhost:9092"}, "test-topic", "test-group", key2)
	if err != nil {
		t.Fatalf("Failed to create consumer: %v", err)
	}
	defer consumer.Close()

	// Should fail verification
	if consumer.verifySignature(testData, signature) {
		t.Error("Consumer with different key should reject signature")
	}
}
