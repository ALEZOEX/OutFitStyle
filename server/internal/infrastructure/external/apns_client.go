package external

import (
	"context"
	"encoding/json"
	"os"

	"github.com/pkg/errors"
	"github.com/sideshow/apns2"
	"github.com/sideshow/apns2/token"
)

type APNSClient struct {
	client   *apns2.Client
	bundleID string
}

func NewAPNSClient(keyFile, keyID, teamID, bundleID, env string) (*APNSClient, error) {
	if keyFile == "" || keyID == "" || teamID == "" || bundleID == "" {
		return nil, errors.New("APNS config is not set (APNS_KEY_FILE/APNS_KEY_ID/APNS_TEAM_ID/APNS_BUNDLE_ID)")
	}

	keyBytes, err := os.ReadFile(keyFile)
	if err != nil {
		return nil, errors.Wrap(err, "read apns key file")
	}

	authKey, err := token.AuthKeyFromBytes(keyBytes)
	if err != nil {
		return nil, errors.Wrap(err, "parse apns auth key")
	}

	tok := &token.Token{
		AuthKey: authKey,
		KeyID:   keyID,
		TeamID:  teamID,
	}

	var c *apns2.Client
	if env == "production" {
		c = apns2.NewTokenClient(tok).Production()
	} else {
		c = apns2.NewTokenClient(tok).Development()
	}

	return &APNSClient{client: c, bundleID: bundleID}, nil
}

func (c *APNSClient) Send(ctx context.Context, deviceToken string, msg PushMessage) error {
	payload := map[string]any{
		"aps": map[string]any{
			"alert": map[string]any{
				"title": msg.Title,
				"body":  msg.Body,
			},
			"sound": "default",
		},
	}
	// data → в корень payload (часто так делают), или в custom key
	if len(msg.Data) > 0 {
		payload["data"] = msg.Data
	}

	b, _ := json.Marshal(payload)
	n := &apns2.Notification{
		DeviceToken: deviceToken,
		Topic:       c.bundleID,
		Payload:     b,
	}

	res, err := c.client.PushWithContext(ctx, n)
	if err != nil {
		return errors.Wrap(err, "apns push")
	}
	if !res.Sent() {
		return errors.Errorf("apns not sent: status=%d reason=%s", res.StatusCode, res.Reason)
	}
	return nil
}
