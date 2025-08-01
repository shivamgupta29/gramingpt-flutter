import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../screens/chat_screen.dart';
import '../widgets/history_drawer.dart';

class DatabaseHelper {
  // This makes the class a singleton, so we only ever have one instance of the database helper.
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  // Main access point to the database.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gramingpt.db');
    return _database!;
  }

  // This function initializes the database.
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // This function creates the tables the first time the app is run.
  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const boolType = 'INTEGER NOT NULL'; // SQLite uses 0 for false, 1 for true
    const intType = 'INTEGER NOT NULL';

    // Create the conversations table
    await db.execute('''
      CREATE TABLE conversations (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        timestamp INTEGER NOT NULL
      )
    ''');

    // Create the messages table
    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        conversationId TEXT NOT NULL,
        text TEXT NOT NULL,
        isUser INTEGER NOT NULL,
        FOREIGN KEY (conversationId) REFERENCES conversations (id) ON DELETE CASCADE
      )
    ''');
  }

  // --- DATABASE OPERATIONS ---

  // Create a new conversation and return its ID.
  Future<String> createConversation(String title) async {
    final db = await instance.database;
    final id = DateTime.now().toIso8601String(); // Use a timestamp for a unique ID
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    await db.insert('conversations', {'id': id, 'title': title, 'timestamp': timestamp});
    return id;
  }

  // Save a single message to a specific conversation.
  Future<void> saveMessage(GraminChatMessage message, String conversationId) async {
    final db = await instance.database;
    await db.insert('messages', {
      'conversationId': conversationId,
      'text': message.text,
      'isUser': message.isUser ? 1 : 0,
    });
  }

  // Get all conversation summaries for the sidebar.
  Future<List<ConversationSummary>> getConversations() async {
    final db = await instance.database;
    // Order by timestamp descending to show the newest conversations first.
    final maps = await db.query('conversations', orderBy: 'timestamp DESC');

    return List.generate(maps.length, (i) {
      return ConversationSummary(
        id: maps[i]['id'] as String,
        title: maps[i]['title'] as String,
      );
    });
  }

  // Get all messages for a specific conversation.
  Future<List<GraminChatMessage>> getMessages(String conversationId) async {
    final db = await instance.database;
    final maps = await db.query(
      'messages',
      where: 'conversationId = ?',
      whereArgs: [conversationId],
      orderBy: 'id DESC', // Order by ID descending to show newest messages at the bottom
    );

    return List.generate(maps.length, (i) {
      return GraminChatMessage(
        text: maps[i]['text'] as String,
        isUser: (maps[i]['isUser'] as int) == 1,
        audioUrl: null, // We are not storing audio URLs for now
      );
    });
  }

  // Close the database connection when it's no longer needed.
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
