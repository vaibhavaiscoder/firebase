# Flutter Chat App with OneSignal - Testing Guide

This guide provides comprehensive testing instructions for your Flutter chat application with OneSignal notifications and reply functionality.

## Prerequisites

Before testing, ensure you have:

1. **OneSignal Account Setup**
   - App ID: `e3f2d92d-3a53-4d20-ae76-cb439d5adbb4`
   - REST API Key (for server-side testing)
   - iOS and Android platform configurations

2. **Development Environment**
   - Flutter SDK installed
   - Android Studio / Xcode for platform-specific testing
   - Physical devices for push notification testing (simulators have limitations)

## Testing Checklist

### 1. Initial Setup Testing

#### Flutter Dependencies
```bash
cd /Users/vaibhavghugase/Desktop/projects/pg/onesignalnoti
flutter pub get
flutter doctor
```

#### Build and Run
```bash
# Android
flutter run -d android

# iOS
flutter run -d ios
```

### 2. OneSignal Integration Testing

#### Check OneSignal Initialization
1. Launch the app
2. Check console logs for OneSignal initialization messages
3. Verify notification permission request appears
4. Grant notification permissions

#### Verify Player ID Registration
```dart
// Add this to your test code to verify OneSignal registration
Future<void> testOneSignalSetup() async {
  final playerId = await NotificationService.getPlayerId();
  print('OneSignal Player ID: $playerId');
  
  // Set external user ID for testing
  await NotificationService.setExternalUserId('test_user_123');
  
  final externalId = await NotificationService.getExternalUserId();
  print('External User ID: $externalId');
}
```

### 3. Notification State Testing

#### Foreground Notifications
1. **Setup**: App is open and visible
2. **Action**: Send a test notification using OneSignal dashboard or API
3. **Expected**: Custom in-app notification appears
4. **Verify**: 
   - Notification content displays correctly
   - Reply button is visible (Android)
   - Tap actions work properly

#### Background Notifications
1. **Setup**: App is running but not visible (home screen)
2. **Action**: Send a test notification
3. **Expected**: System notification appears in notification panel
4. **Verify**:
   - Notification shows with reply action
   - Tapping notification opens correct chat
   - Reply from notification panel works

#### Terminated State Notifications
1. **Setup**: Force close the app completely
2. **Action**: Send a test notification
3. **Expected**: System notification appears
4. **Verify**:
   - Notification appears even when app is closed
   - Tapping notification launches app and opens correct chat
   - Reply functionality works

### 4. Reply Action Testing

#### Android Reply Testing
1. Send a chat notification to the device
2. Pull down notification panel
3. Look for "Reply" button/action
4. Tap reply and type a message
5. Send the reply
6. **Verify**:
   - Reply message is saved to database
   - Reply is sent via chat service
   - Original notification is dismissed
   - Reply appears in chat conversation

#### iOS Reply Testing
1. Send a chat notification to iOS device
2. Long press or 3D touch the notification
3. Look for "Reply" action
4. Type message in the text input
5. Send the reply
6. **Verify**:
   - Reply functionality works similar to Android
   - Message is processed correctly

### 5. Server-Side Testing

#### Using cURL (Replace with your REST API key)
```bash
curl -X POST \
  https://onesignal.com/api/v1/notifications \
  -H 'Authorization: Basic YOUR_REST_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "app_id": "e3f2d92d-3a53-4d20-ae76-cb439d5adbb4",
    "include_external_user_ids": ["test_user_123"],
    "headings": {"en": "John Doe"},
    "contents": {"en": "Hey! How are you doing?"},
    "data": {
      "type": "chat_message",
      "chatId": "test_chat_123",
      "senderId": "user_456",
      "senderName": "John Doe",
      "message": "Hey! How are you doing?",
      "timestamp": "2024-01-20T10:30:00Z"
    },
    "android_channel_id": "chat_notifications",
    "ios_category": "CHAT_MESSAGE"
  }'
```

#### Using OneSignal Dashboard
1. Go to OneSignal dashboard
2. Navigate to Messages > New Push
3. Select your app
4. Configure message:
   - **Audience**: Specific users (use external user ID)
   - **Message**: Set title and content
   - **Additional Data**: Add the required fields:
     ```json
     {
       "type": "chat_message",
       "chatId": "test_chat_123",
       "senderId": "user_456",
       "senderName": "Test User",
       "message": "Test message content",
       "timestamp": "2024-01-20T10:30:00Z"
     }
     ```
5. Send the notification

### 6. Database Testing

#### Verify Message Storage
```dart
// Test database operations
Future<void> testDatabaseOperations() async {
  // Insert test message
  final testMessage = Message(
    id: 'test_123',
    senderId: 'user_456',
    receiverId: 'user_789',
    message: 'Test message',
    timestamp: DateTime.now(),
  );
  
  await DatabaseHelper.insertMessage(testMessage);
  
  // Retrieve messages
  final messages = await DatabaseHelper.getMessages('user_456', 'user_789');
  print('Retrieved ${messages.length} messages');
  
  // Verify the test message exists
  final foundMessage = messages.firstWhere((m) => m.id == 'test_123');
  print('Found test message: ${foundMessage.message}');
}
```

### 7. UI Testing

#### Chat List Screen
- [ ] Displays list of conversations
- [ ] Shows last message and timestamp
- [ ] Navigates to chat screen on tap
- [ ] Updates in real-time when new messages arrive

#### Chat Screen
- [ ] Displays conversation messages
- [ ] Shows sender information correctly
- [ ] Message input field works
- [ ] Send button functionality
- [ ] Real-time message updates
- [ ] Proper message ordering by timestamp

