package external

import (
"context"

firebase "firebase.google.com/go/v4"
"firebase.google.com/go/v4/messaging"
"github.com/pkg/errors"
"google.golang.org/api/option"
)

type FCMClient struct {
m *messaging.Client
}

func NewFCMClient(ctx context.Context, credentialsFile string) (*FCMClient, error) {
if credentialsFile == "" {
return nil, errors.New("FCM credentials file is not set")
}

app, err := firebase.NewApp(ctx, nil, option.WithCredentialsFile(credentialsFile))
if err != nil {
return nil, errors.Wrap(err, "init firebase app")
}

m, err := app.Messaging(ctx)
if err != nil {
return nil, errors.Wrap(err, "init messaging client")
}

return &FCMClient{m: m}, nil
}

func (c *FCMClient) Send(ctx context.Context, token string, msg PushMessage) error {
m := &messaging.Message{
Token: token,
Notification: &messaging.Notification{
Title: msg.Title,
Body:  msg.Body,
},
Data: msg.Data,
}
_, err := c.m.Send(ctx, m)
return errors.Wrap(err, "fcm send")
}