package external

import (
	"context"
	"strings"

	"github.com/pkg/errors"
)

type PushMux struct {
	FCM  *FCMClient
	APNS *APNSClient
}

func (m *PushMux) Send(ctx context.Context, platform string, token string, msg PushMessage) error {
	platform = strings.ToLower(strings.TrimSpace(platform))

	switch platform {
	case "ios":
		if m.APNS == nil {
			return errors.New("apns sender not configured")
		}
		return m.APNS.Send(ctx, token, msg)
	case "android", "web":
		if m.FCM == nil {
			return errors.New("fcm sender not configured")
		}
		return m.FCM.Send(ctx, token, msg)
	default:
		return errors.Errorf("unknown platform: %s", platform)
	}
}
