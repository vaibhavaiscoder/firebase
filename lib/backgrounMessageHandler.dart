// Background Message Handler
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'dataBaseHelper.dart';
import 'messageModel.dart';
import 'chatService.dart';

class BackgroundMessageHandler {
  static const MethodChannel _channel = MethodChannel('chat_app/background');

  static Future<void> initialize() async {
    // Set up method channel listener for notification replies
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onNotificationReply':
          await _handleNotificationReply(call.arguments);
          break;
        default:
          throw PlatformException(
            code: 'Unimplemented',
            details: 'Method ${call.method} not implemented',
          );
      }
    });
  }

  static Future<void> handleBackgroundMessage(Map<String, dynamic> data) async {
    // Handle message in background/terminated state
    final message = Message(
      id: const Uuid().v4(),
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      message: data['message'] ?? '',
      timestamp: DateTime.now(),
    );

    await DatabaseHelper.insertMessage(message);

    // Update app badge count
    await _updateBadgeCount();
  }

  static Future<void> _handleNotificationReply(Map<dynamic, dynamic> data) async {
    final message = data['message'] as String?;
    final chatId = data['chatId'] as String?;
    final senderId = data['senderId'] as String?;

    if (message != null && chatId != null && senderId != null) {
      // Create and save the reply message
      final replyMessage = Message(
        id: const Uuid().v4(),
        senderId: 'current_user_id', // Replace with actual current user ID
        receiverId: senderId,
        message: message,
        timestamp: DateTime.now(),
      );

      await DatabaseHelper.insertMessage(replyMessage);

      // Send the message via your chat service
      await ChatService.sendMessage(replyMessage);

      print('Reply sent from notification: $message');
    }
  }

  static Future<void> sendReplyFromNotification({
    required String message,
    required String chatId,
    required String senderId,
  }) async {
    try {
      await _channel.invokeMethod('sendReplyFromNotification', {
        'message': message,
        'chatId': chatId,
        'senderId': senderId,
      });
    } catch (e) {
      print('Error sending reply from notification: $e');
    }
  }

  static Future<void> _updateBadgeCount() async {
    try {
      await _channel.invokeMethod('updateBadgeCount');
    } catch (e) {
      print('Error updating badge count: $e');
    }
  }
}
