import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'dataBaseHelper.dart';
import 'messageModel.dart';
import 'backgrounMessageHandler.dart' as CustomHandler;

class FirebaseNotificationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  static const String _channelId = 'chat_notifications';
  static const String _channelName = 'Chat Messages';
  static const String _channelDescription = 'Notifications for chat messages';

  static Future<void> initialize() async {
    // Firebase is already initialized in main.dart
    
    // Initialize local notifications
    await _initializeLocalNotifications();

    // Request notification permissions
    await _requestPermissions();

    // Initialize background message handler
    await CustomHandler.BackgroundMessageHandler.initialize();

    // Set up Firebase messaging listeners
    _setupFirebaseListeners();

    // Get and print FCM token for testing
    final token = await getToken();
    print('FCM Token: $token');
  }

  static Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    // Create notification channel for Android
    if (Platform.isAndroid) {
      await _createNotificationChannel();
    }
  }

  static Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );
    
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  static Future<void> _requestPermissions() async {
    final messaging = FirebaseMessaging.instance;
    
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    
    print('Notification permission status: ${settings.authorizationStatus}');
  }

  static void _setupFirebaseListeners() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    
    // Handle notification tap when app is terminated
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleNotificationTap(message);
      }
    });
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Received foreground message: ${message.messageId}');
    
    final data = message.data;
    if (data['type'] == 'chat_message') {
      await _showLocalNotificationWithReply(
        title: message.notification?.title ?? 'New Message',
        body: message.notification?.body ?? '',
        data: data,
      );
    }
  }

  static Future<void> _handleNotificationTap(RemoteMessage message) async {
    print('Notification tapped: ${message.messageId}');
    
    final data = message.data;
    if (data['type'] == 'chat_message') {
      final chatId = data['chatId'] ?? '';
      final senderId = data['senderId'] ?? '';
      final senderName = data['senderName'] ?? 'Unknown';
      
      _navigateToChat(chatId, senderId, senderName);
    }
  }

  static void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      
      if (data['type'] == 'chat_message') {
        final chatId = data['chatId'] ?? '';
        final senderId = data['senderId'] ?? '';
        final senderName = data['senderName'] ?? 'Unknown';
        
        _navigateToChat(chatId, senderId, senderName);
      }
    }
  }

  static Future<void> _showLocalNotificationWithReply({
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    final chatId = data['chatId'] ?? '';
    final senderId = data['senderId'] ?? '';
    final senderName = data['senderName'] ?? 'Unknown';

    if (Platform.isAndroid) {
      await _showAndroidNotificationWithReply(
        title: title,
        message: body,
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
      );
    } else {
      await _showIOSNotification(
        title: title,
        body: body,
        data: data,
      );
    }
  }

  static Future<void> _showAndroidNotificationWithReply({
    required String title,
    required String message,
    required String chatId,
    required String senderId,
    required String senderName,
  }) async {
    try {
      const platform = MethodChannel('chat_app/notifications');
      await platform.invokeMethod('showNotificationWithReply', {
        'title': title,
        'message': message,
        'chatId': chatId,
        'senderId': senderId,
        'senderName': senderName,
      });
    } catch (e) {
      print('Error showing Android notification with reply: $e');
      // Fallback to regular notification
      await _showRegularNotification(title, message, chatId, senderId);
    }
  }

  static Future<void> _showRegularNotification(String title, String message, String chatId, String senderId) async {
    final payload = jsonEncode({
      'type': 'chat_message',
      'chatId': chatId,
      'senderId': senderId,
    });

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      chatId.hashCode,
      title,
      message,
      notificationDetails,
      payload: payload,
    );
  }

  static Future<void> _showIOSNotification({
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    final payload = jsonEncode(data);

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'CHAT_MESSAGE',
    );

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      data['chatId'].hashCode,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  static void _showInAppNotification({
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(body),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Dismiss'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _navigateToChat(
                        data['chatId'] ?? '',
                        data['senderId'] ?? '',
                        data['senderName'] ?? 'Unknown',
                      );
                    },
                    child: const Text('Reply'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }

  static void _navigateToChat(String chatId, String senderId, [String? senderName]) {
    navigatorKey.currentState?.pushNamed('/chat', arguments: {
      'chatId': chatId,
      'userId': senderId,
      'senderName': senderName ?? 'Unknown',
    });
  }

  // Handle notification received in background/terminated state
  static Future<void> handleBackgroundNotification(Map<String, dynamic> data) async {
    await CustomHandler.BackgroundMessageHandler.handleBackgroundMessage(data);
  }

  // Get FCM token for sending notifications
  static Future<String?> getToken() async {
    try {
      final messaging = FirebaseMessaging.instance;
      return await messaging.getToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  // Subscribe to topic for group messaging
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  // Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }

  // Set user properties (equivalent to OneSignal tags)
  static Future<void> setUserProperties(Map<String, String> properties) async {
    try {
      // Store user properties locally for targeting
      // In a real app, you'd send these to your server for targeting
      final prefs = await SharedPreferences.getInstance();
      for (final entry in properties.entries) {
        await prefs.setString('user_${entry.key}', entry.value);
      }
      print('User properties set: $properties');
    } catch (e) {
      print('Error setting user properties: $e');
    }
  }
}
