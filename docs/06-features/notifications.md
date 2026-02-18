# Notifications System

## Overview

The OutfitStyle notification system supports various types of notifications to keep users engaged and informed.

## Notification Types

### Weather-Based Notifications
- Daily outfit recommendations based on weather
- Weather change alerts
- Seasonal clothing reminders

### System Notifications
- Subscription status updates
- Trial period reminders
- Feature announcements

### Engagement Notifications
- Style tips and suggestions
- Wardrobe completion reminders
- Personalized recommendations

## Architecture

### Notification Structure

The `CreateNotificationParams` structure includes:

```go
type CreateNotificationParams struct {
    UserID    uuid.UUID
    Title     string
    Message   string
    Type      string
    ImageURL  *string  // Optional image for rich notifications
    Metadata  json.RawMessage
}
```

### Current Implementation

Currently, the system supports:
- Emoji-based notifications
- Text-only notifications
- Basic push notifications

## Image Support

### Current Status

The `ImageURL` field is available but the following is not yet implemented:
- Image storage and delivery system
- Image size, format, and quality requirements
- Push notification image delivery testing

### Future Enhancements

#### 1. Image Storage System
- S3-compatible storage integration
- Automatic thumbnail generation
- Image optimization for mobile devices

#### 2. Rich Notifications
- Image support in push notifications
- Fallback options for unsupported platforms
- Notification image caching

#### 3. Other Application Areas
- User profiles
- Clothing items
- Recommendations
- Achievements
- Catalogs

## Technical Requirements

### Formats
- Primary: JPEG, PNG
- Icons: WebP, SVG
- Animated: GIF (limited)

### Sizes
- Notifications: up to 250KB
- Profiles: up to 2MB
- Catalog: up to 5MB

### Security
- MIME type validation
- Image sanitization
- Antivirus scanning

## Implementation Plan

1. **Current**: Use emoji and text
2. **Later**: Add basic image support
3. **Future**: Full-featured media management system

## UX Considerations

- Don't overload notifications with images
- Ensure accessibility for users with disabilities
- Provide options to disable images in notifications
- Respect user preferences for notification content

## Push Notification Integration

### Firebase Cloud Messaging

The app integrates with FCM for push notifications:

```dart
class NotificationService {
  // Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    _showLocalNotification(message);
  });

  // Handle background messages
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    _handleNotificationTap(message);
  });
}
```

### Notification Types Supported

- Daily outfit recommendations
- Weather alerts
- Re-engagement campaigns
- Social sharing notifications

## Best Practices

### Content
- Keep messages concise and relevant
- Use personalization when possible
- Include clear call-to-action
- Respect user timezone

### Timing
- Send notifications at appropriate times
- Avoid late night/early morning notifications
- Consider user activity patterns
- Implement frequency capping

### User Control
- Allow users to customize notification preferences
- Provide easy opt-out options
- Respect Do Not Disturb settings
- Honor platform notification settings
