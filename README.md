# 📲 onesignalnoti

A Flutter app integrated with [OneSignal](https://onesignal.com) for push notifications on both **Android** and **iOS** platforms.

---

## 🚀 Features

- Push notifications via OneSignal
- Supports Android & iOS
- OneSignal foreground and background handling
- Flutter clean architecture with minimal setup

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  onesignal_flutter: ^5.1.0 # Check pub.dev for latest version
```

---

## 🔧 Setup Instructions

### ✅ OneSignal Setup

1. Go to [https://onesignal.com](https://onesignal.com) and create a project.
2. Enable platforms (Android, iOS) as needed.
3. Copy the **App ID** and paste it in your `main.dart`:
   ```dart
   OneSignal.initialize("YOUR-ONESIGNAL-APP-ID");
   ```

---

### 📲 Android Configuration

#### `android/app/build.gradle`

Add at bottom:

```gradle
apply plugin: 'com.google.gms.google-services'
```

#### `android/build.gradle`

```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

#### `android/app/src/main/AndroidManifest.xml`

Inside `<manifest>`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
```

Inside `<application>`:
```xml
<meta-data
    android:name="com.onesignal.NotificationOpened.DEFAULT"
    android:value="DISABLE"/>
```

Also:
- Place your `google-services.json` in `android/app/`.

---

### 🍏 iOS Configuration

1. Enable **Push Notifications** and **Background Modes** in Xcode.
2. Add to `ios/Runner/Info.plist`:
   ```xml
   <key>NSUserTrackingUsageDescription</key>
   <string>This identifier will be used to deliver personalized notifications.</string>
   <key>UIBackgroundModes</key>
   <array>
     <string>remote-notification</string>
   </array>
   ```
3. Upload your **APNs certificate or key** to the OneSignal dashboard.

---

### 🔑 Request Notification Permission

In `main.dart`:
```dart
OneSignal.Notifications.requestPermission(true);
```

---

## 🧪 Testing

1. Build the app on a **real device**.
2. Go to OneSignal Dashboard → Audience → Send Test Notification.

---

## 🛠️ Useful Snippets

### Get OneSignal Player ID

```dart
final state = await OneSignal.User.getDeviceState();
print('User ID: ${state?.userId}');
```

---

## 📝 Notes Before Launch

- [ ] Set unique `applicationId` (Android) and bundle ID (iOS).
- [ ] Customize app name, launcher icon, and splash screen.
- [ ] Confirm push works on production builds.
- [ ] Add privacy policy mentioning use of push notifications.
- [ ] Ensure iOS signing & provisioning profiles are valid.
- [ ] Upload release builds (APK/AAB or .ipa) to stores with correct versioning.

---

## 📄 License

MIT – feel free to use, modify, and distribute.

---

## 📬 Support

- [OneSignal Docs – Flutter](https://documentation.onesignal.com/docs/flutter-sdk-setup)
- [Flutter Docs](https://flutter.dev)

---