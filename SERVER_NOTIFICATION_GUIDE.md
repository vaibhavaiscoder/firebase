# OneSignal Server-Side Notification Guide

This guide explains how to send notifications from your server to the Flutter chat application with proper data structure for reply functionality.

## OneSignal REST API Configuration

### Base URL
```
https://onesignal.com/api/v1/notifications
```

### Headers Required
```
Content-Type: application/json; charset=utf-8
Authorization: Basic YOUR_REST_API_KEY
```

## Notification Payload Structure

### Basic Chat Message Notification

```json
{
  "app_id": "e3f2d92d-3a53-4d20-ae76-cb439d5adbb4",
  "include_external_user_ids": ["receiver_user_id"],
  "headings": {
    "en": "New Message from John"
  },
  "contents": {
    "en": "Hey! How are you doing?"
  },
  "data": {
    "type": "chat_message",
    "chatId": "chat_123",
    "senderId": "user_456",
    "senderName": "John Doe",
    "message": "Hey! How are you doing?",
    "timestamp": "2024-01-20T10:30:00Z"
  },
  "android_channel_id": "chat_notifications",
  "priority": 10,
  "ttl": 3600
}
```

### Enhanced Notification with Reply Action (Android)

```json
{
  "app_id": "e3f2d92d-3a53-4d20-ae76-cb439d5adbb4",
  "include_external_user_ids": ["receiver_user_id"],
  "headings": {
    "en": "John Doe"
  },
  "contents": {
    "en": "Hey! How are you doing?"
  },
  "data": {
    "type": "chat_message",
    "chatId": "chat_123",
    "senderId": "user_456",
    "senderName": "John Doe",
    "message": "Hey! How are you doing?",
    "timestamp": "2024-01-20T10:30:00Z"
  },
  "android_channel_id": "chat_notifications",
  "priority": 10,
  "ttl": 3600,
  "buttons": [
    {
      "id": "reply_button",
      "text": "Reply",
      "icon": "ic_reply"
    }
  ],
  "android_accent_color": "FF009688",
  "android_visibility": 1,
  "android_led_color": "FF009688",
  "android_sound": "notification_sound",
  "android_group": "chat_messages"
}
```

## Server Implementation Examples

### Node.js Example

```javascript
const axios = require('axios');

class OneSignalService {
  constructor() {
    this.appId = 'e3f2d92d-3a53-4d20-ae76-cb439d5adbb4';
    this.restApiKey = 'YOUR_REST_API_KEY'; // Replace with your actual REST API key
    this.baseUrl = 'https://onesignal.com/api/v1/notifications';
  }

  async sendChatNotification({
    receiverUserId,
    senderName,
    message,
    chatId,
    senderId
  }) {
    const payload = {
      app_id: this.appId,
      include_external_user_ids: [receiverUserId],
      headings: { en: senderName },
      contents: { en: message },
      data: {
        type: 'chat_message',
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        message: message,
        timestamp: new Date().toISOString()
      },
      android_channel_id: 'chat_notifications',
      priority: 10,
      ttl: 3600,
      buttons: [
        {
          id: 'reply_button',
          text: 'Reply',
          icon: 'ic_reply'
        }
      ]
    };

    try {
      const response = await axios.post(this.baseUrl, payload, {
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': `Basic ${this.restApiKey}`
        }
      });

      console.log('Notification sent successfully:', response.data);
      return response.data;
    } catch (error) {
      console.error('Error sending notification:', error.response?.data || error.message);
      throw error;
    }
  }

  async sendGroupChatNotification({
    receiverUserIds,
    senderName,
    message,
    chatId,
    senderId,
    groupName
  }) {
    const payload = {
      app_id: this.appId,
      include_external_user_ids: receiverUserIds,
      headings: { en: `${senderName} in ${groupName}` },
      contents: { en: message },
      data: {
        type: 'chat_message',
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        message: message,
        groupName: groupName,
        timestamp: new Date().toISOString()
      },
      android_channel_id: 'chat_notifications',
      priority: 10,
      ttl: 3600
    };

    try {
      const response = await axios.post(this.baseUrl, payload, {
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': `Basic ${this.restApiKey}`
        }
      });

      return response.data;
    } catch (error) {
      console.error('Error sending group notification:', error.response?.data || error.message);
      throw error;
    }
  }
}

// Usage example
const oneSignalService = new OneSignalService();

// Send a chat notification
oneSignalService.sendChatNotification({
  receiverUserId: 'user_123',
  senderName: 'John Doe',
  message: 'Hello! How are you?',
  chatId: 'chat_456',
  senderId: 'user_789'
});
```

### Python Example

