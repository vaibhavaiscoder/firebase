import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'chatService.dart';

// In-app notification widget
class InAppNotificationWidget extends StatelessWidget {
  final OSNotification notification;

  const InAppNotificationWidget({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final data = notification.additionalData;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 10,
      right: 10,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.teal,
                child: Text(data?['senderName']?.substring(0, 1) ?? 'U'),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      data?['senderName'] ?? 'Unknown',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      notification.body ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.reply),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showQuickReply(context, data);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuickReply(BuildContext context, Map<String, dynamic>? data) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quick Reply'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Type your message...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await ChatService.sendQuickReply(
                  controller.text.trim(),
                  data?['chatId'] ?? '',
                );
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Message sent!')),
                );
              }
            },
            child: Text('Send'),
          ),
        ],
      ),
    );
  }
}
