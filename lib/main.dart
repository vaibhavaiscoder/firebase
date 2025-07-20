import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';

import 'firebase_options.dart';
import 'chatListScreen.dart';
import 'chatScreen.dart';
import 'dataBaseHelper.dart';
import 'inAppNotificationWidget.dart';
import 'notificationService.dart';
import 'backgrounMessageHandler.dart' as CustomHandler;

// Top-level function for background message handling
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
  await CustomHandler.BackgroundMessageHandler.handleBackgroundMessage(message.data);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize database
  await DatabaseHelper.database;

  // Initialize Firebase notification service
  await FirebaseNotificationService.initialize();

  runApp(MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App with Notifications',
      navigatorKey: FirebaseNotificationService.navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => ChatListScreen(),
        '/chat': (context) => ChatScreen(),
      },
    );
  }
}