#### In-App Notifications
- [ ] Custom notification overlay appears
- [ ] Displays correct sender and message
- [ ] Reply button navigates to chat
- [ ] Dismiss functionality works

### 8. Platform-Specific Testing

#### Android Specific
- [ ] Notification channel is created properly
- [ ] Reply action appears in notification panel
- [ ] RemoteInput functionality works
- [ ] Broadcast receiver handles replies
- [ ] Method channel communication works
- [ ] App badge updates (if implemented)

#### iOS Specific
- [ ] Notification categories are registered
- [ ] UNTextInputNotificationAction works
- [ ] Reply text input appears
- [ ] Method channel communication works
- [ ] Background app refresh works

### 9. Edge Cases Testing

#### Network Connectivity
- [ ] App handles offline state gracefully
- [ ] Messages queue when offline
- [ ] Sync when connection restored
- [ ] Notification delivery in poor network conditions

#### Permission Handling
- [ ] App requests notification permissions
- [ ] Handles permission denial gracefully
- [ ] Shows appropriate UI when permissions denied
- [ ] Re-requests permissions when needed

#### Memory and Performance
- [ ] App doesn't crash with many notifications
- [ ] Database queries are efficient
- [ ] UI remains responsive during notification handling
- [ ] Memory usage is reasonable

### 10. Debugging Common Issues

#### Notifications Not Received
1. Check notification permissions in device settings
2. Verify OneSignal player ID registration
3. Check external user ID is set correctly
4. Verify REST API key and App ID
5. Check OneSignal dashboard for delivery status

#### Reply Action Not Working
1. Verify Android notification helper implementation
2. Check method channel names match
3. Ensure broadcast receiver is registered
4. Verify iOS notification categories are set up
5. Check console logs for errors

#### App Not Opening Correct Chat
1. Verify chatId and senderId in notification payload
2. Check navigation logic in notification click handler
3. Ensure route parameters are passed correctly
4. Verify chat screen handles parameters properly

#### Database Issues
1. Check database initialization
2. Verify table creation
3. Test CRUD operations manually
4. Check for SQL syntax errors
5. Verify data types match model

### 11. Performance Testing

#### Load Testing
- Send multiple notifications rapidly
- Test with large message history
- Verify app performance with many conversations
- Check memory usage over time

#### Battery Usage
- Monitor battery consumption during testing
- Test background notification handling efficiency
- Verify app doesn't drain battery excessively

### 12. Security Testing

#### Data Validation
- Test with malformed notification payloads
- Verify input sanitization
- Check for SQL injection vulnerabilities
- Test with extremely long messages

#### Permission Security
- Verify app only requests necessary permissions
- Check data is stored securely
- Ensure sensitive data is not logged

## Test Scenarios

### Scenario 1: Basic Chat Flow
1. User A sends message to User B
2. User B receives notification (background)
3. User B replies from notification panel
4. User A receives the reply
5. Both users can see full conversation

### Scenario 2: Group Chat
1. User A sends message to group
2. All group members receive notifications
3. User B replies from notification
4. All members see the reply
5. Conversation continues normally

### Scenario 3: App State Transitions
1. Send notification while app is foreground
2. Move app to background, send another
3. Force close app, send third notification
4. Verify all notifications handled correctly

## Automated Testing

### Unit Tests
```dart
// Example unit test for notification service
import 'package:flutter_test/flutter_test.dart';
import 'package:onesignalnoti/notificationService.dart';

void main() {
  group('NotificationService Tests', () {
    test('should initialize OneSignal correctly', () async {
      await NotificationService.initialize();
      // Add assertions
    });
    
    test('should handle notification data correctly', () {
      final testData = {
        'type': 'chat_message',
        'chatId': 'test_123',
        'senderId': 'user_456',
        'message': 'Test message'
      };
      
      // Test notification handling logic
    });
  });
}
```

### Integration Tests
```dart
// Example integration test
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:onesignalnoti/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Chat App Integration Tests', () {
    testWidgets('should handle notification and navigate to chat', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Simulate notification tap
      // Verify navigation to chat screen
      // Check message display
    });
  });
}
```

## Monitoring and Analytics

### OneSignal Analytics
- Monitor delivery rates
- Track click-through rates
- Analyze user engagement
- Check for failed deliveries

### App Analytics
- Track notification open rates
- Monitor reply usage
- Measure user engagement
- Identify performance bottlenecks

## Troubleshooting Checklist

- [ ] OneSignal SDK initialized correctly
- [ ] Notification permissions granted
- [ ] Player ID registered
- [ ] External user ID set
- [ ] Notification payload format correct
- [ ] Method channels configured properly
- [ ] Database operations working
- [ ] UI navigation functioning
- [ ] Platform-specific code implemented
- [ ] Background modes enabled (iOS)
- [ ] Notification channels created (Android)

## Success Criteria

Your implementation is successful when:

1. ✅ Notifications are received in all app states
2. ✅ Reply actions work from notification panel
3. ✅ Messages are saved and synced correctly
4. ✅ UI updates in real-time
5. ✅ Navigation works properly
6. ✅ Performance is acceptable
7. ✅ No crashes or memory leaks
8. ✅ Cross-platform compatibility
9. ✅ Server integration works
10. ✅ User experience is smooth

## Next Steps

After successful testing:

1. **Production Deployment**
   - Configure production OneSignal app
   - Set up proper server infrastructure
   - Implement proper error handling
   - Add logging and monitoring

2. **Feature Enhancements**
   - Add media message support
   - Implement read receipts
   - Add typing indicators
   - Support group chat features

3. **Optimization**
   - Optimize database queries
   - Implement message pagination
   - Add offline support
   - Improve battery efficiency