```python
import requests
import json
from datetime import datetime

class OneSignalService:
    def __init__(self):
        self.app_id = 'e3f2d92d-3a53-4d20-ae76-cb439d5adbb4'
        self.rest_api_key = 'YOUR_REST_API_KEY'  # Replace with your actual REST API key
        self.base_url = 'https://onesignal.com/api/v1/notifications'
    
    def send_chat_notification(self, receiver_user_id, sender_name, message, chat_id, sender_id):
        payload = {
            'app_id': self.app_id,
            'include_external_user_ids': [receiver_user_id],
            'headings': {'en': sender_name},
            'contents': {'en': message},
            'data': {
                'type': 'chat_message',
                'chatId': chat_id,
                'senderId': sender_id,
                'senderName': sender_name,
                'message': message,
                'timestamp': datetime.now().isoformat()
            },
            'android_channel_id': 'chat_notifications',
            'priority': 10,
            'ttl': 3600,
            'buttons': [
                {
                    'id': 'reply_button',
                    'text': 'Reply',
                    'icon': 'ic_reply'
                }
            ]
        }
        
        headers = {
            'Content-Type': 'application/json; charset=utf-8',
            'Authorization': f'Basic {self.rest_api_key}'
        }
        
        try:
            response = requests.post(self.base_url, json=payload, headers=headers)
            response.raise_for_status()
            print('Notification sent successfully:', response.json())
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f'Error sending notification: {e}')
            raise e

# Usage example
onesignal_service = OneSignalService()
onesignal_service.send_chat_notification(
    receiver_user_id='user_123',
    sender_name='John Doe',
    message='Hello! How are you?',
    chat_id='chat_456',
    sender_id='user_789'
)
```

### PHP Example

```php
<?php

class OneSignalService {
    private $appId = 'e3f2d92d-3a53-4d20-ae76-cb439d5adbb4';
    private $restApiKey = 'YOUR_REST_API_KEY'; // Replace with your actual REST API key
    private $baseUrl = 'https://onesignal.com/api/v1/notifications';
    
    public function sendChatNotification($receiverUserId, $senderName, $message, $chatId, $senderId) {
        $payload = [
            'app_id' => $this->appId,
            'include_external_user_ids' => [$receiverUserId],
            'headings' => ['en' => $senderName],
            'contents' => ['en' => $message],
            'data' => [
                'type' => 'chat_message',
                'chatId' => $chatId,
                'senderId' => $senderId,
                'senderName' => $senderName,
                'message' => $message,
                'timestamp' => date('c')
            ],
            'android_channel_id' => 'chat_notifications',
            'priority' => 10,
            'ttl' => 3600,
            'buttons' => [
                [
                    'id' => 'reply_button',
                    'text' => 'Reply',
                    'icon' => 'ic_reply'
                ]
            ]
        ];
        
        $headers = [
            'Content-Type: application/json; charset=utf-8',
            'Authorization: Basic ' . $this->restApiKey
        ];
        
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $this->baseUrl);
        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HEADER, false);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        if ($httpCode === 200) {
            echo "Notification sent successfully: " . $response;
            return json_decode($response, true);
        } else {
            echo "Error sending notification. HTTP Code: " . $httpCode . " Response: " . $response;
            return false;
        }
    }
}

// Usage example
$oneSignalService = new OneSignalService();
$oneSignalService->sendChatNotification(
    'user_123',
    'John Doe',
    'Hello! How are you?',
    'chat_456',
    'user_789'
);
?>
```

## Important Data Fields

### Required Fields for Chat Notifications

1. **type**: Must be `"chat_message"` for proper handling
2. **chatId**: Unique identifier for the chat/conversation
3. **senderId**: ID of the user sending the message
4. **senderName**: Display name of the sender
5. **message**: The actual message content
6. **timestamp**: ISO 8601 formatted timestamp

### Optional Fields

1. **groupName**: For group chat notifications
2. **messageType**: text, image, file, etc.
3. **attachmentUrl**: URL for media messages
4. **priority**: Message priority level

## Testing Your Implementation

### Using cURL

```bash
curl -X POST \
  https://onesignal.com/api/v1/notifications \
  -H 'Authorization: Basic YOUR_REST_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "app_id": "e3f2d92d-3a53-4d20-ae76-cb439d5adbb4",
    "include_external_user_ids": ["test_user_123"],
    "headings": {"en": "Test Sender"},
    "contents": {"en": "This is a test message"},
    "data": {
      "type": "chat_message",
      "chatId": "test_chat_123",
      "senderId": "test_sender_456",
      "senderName": "Test Sender",
      "message": "This is a test message",
      "timestamp": "2024-01-20T10:30:00Z"
    },
    "android_channel_id": "chat_notifications"
  }'
```

## Best Practices

1. **Always include the `type: "chat_message"` field** for proper app handling
2. **Use external user IDs** instead of player IDs for better user management
3. **Set appropriate TTL** (time to live) for messages
4. **Use consistent chatId format** across your application
5. **Include timestamp** for message ordering
6. **Test notifications** in all app states (foreground, background, terminated)
7. **Handle notification failures** gracefully in your server code
8. **Use appropriate priority levels** for different message types

## Troubleshooting

### Common Issues

1. **Notifications not received**: Check if user has granted notification permissions
2. **Reply action not working**: Ensure Android implementation is correct
3. **App not opening correct chat**: Verify chatId and senderId in payload
4. **Background notifications not handled**: Check background message handler implementation

### Debug Steps

1. Check OneSignal dashboard for delivery status
2. Verify REST API key and App ID
3. Test with OneSignal's testing tools
4. Check device logs for error messages
5. Ensure external user ID is set correctly in the app

## Security Considerations

1. **Never expose REST API key** in client-side code
2. **Validate user permissions** before sending notifications
3. **Sanitize message content** to prevent XSS attacks
4. **Use HTTPS** for all API calls
5. **Implement rate limiting** to prevent spam


api key: os_v2_app_4pznslj2kngsbltwznbz2ww3wq6jix7htuou4inkttxzdfvcbsnaqjnd6dyyvy6a7sclzggipcium7jusxzt3bf2vpe2nyv4ukwrvaa
