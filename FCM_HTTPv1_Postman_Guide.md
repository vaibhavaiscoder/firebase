# 🔔 Sending FCM Notification using HTTP v1 API via Postman

This README provides a step-by-step guide to send push notifications using Firebase Cloud Messaging (FCM) HTTP v1 API with Postman.

---

## ✅ Prerequisites

- Firebase project
- Device registered with FCM (you must have the `FCM_DEVICE_TOKEN`)
- Firebase service account JSON file
- Access token (OAuth2 Bearer token) generated from service account

---

## 🔐 1. Get Access Token

Use the following Dart code or gcloud CLI to get the Bearer token:

### Dart Code (example)
```dart
final accessToken = await getAccessToken(); // Use your Dart code here
```

### gcloud CLI
```bash
gcloud auth activate-service-account --key-file=service-account.json
gcloud auth application-default print-access-token
```

---

## 🛠️ 2. Postman Setup

### Request Type: `POST`

### URL:
```
https://fcm.googleapis.com/v1/projects/631200803564/messages:send
```

### Headers:

| Key            | Value                                      |
|----------------|--------------------------------------------|
| Authorization  | Bearer YOUR_ACCESS_TOKEN (copy from above) |
| Content-Type   | application/json                           |

### Body (raw → JSON):
```json
{
  "message": {
    "token": "FCM_DEVICE_TOKEN",
    "notification": {
      "title": "John Doe",
      "body": "Hey! How are you doing?"
    },
    "data": {
      "type": "chat_message",
      "chatId": "chat_123",
      "senderId": "user_456",
      "senderName": "John Doe",
      "message": "Hey! How are you doing?",
      "timestamp": "2024-01-20T10:30:00Z"
    },
    "android": {
      "priority": "HIGH",
      "notification": {
        "channel_id": "chat_notifications",
        "sound": "default"
      }
    },
    "apns": {
      "payload": {
        "aps": {
          "category": "CHAT_MESSAGE",
          "sound": "default"
        }
      }
    }
  }
}
```

---

## ✅ Notes

- `priority` must be set at the `android` level, not inside `android.notification`.
- Replace `FCM_DEVICE_TOKEN` and `YOUR_ACCESS_TOKEN` with actual values.
- Ensure your service account has Firebase Cloud Messaging access permissions.

---

## 📦 Response

A successful request will return a response like:
```json
{
  "name": "projects/PROJECT_ID/messages/0:abcdef1234567890%..."
}
```

---

## 🧾 References

- [FCM HTTP v1 Documentation](https://firebase.google.com/docs/cloud-messaging/send-message)
- [OAuth2 for Service Accounts](https://developers.google.com/identity/protocols/oauth2/service-account)