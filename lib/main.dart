import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

void main() {
  runApp(MyApp());

  // OneSignal initialization
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("e3f2d92d-3a53-4d20-ae76-cb439d5adbb4"); // ← Replace with your onesignal App ID

  // Prompt user for push notification permission (iOS)
  OneSignal.Notifications.requestPermission(true);

  // Handle foreground push
  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    event.preventDefault(); // prevent default notification
    event.notification.display(); // show manually
  });

  // Handle notification tap
  OneSignal.Notifications.addClickListener((event) {
    print('Notification Clicked: ${event.notification.jsonRepresentation()}');
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OneSignal Push Example',
      home: Scaffold(
        appBar: AppBar(title: Text("Push Demo")),
        body: Center(child: Text("Waiting for notifications...")),
      ),
    );
  }
}
