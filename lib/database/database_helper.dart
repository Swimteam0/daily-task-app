import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'daily_task.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // 添加 task_date 字段
      await db.execute('ALTER TABLE tasks ADD COLUMN task_date TEXT');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        task_type INTEGER NOT NULL,
        remind_time TEXT,
        remind_enabled INTEGER DEFAULT 0,
        repeat_days TEXT,
        created_at TEXT NOT NULL,
        is_active INTEGER DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE check_ins (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id INTEGER NOT NULL,
        check_in_date TEXT NOT NULL,
        check_in_time TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (task_id) REFERENCES tasks(id),
        UNIQUE(task_id, check_in_date)
      )
    ''');

    await db.execute('''
      CREATE TABLE user_stats (
        id INTEGER PRIMARY KEY DEFAULT 1,
        total_check_ins INTEGER DEFAULT 0,
        current_streak INTEGER DEFAULT 0,
        max_streak INTEGER DEFAULT 0,
        last_check_in_date TEXT,
        level INTEGER DEFAULT 1,
        rank INTEGER DEFAULT 1,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE focus_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        start_time TEXT NOT NULL,
        end_time TEXT,
        duration_minutes INTEGER DEFAULT 0,
        interruption_count INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    await db.execute('CREATE INDEX idx_checkins_task ON check_ins(task_id)');
    await db.execute('CREATE INDEX idx_checkins_date ON check_ins(check_in_date)');
    await db.execute('CREATE INDEX idx_tasks_type ON tasks(task_type)');
    await db.execute('CREATE INDEX idx_tasks_active ON tasks(is_active)');
    await db.execute('CREATE INDEX idx_focus_date ON focus_sessions(start_time)');

    // Insert default settings
    await db.insert('settings', {'key': 'theme_mode', 'value': 'system'});
    await db.insert('settings', {'key': 'notification_enabled', 'value': 'true'});
    await db.insert('settings', {
      'key': 'focus_ai_whitelist',
      'value': '豆包,元宝,千问,ChatGPT,Claude,Gemini'
    });

    // Insert default user_stats row
    final now = DateTime.now().toIso8601String();
    await db.insert('user_stats', {
      'id': 1,
      'total_check_ins': 0,
      'current_streak': 0,
      'max_streak': 0,
      'level': 1,
      'rank': 1,
      'updated_at': now,
    });
  }
}
