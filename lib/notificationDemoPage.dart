import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/notification_service.dart';
import 'models/message.dart';


class NotificationDemoPage extends StatefulWidget {
  const NotificationDemoPage({super.key});

  @override
  State<NotificationDemoPage> createState() => _NotificationDemoPageState();
}

class _NotificationDemoPageState extends State<NotificationDemoPage> {
  final NotificationService _notificationService = NotificationService();
  String? _fcmToken;
  List<Message> _messages = [];
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFCMToken();
    _loadMessages();
  }

  Future<void> _loadFCMToken() async {
    final token = await _notificationService.getStoredFCMToken();
    setState(() {
      _fcmToken = token;
    });
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = prefs.getStringList('messages') ?? [];
    setState(() {
      _messages =
          messagesJson
              .map(
                (json) => Message.fromJson(
              Map<String, dynamic>.from(
                Map.fromIterable(
                  json.split('|'),
                  key: (e) => e.split(':')[0],
                  value: (e) => e.split(':')[1],
                ),
              ),
            ),
          )
              .toList();
    });
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson =
    _messages
        .map(
          (message) => message
          .toJson()
          .entries
          .map((e) => '${e.key}:${e.value}')
          .join('|'),
    )
        .toList();
    await prefs.setStringList('messages', messagesJson);
  }

  Future<void> _addMessage(Message message) async {
    setState(() {
      _messages.insert(0, message);
    });
    await _saveMessages();
  }

  Future<void> _sendQuickReply(String messageId, String reply) async {
    final replyMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'current_user',
      senderName: 'You',
      content: reply,
      timestamp: DateTime.now(),
      replyTo: messageId,
    );

    await _addMessage(replyMessage);
    await _notificationService.sendQuickReply(messageId, reply);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Reply sent: $reply')));
  }

  Future<void> _markAsRead(String messageId) async {
    setState(() {
      _messages =
          _messages.map((message) {
            if (message.id == messageId) {
              return message.copyWith(isRead: true);
            }
            return message;
          }).toList();
    });
    await _saveMessages();
    await _notificationService.markMessageAsRead(messageId);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Message marked as read')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Firebase Notifications Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFCMToken,
            tooltip: 'Refresh FCM Token',
          ),
        ],
      ),
      body: Column(
        children: [
          // FCM Token Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FCM Token:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  _fcmToken ?? 'Loading...',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                        _fcmToken != null
                            ? () {
                          Clipboard.setData(
                            ClipboardData(text: _fcmToken!),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'FCM Token copied to clipboard',
                              ),
                            ),
                          );
                        }
                            : null,
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy Token'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Messages List
          Expanded(
            child:
            _messages.isEmpty
                ? const Center(
              child: Text(
                'No messages yet.\nSend a test notification to see messages here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
                : ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: ListTile(
                    title: Text(
                      message.senderName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (message.replyTo != null)
                          Container(
                            padding: const EdgeInsets.all(4),
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Replying to message ${message.replyTo}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        Text(message.content),
                        const SizedBox(height: 4),
                        Text(
                          _formatTimestamp(message.timestamp),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    trailing:
                    message.senderId != 'current_user'
                        ? PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'reply') {
                          _showReplyDialog(message);
                        } else if (value == 'mark_read') {
                          _markAsRead(message.id);
                        }
                      },
                      itemBuilder:
                          (context) => [
                        const PopupMenuItem(
                          value: 'reply',
                          child: Row(
                            children: [
                              Icon(Icons.reply),
                              SizedBox(width: 8),
                              Text('Reply'),
                            ],
                          ),
                        ),
                        if (!message.isRead)
                          const PopupMenuItem(
                            value: 'mark_read',
                            child: Row(
                              children: [
                                Icon(Icons.mark_email_read),
                                SizedBox(width: 8),
                                Text('Mark as Read'),
                              ],
                            ),
                          ),
                      ],
                    )
                        : null,
                  ),
                );
              },
            ),
          ),

          // Quick Reply Input
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a quick reply...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      _sendQuickReply(
                        DateTime.now().millisecondsSinceEpoch.toString(),
                        _messageController.text,
                      );
                      _messageController.clear();
                    }
                  },
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showTestNotificationDialog,
        tooltip: 'Send Test Notification',
        child: const Icon(Icons.notifications),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showReplyDialog(Message message) {
    final replyController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        title: Text('Reply to ${message.senderName}'),
        content: TextField(
          controller: replyController,
          decoration: const InputDecoration(
            hintText: 'Type your reply...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (replyController.text.isNotEmpty) {
                _sendQuickReply(message.id, replyController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Send Reply'),
          ),
        ],
      ),
    );
  }

  void _showTestNotificationDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        title: const Text('Send Test Notification'),
        content: const Text(
          'This will simulate receiving a notification. '
              'You can test the app in different states:\n\n'
              '• Foreground: App is open\n'
              '• Background: App is minimized\n'
              '• Terminated: App is closed\n\n'
              'The notification should work in all states!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _simulateTestNotification();
            },
            child: const Text('Send Test'),
          ),
        ],
      ),
    );
  }

  void _simulateTestNotification() {
    final testMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'test_sender',
      senderName: 'Test User',
      content: 'This is a test notification! Tap to reply or mark as read.',
      timestamp: DateTime.now(),
    );

    _addMessage(testMessage);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Test notification added! Check your device notifications.',
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
