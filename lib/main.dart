import 'package:flutter/material.dart';

import 'chatListScreen.dart';
import 'chatScreen.dart';
import 'dataBaseHelper.dart';
import 'notificationService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  await DatabaseHelper.database;

  // Initialize notification service
  await NotificationService.initialize();

  runApp(MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App with Notifications',
      navigatorKey: NotificationService.navigatorKey,
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


