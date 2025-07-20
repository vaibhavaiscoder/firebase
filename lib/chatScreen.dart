import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'chatService.dart';
import 'dataBaseHelper.dart';
import 'messageModel.dart';

// Chat Screen
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> messages = [];
  late String chatId;
  late String userId;
  late String userName;

  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     final args = ModalRoute.of()!.settings.arguments as Map<String, dynamic>;
  //     chatId = args['chatId'];
  //     userId = args['userId'];
  //     userName = args['userName'] ?? 'Unknown';
  //     _loadMessages();
  //   });
  // }

  Future<void> _loadMessages() async {
    final loadedMessages = await DatabaseHelper.getMessages(chatId);
    setState(() {
      messages = loadedMessages;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getString('userId') ?? '';

    final message = Message(
      id: const Uuid().v4(),
      senderId: currentUserId,
      receiverId: userId,
      message: _controller.text.trim(),
      timestamp: DateTime.now(),
    );

    setState(() {
      messages.add(message);
    });

    _controller.clear();
    _scrollToBottom();

    await ChatService.sendMessage(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(userName.substring(0, 1), style: TextStyle(color: Colors.teal)),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName, style: TextStyle(fontSize: 16)),
                Text('Online', style: TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: Icon(Icons.videocam), onPressed: () {}),
          IconButton(icon: Icon(Icons.call), onPressed: () {}),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(child: Text('View Contact')),
              PopupMenuItem(child: Text('Media')),
              PopupMenuItem(child: Text('Block')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final prefs = SharedPreferences.getInstance();

                return FutureBuilder<SharedPreferences>(
                  future: prefs,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return SizedBox.shrink();

                    final currentUserId = snapshot.data!.getString('userId') ?? '';
                    final isMe = message.senderId == currentUserId;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.teal : Colors.grey[300],
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              message.message,
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isMe ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    maxLines: null,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                SizedBox(width: 8),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.teal,
                  onPressed: _sendMessage,
                  child: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}