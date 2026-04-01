package event_driven

import (
	"encoding/base64"
	"testing"
)

const testSigningKey = "test-signing-key-12345"

func TestNewKafkaPublisher(t *testing.T) {
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
			publisher, err := NewKafkaPublisher([]string{"localhost:9092"}, "test-topic", tt.signingKey)
			if (err != nil) != tt.wantErr {
				t.Errorf("NewKafkaPublisher() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			if !tt.wantErr && publisher == nil {
				t.Error("NewKafkaPublisher() returned nil publisher")
			}
			if publisher != nil {
				publisher.Close()
			}
		})
	}
}

func TestComputeSignature(t *testing.T) {
	publisher, err := NewKafkaPublisher([]string{"localhost:9092"}, "test-topic", testSigningKey)
	if err != nil {
		t.Fatalf("Failed to create publisher: %v", err)
	}
	defer publisher.Close()

	testData := []byte("test message data")
	signature := publisher.computeSignature(testData)

	// Verify signature is not empty
	if signature == "" {
		t.Error("Signature should not be empty")
	}

	// Verify signature is base64 encoded
	_, err = base64.StdEncoding.DecodeString(signature)
	if err != nil {
		t.Errorf("Signature should be valid base64: %v", err)
	}

	// Verify signature is deterministic
	signature2 := publisher.computeSignature(testData)
	if signature != signature2 {
		t.Error("Signature should be deterministic for same data")
	}

	// Verify different data produces different signature
	differentData := []byte("different message data")
	differentSignature := publisher.computeSignature(differentData)
	if signature == differentSignature {
		t.Error("Different data should produce different signature")
	}
}

func TestSignatureLength(t *testing.T) {
	publisher, err := NewKafkaPublisher([]string{"localhost:9092"}, "test-topic", testSigningKey)
	if err != nil {
		t.Fatalf("Failed to create publisher: %v", err)
	}
	defer publisher.Close()

	testData := []byte("test")
	signature := publisher.computeSignature(testData)

	// HMAC-SHA256 produces 32 bytes, base64 encoded should be 44 characters
	decoded, err := base64.StdEncoding.DecodeString(signature)
	if err != nil {
		t.Fatalf("Failed to decode signature: %v", err)
	}

	if len(decoded) != 32 {
		t.Errorf("Decoded signature length = %d, expected 32 bytes", len(decoded))
	}
}
