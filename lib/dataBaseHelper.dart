import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'messageModel.dart';

// Database Helper for local chat storage
class DatabaseHelper {
  static Database? _database;
  static const String tableName = 'messages';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'chat_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName(
            id TEXT PRIMARY KEY,
            senderId TEXT,
            receiverId TEXT,
            message TEXT,
            timestamp INTEGER,
            isRead INTEGER,
            isSent INTEGER
          )
        ''');
      },
    );
  }

  static Future<void> insertMessage(Message message) async {
    final db = await database;
    await db.insert(tableName, message.toMap());
  }

  static Future<List<Message>> getMessages(String chatId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '(senderId = ? AND receiverId = ?) OR (senderId = ? AND receiverId = ?)',
      whereArgs: [chatId.split('_')[0], chatId.split('_')[1], chatId.split('_')[1], chatId.split('_')[0]],
      orderBy: 'timestamp ASC',
    );
    return List.generate(maps.length, (i) => Message.fromMap(maps[i]));
  }
}