import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class BackgroundNotificationHandler {
  static const MethodChannel _channel = MethodChannel('chat_app/notifications');

  static Future<void> initialize() async {
    // Set up OneSignal background notification handler
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      _handleNotificationReceived(event.notification);
    });
  }

  static void _handleNotificationReceived(OSNotification notification) {
    final data = notification.additionalData;
    
    if (data?['type'] == 'chat_message') {
      // Always show notification with reply action for chat messages
      _showNotificationWithReply(
        title: notification.title ?? 'New Message',
        message: notification.body ?? '',
        chatId: data?['chatId'] ?? '',
        senderId: data?['senderId'] ?? '',
        senderName: data?['senderName'] ?? 'Unknown',
      );
    }
  }

  static Future<void> _showNotificationWithReply({
    required String title,
    required String message,
    required String chatId,
    required String senderId,
    required String senderName,
  }) async {
    try {
      await _channel.invokeMethod('showNotificationWithReply', {
        'title': title,
        'message': message,
        'chatId': chatId,
        'senderId': senderId,
        'senderName': senderName,
      });
    } catch (e) {
      print('Error showing notification with reply: $e');
    }
  }
}
