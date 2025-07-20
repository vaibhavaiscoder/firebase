import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

// Chat List Screen
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> with WidgetsBindingObserver {
  List<Map<String, String>> chats = [
    {'id': 'user1', 'name': 'John Doe', 'lastMessage': 'Hey there!'},
    {'id': 'user2', 'name': 'Jane Smith', 'lastMessage': 'How are you?'},
    {'id': 'user3', 'name': 'Bob Wilson', 'lastMessage': 'See you later!'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeUser();
  }

  // void getToken() async {
  //   final accessToken = await getAccessToken();
  //   print('accessToken is ==> $accessToken');
  // }





  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes
    switch (state) {
      case AppLifecycleState.resumed:
        _handleAppResumed();
        break;
      case AppLifecycleState.paused:
        _handleAppPaused();
        break;
      case AppLifecycleState.detached:
        _handleAppTerminated();
        break;
      default:
        break;
    }
  }

  Future<void> _initializeUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userId')) {
      await prefs.setString('userId', 'current_user_${DateTime.now().millisecondsSinceEpoch}');
    }

    // Set Firebase FCM user identification
    final userId = prefs.getString('userId')!;
    // Firebase FCM user identification is handled in FirebaseNotificationService
  }

  void _handleAppResumed() {
    // Sync messages when app comes to foreground
    print('App resumed - syncing messages');
  }

  void _handleAppPaused() {
    // Save any pending data
    print('App paused - saving state');
  }

  void _handleAppTerminated() {
    // Clean up resources
    print('App terminated - cleaning up');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(child: Text('Settings')),
              PopupMenuItem(child: Text('Profile')),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.teal,
              child: Text(chat['name']!.substring(0, 1)),
            ),
            title: Text(chat['name']!),
            subtitle: Text(chat['lastMessage']!),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('12:30 PM', style: TextStyle(fontSize: 12)),
                Container(
                  margin: EdgeInsets.only(top: 5),
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    shape: BoxShape.circle,
                  ),
                  child: Text('2', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ],
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/chat',
                arguments: {
                  'chatId': 'current_user_${chat['id']}',
                  'userId': chat['id'],
                  'userName': chat['name'],
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () {},
        child: Icon(Icons.chat),
      ),
    );
  }
}
