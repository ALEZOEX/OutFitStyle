package external

import (
"context"
)

type PushMessage struct {
Title string
Body  string
Data  map[string]string
}

type PushSender interface {
Send(ctx context.Context, token string, msg PushMessage) error
}