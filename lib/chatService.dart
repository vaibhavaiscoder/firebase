import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart';

import 'dataBaseHelper.dart';
import 'messageModel.dart';

// Chat Service for API calls
class ChatService {
  static const String baseUrl = 'YOUR_API_BASE_URL'; // Replace with your API

  static Future<void> sendMessage(Message message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send-message'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'senderId': message.senderId,
          'receiverId': message.receiverId,
          'message': message.message,
          'timestamp': message.timestamp.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        await DatabaseHelper.insertMessage(message);
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  static Future<void> sendQuickReply(String messageText, String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getString('userId') ?? '';

    final message = Message(
      id: const Uuid().v4(),
      senderId: currentUserId,
      receiverId: chatId.replaceAll(currentUserId, '').replaceAll('_', ''),
      message: messageText,
      timestamp: DateTime.now(),
    );

    await sendMessage(message);
  }
}