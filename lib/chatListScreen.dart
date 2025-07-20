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
    getToken();
  }

  void getToken() async {
    final accessToken = await getAccessToken();
    print('accessToken is ==> $accessToken');
  }


  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "freeklat",
      "private_key_id": "34c103195ce0ccb61eacac17387934c4547136d7",
      "private_key":
      "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDMEgTdFYi/EQ/6\nOE2HfC2D3mPgb/olFTBV1FBPPN77OMNDpL4TpYloKXlpAAvF6+JN905sRYzKe8ZD\nONOYpy2muIl/nLV8Sw32ou2EvznKEdj4t/3eD9sdIboeG68dwZcYZw1UILlVNFlu\nhyGHu5fFpYih6ySc0Ngnm2mCaz6GjnG9LiU9Y5hznIHUn5BZz8fkmvU9an/RsT4Y\nU8YM2OH02PwesLyl8zbLhv2tqg0jtKfT63OA6RIZF6nK5sW3tGBmc4/bOwimm/M2\nB97xncVJIDLheax1BsVpft08a1CJVwiJ3MbYuPZLMxBjHpob0TwCV3ZSxiaYjlJO\n6s6gQ3RPAgMBAAECggEAFSppRrpNDJmAcWYVjyUvXgCwQJRcpYFPxMHYnTSltqNp\n3UI2VLipSnHCyJkwn2lFIkEG6UPtbl2YGrDHgYsVY7gQICQ+I+jE8f0Zatif7c1x\na5qUbMvINiVMCy4Ojk+IlFyxN+CNAxatj+vZa8fmiKFlTSX5Diq7FfXl45kBSy3w\nw1Ptx9U1dyscXFgAy6HxBS1AgJggF+Cskba5whF1mcT1n6wMMEzOVUdtzuAEPKwu\neNGVhJblmkrT8ZU2grTyE8leoo+7AaYtsYxCT2euQ4x6w3ypHorZEOhQX2WCGN0V\ns6l8ozG4UaNWCiHBHWPxIh4uCCX4JpcimA+5013bAQKBgQD4yZM6ACztH6uTTNbf\n0DctRnINVIIXhqilT9WbrPvoq8RmU5ZgE+uKRJtOHIqK3ziyc021u+9usZH7THrv\nyZVJvOwQAeoFcdiyKa7/CePKkawMSe/MrYB4+GEinn80qLyyvYwE9erzgm63SrmT\nPyJWXIn9RceOZrNJvftcpLeZMQKBgQDR/JFWDpnlnTwFpnO7WPwOjIyFXfzE5A/2\nMewblMUVYpgSp/1KuxGrCt8dtCe6O237A51NQSSkEAe02xNzz8LpveMz4AGpq22c\nWc6JGEKncAtDasSNtOVSU4mLUxSGzD7/GPmsBDW5iypMVd3S+J0TasZWKd5YP732\n0e13ShiFfwKBgQCOSmPtOWp4mLN+BOWkjqbwOylCHIJnSDouinGmnxJY6dzjlY0d\nGGeP5ltZGpPWh4Ma9T2N4pY3nlHbA8wQVyAOU4JESYP6ZznD9HlFHvfsxNI9GRCQ\n5O7kwVJ1BWfFy3hZVnW95JTjf0cpiBCJegN+l2DIvd87v9ttIr6gJwlnEQKBgQCZ\nJ9X5Jn0o9B2rIVSX+LcfBXQYcgzCrnTV5GOJWmDE0DyKnuwnbXndfvhs+dFgC6iT\nxHceuby3zNlSF9eASLCpO05Tr7aGwfoYZ4g0hfVXmmkcqurhUGdSPIu9isMV7jKk\nbNrtk8R7p/0Z4CcCkUI/v0kZ3z/Erfkn5MWGlAx+kQKBgBn+jzZqAI04wKMzBLeh\n5smRq7JYZ6+GTGjPmNUxXZ92FqGS/4z/3t0PKXaa4Tg3eeXeXxlJruRIubxWkCwR\nQdJYabKYkIXwXf3uAQQf1orVmLmD/nk6w0n41j7lYvaK9ygiu8cY4ekCun2Eo00f\nsfH4oAO5hgxatTu34+VbpIRg\n-----END PRIVATE KEY-----\n",
      "client_email":
      "chatnoti@freeklat.iam.gserviceaccount.com",
      "client_id": "113955446802568673860",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
      "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
      "https://www.googleapis.com/robot/v1/metadata/x509/chatnoti%40freeklat.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };
    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];
    http.Client client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson), scopes);
    auth.AccessCredentials credentials =
    await auth.obtainAccessCredentialsViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
        client);
    client.close();
    return credentials.accessToken.data;
  }

  // static sendNotificationToSelectedDriver(
  //     String deviceToken, BuildContext context, String tripID) async {
  //   final String serverAccessToken = await getAccessToken();
  //   String endpointFirebaseCloudMessaging =
  //       'https://fcm.googleapis.com/v1/projects/aakarsh-career/messages:send';
  //
  //   final Map<String, dynamic> message = {
  //     'message': {
  //       'token': AakarshStorage.fcmToken,
  //       'notification': {'title': 't1', 'body': 'b1'},
  //       'data': {
  //         'tripId': '1',
  //         'channel': 'basic_channel', //call_channel
  //         'action': 'leave'
  //       }
  //     }
  //   };
  //
  //   final http.Response response = await http.post(
  //       Uri.parse(endpointFirebaseCloudMessaging),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $serverAccessToken'
  //       },
  //       body: jsonEncode(message));
  //   if (response.statusCode == 200) {
  //     print('notification send successfully');
  //   } else {
  //     print('failed to send notification: ${response.statusCode}');
  //   }
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
