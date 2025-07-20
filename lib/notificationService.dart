import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:uuid/uuid.dart';

import 'dataBaseHelper.dart';
import 'messageModel.dart';
import 'backgrounMessageHandler.dart';

class NotificationService {
  static const String _appId = "e3f2d92d-3a53-4d20-ae76-cb439d5adbb4";
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Future<void> initialize() async {
    // Initialize OneSignal
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize(_appId);

    // Request permission for notifications
    await OneSignal.Notifications.requestPermission(true);

    // Set external user ID for testing (replace with actual user ID in production)
    await setExternalUserId('test_user_123');

    // Initialize background message handler
    await BackgroundMessageHandler.initialize();

    // Configure notification categories for reply actions
    await _setupNotificationCategories();

    // Set up notification listeners
    _setupNotificationListeners();
  }

  static void _setupNotificationListeners() {
    // Handle ALL notifications (foreground, background, terminated)
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      final data = event.notification.additionalData;
      
      if (data?['type'] == 'chat_message') {
        // Always create custom notification with reply action
        _showCustomNotificationWithReply(event.notification);
        event.preventDefault(); // Prevent default OneSignal notification
      } else {
        event.notification.display();
      }
    });

    // Handle notification clicks
    OneSignal.Notifications.addClickListener((event) {
      final data = event.notification.additionalData;
      
      if (data?['type'] == 'chat_message') {
        final chatId = data?['chatId'] ?? '';
        final senderId = data?['senderId'] ?? '';
        final senderName = data?['senderName'] ?? 'Unknown';
        
        // Navigate to chat screen
        _navigateToChat(chatId, senderId, senderName);
      }
    });

    // Handle notification permission changes
    OneSignal.Notifications.addPermissionObserver((state) {
      print("Notification permission: $state");
    });
  }

  static Future<void> _setupNotificationCategories() async {
    if (Platform.isIOS) {
      // iOS notification categories are set up in native code
      // This would typically be done in AppDelegate.swift
      print("iOS notification categories should be configured in native code");
    } else if (Platform.isAndroid) {
      // Android notification actions are handled in MainActivity.kt
      print("Android notification actions configured in MainActivity");
    }
  }

  static void _showCustomNotificationWithReply(OSNotification notification) {
    final data = notification.additionalData;
    final chatId = data?['chatId'] ?? '';
    final senderId = data?['senderId'] ?? '';
    final message = notification.body ?? '';
    final title = notification.title ?? 'New Message';

    if (Platform.isAndroid) {
      // Use method channel to show Android notification with reply action
      _showAndroidNotificationWithReply(
        title: title,
        message: message,
        chatId: chatId,
        senderId: senderId,
      );
    } else {
      // For iOS, show in-app notification or use native implementation
      _showInAppNotification(notification);
    }
  }

  static Future<void> _showAndroidNotificationWithReply({
    required String title,
    required String message,
    required String chatId,
    required String senderId,
  }) async {
    try {
      const platform = MethodChannel('chat_app/notifications');
      await platform.invokeMethod('showNotificationWithReply', {
        'title': title,
        'message': message,
        'chatId': chatId,
        'senderId': senderId,
      });
    } catch (e) {
      print('Error showing Android notification with reply: $e');
      // Fallback to regular notification
      _showRegularNotification(title, message, chatId, senderId);
    }
  }

  static void _showRegularNotification(String title, String message, String chatId, String senderId) {
    // Fallback notification without reply action
    print('Showing regular notification: $title - $message');
  }

  static void _showInAppNotification(OSNotification notification) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(notification.title ?? 'New Message'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(notification.body ?? ''),
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
                      final data = notification.additionalData;
                      _navigateToChat(
                        data?['chatId'] ?? '',
                        data?['senderId'] ?? '',
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
    await BackgroundMessageHandler.handleBackgroundMessage(data);
  }

  // Get OneSignal player ID for sending notifications
  static Future<String?> getPlayerId() async {
    try {
      final user = OneSignal.User;
      return user.pushSubscription.id;
    } catch (e) {
      print('Error getting player ID: $e');
      return null;
    }
  }

  // Get external user ID
  static Future<String?> getExternalUserId() async {
    try {
      return OneSignal.User.getExternalId();
    } catch (e) {
      print('Error getting external user ID: $e');
      return null;
    }
  }

  // Set external user ID
  static Future<void> setExternalUserId(String userId) async {
    try {
      OneSignal.login(userId);
    } catch (e) {
      print('Error setting external user ID: $e');
    }
  }

  // Add tags for better targeting
  static Future<void> addTags(Map<String, String> tags) async {
    try {
      OneSignal.User.addTags(tags);
    } catch (e) {
      print('Error adding tags: $e');
    }
  }
}
