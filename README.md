# Firebase Notifications with Native Functionality

This Flutter app demonstrates a comprehensive Firebase notification system that works even when the app is closed or removed from the background, similar to WhatsApp. It includes native functionality for both Android and iOS platforms.

## Features

- ✅ **Background Notifications**: Works when app is closed, minimized, or removed from background
- ✅ **Quick Reply**: Reply to notifications directly from the notification panel (like WhatsApp)
- ✅ **Native Implementation**: Uses native Android and iOS code for reliable background processing
- ✅ **Foreground Notifications**: Shows notifications even when app is open
- ✅ **Notification Actions**: Mark as read, reply, and other custom actions
- ✅ **FCM Token Management**: Automatic token refresh and storage
- ✅ **Permission Handling**: Proper permission requests for notifications

## Setup Instructions

### 1. Firebase Configuration

1. **Create a Firebase Project**:
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project or use an existing one

2. **Add Android App**:
   - Click "Add app" → Android
   - Use package name: `com.example.firebasenotifications`
   - Download `google-services.json` and place it in `android/app/`

3. **Add iOS App**:
   - Click "Add app" → iOS
   - Use bundle ID: `com.example.firebasenotifications`
   - Download `GoogleService-Info.plist` and place it in `ios/Runner/`

### 2. Dependencies

The following dependencies are already included in `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^3.15.1
  firebase_messaging: ^15.2.9
  flutter_local_notifications: ^18.0.1
  permission_handler: ^11.3.1
  shared_preferences: ^2.2.3
```

### 3. Platform Configuration

#### Android
- Permissions are already configured in `android/app/src/main/AndroidManifest.xml`
- Notification channel is set up for high-priority notifications
- Background service is configured for Firebase messaging

#### iOS
- Background modes are configured in `ios/Runner/Info.plist`
- Notification capabilities are enabled
- AppDelegate is configured for Firebase messaging

### 4. Running the App

```bash
# Install dependencies
flutter pub get

# Run on Android
flutter run

# Run on iOS
flutter run -d ios
```

## How It Works

### 1. Background Message Handling

The app uses a top-level function `_firebaseMessagingBackgroundHandler` that handles messages when the app is completely closed:

```dart
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await _showBackgroundNotification(message);
}
```

### 2. Native Implementation

#### Android
- Custom `MainActivity.kt` handles notification actions
- Method channel communication between native and Flutter
- Background service for reliable message processing

#### iOS
- Enhanced `AppDelegate.swift` with Firebase messaging delegate
- UNUserNotificationCenterDelegate for notification handling
- Background processing capabilities

### 3. Quick Reply Functionality

The notification system includes quick reply actions:

```dart
const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
  'high_importance_channel',
  'High Importance Notifications',
  actions: [
    AndroidNotificationAction('reply', 'Reply', showsUserInterface: true),
    AndroidNotificationAction('mark_read', 'Mark as Read'),
  ],
);
```

## Testing Notifications

### 1. Using Firebase Console

1. Go to Firebase Console → Messaging
2. Create a new campaign
3. Target your app
4. Send a test message

### 2. Using FCM API

You can send notifications using the FCM API:

```bash
curl -X POST -H "Authorization: key=YOUR_SERVER_KEY" \
     -H "Content-Type: application/json" \
     -d '{
       "to": "DEVICE_FCM_TOKEN",
       "notification": {
         "title": "Test Notification",
         "body": "This is a test message"
       },
       "data": {
         "message_id": "123",
         "sender_id": "test_user",
         "sender_name": "Test User"
       }
     }' \
     https://fcm.googleapis.com/fcm/send
```

### 3. App Testing

The app includes a test button that simulates receiving a notification. You can test:

- **Foreground**: App is open
- **Background**: App is minimized
- **Terminated**: App is completely closed

## File Structure

```
lib/
├── main.dart                 # Main app with notification demo UI
├── services/
│   └── notification_service.dart  # Core notification handling
└── models/
    └── message.dart          # Message data model

android/app/src/main/
├── AndroidManifest.xml       # Android permissions and services
├── kotlin/com/example/firebasenotifications/
│   └── MainActivity.kt       # Native Android notification handling
└── res/values/
    └── colors.xml            # Notification color resources

ios/Runner/
├── AppDelegate.swift         # Native iOS notification handling
└── Info.plist               # iOS capabilities and permissions
```

## Key Components

### NotificationService
- Singleton service for managing notifications
- Handles FCM token management
- Processes foreground and background messages
- Manages local notifications

### Message Model
- Structured data for messages
- Support for replies and read status
- JSON serialization for storage

### Native Handlers
- Android: Kotlin implementation for reliable background processing
- iOS: Swift implementation with proper delegate methods

## Troubleshooting

### Common Issues

1. **Notifications not showing when app is closed**:
   - Ensure background modes are enabled in iOS
   - Check Android manifest permissions
   - Verify Firebase configuration

2. **Quick reply not working**:
   - Check notification channel configuration
   - Ensure actions are properly defined
   - Verify native code implementation

3. **FCM token not generating**:
   - Check Firebase configuration files
   - Ensure internet connectivity
   - Verify app permissions

### Debug Tips

- Check console logs for FCM token generation
- Monitor notification delivery in Firebase Console
- Test with different app states (foreground/background/terminated)

#add in app/build.gradle.kts

    compileOptions {
        isCoreLibraryDesugaringEnabled = true

        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    dependencies {
         implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
         coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
    }

## Next Steps

To integrate this into your production app:

1. **Backend Integration**: Connect to your backend API for message storage
2. **User Authentication**: Add user authentication for targeted notifications
3. **Message Persistence**: Implement local database for message history
4. **Push Notifications**: Set up server-side notification sending
5. **Analytics**: Add notification analytics and tracking

## License

This project is open source and available under the MIT License.
