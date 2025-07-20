# Firebase Cloud Messaging Setup Guide

This guide will help you complete the Firebase FCM setup for your Flutter chat application.

## 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter project name: `flutter-chat-notifications`
4. Enable Google Analytics (optional)
5. Click "Create project"

## 2. Add Android App to Firebase

1. In Firebase Console, click "Add app" → Android
2. **Android package name**: `com.app.firebasenotifications`
3. **App nickname**: `Flutter Chat Android`
4. **Debug signing certificate SHA-1**: (optional for now)
5. Click "Register app"
6. **Download `google-services.json`**
7. Place the file in: `android/app/google-services.json`

## 3. Add iOS App to Firebase

1. In Firebase Console, click "Add app" → iOS
2. **iOS bundle ID**: `com.app.firebasenotifications`
3. **App nickname**: `Flutter Chat iOS`
4. Click "Register app"
5. **Download `GoogleService-Info.plist`**
6. Place the file in: `ios/Runner/GoogleService-Info.plist`

## 4. Update Android Configuration

### 4.1 Update `android/build.gradle`:
```gradle
buildscript {
    dependencies {
        // Add this line
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

### 4.2 Update `android/app/build.gradle`:
```gradle
// Add at the top
apply plugin: 'com.google.gms.google-services'

dependencies {
    // Add Firebase dependencies
    implementation 'com.google.firebase:firebase-messaging:23.4.0'
    implementation 'com.google.firebase:firebase-analytics:21.5.0'
}
```

### 4.3 Create notification resources in `android/app/src/main/res/`:

**Create `drawable/ic_notification.xml`:**
```xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24"
    android:tint="?attr/colorOnPrimary">
  <path
      android:fillColor="@android:color/white"
      android:pathData="M12,22c1.1,0 2,-0.9 2,-2h-4c0,1.1 0.89,2 2,2zM18,16v-5c0,-3.07 -1.64,-5.64 -4.5,-6.32V4c0,-0.83 -0.67,-1.5 -1.5,-1.5s-1.5,0.67 -1.5,1.5v0.68C7.63,5.36 6,7.92 6,11v5l-2,2v1h16v-1l-2,-2z"/>
</vector>
```

**Create `values/colors.xml`:**
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="notification_color">#FF009688</color>
</resources>
```

## 5. Update iOS Configuration

### 5.1 Add GoogleService-Info.plist to Xcode:
1. Open `ios/Runner.xcworkspace` in Xcode
2. Right-click on `Runner` folder
3. Select "Add Files to Runner"
4. Choose the `GoogleService-Info.plist` file
5. Make sure "Copy items if needed" is checked
6. Click "Add"

### 5.2 Update `ios/Runner/Info.plist`:
Add these keys inside the `<dict>` tag:
```xml
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
```

## 6. Update Firebase Options

Replace the placeholder values in `lib/firebase_options.dart` with your actual Firebase configuration:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_ANDROID_API_KEY_FROM_GOOGLE_SERVICES_JSON',
  appId: 'YOUR_ANDROID_APP_ID_FROM_GOOGLE_SERVICES_JSON',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  storageBucket: 'YOUR_PROJECT_ID.appspot.com',
);

static const FirebaseOptions ios = FirebaseOptions(
  apiKey: 'YOUR_IOS_API_KEY_FROM_GOOGLESERVICE_INFO_PLIST',
  appId: 'YOUR_IOS_APP_ID_FROM_GOOGLESERVICE_INFO_PLIST',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  iosBundleId: 'com.app.firebasenotifications',
);
```

## 7. Enable Cloud Messaging in Firebase Console

1. Go to Firebase Console → Your Project
2. Navigate to "Build" → "Cloud Messaging"
3. No additional setup required - FCM is enabled by default

## 8. Test FCM Token Generation

Run your app and check the console for the FCM token:
```
flutter run
```

Look for output like:
```
FCM Token: fGhJ...xyz123
```

## 9. Server-Side Integration

### 9.1 Get Server Key:
1. Firebase Console → Project Settings → Cloud Messaging
2. Copy the "Server key" (legacy) or create a new service account key

### 9.2 Send Test Notification:
```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "FCM_TOKEN_FROM_APP",
    "notification": {
      "title": "Test Message",
      "body": "Hello from Firebase!"
    },
    "data": {
      "type": "chat_message",
      "chatId": "test_chat_123",
      "senderId": "user_456",
      "senderName": "Test User",
      "message": "Hello from Firebase!",
      "timestamp": "2024-01-20T10:30:00Z"
    }
  }'
```

## 10. Troubleshooting

### Common Issues:

1. **Build Errors**: Make sure all Firebase dependencies are added correctly
2. **No Token**: Check if Firebase is initialized properly
3. **No Notifications**: Verify FCM is enabled and server key is correct
4. **iOS Issues**: Ensure GoogleService-Info.plist is added to Xcode project

### Debug Steps:

1. Check Firebase initialization logs
2. Verify FCM token is generated
3. Test with Firebase Console test message
4. Check notification permissions

## 11. Migration Complete!

Once you've completed these steps:

1. ✅ Firebase project created
2. ✅ Configuration files added
3. ✅ Android/iOS setup complete
4. ✅ FCM token generated
5. ✅ Test notifications working

Your app will have full Firebase Cloud Messaging support with reply actions!

## Next Steps

- Test notifications in all app states (foreground, background, terminated)
- Implement server-side notification sending
- Add user targeting and topic subscriptions
- Customize notification appearance and behavior
