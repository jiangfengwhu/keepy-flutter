import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/notebook.dart';

/// 本地数据库服务（单例）
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'miaoji.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notebooks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT DEFAULT '',
        schema_json TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  // ── Notebook CRUD ────────────────────────────

  /// 创建笔记本，返回插入的 id
  Future<int> createNotebook(Notebook notebook) async {
    final db = await database;
    return db.insert('notebooks', notebook.toDbRow());
  }

  /// 获取所有笔记本（按创建时间倒序）
  Future<List<Notebook>> getAllNotebooks() async {
    final db = await database;
    final rows = await db.query(
      'notebooks',
      orderBy: 'created_at DESC',
    );
    return rows.map((row) => Notebook.fromDbRow(row)).toList();
  }

  /// 根据 id 获取笔记本
  Future<Notebook?> getNotebook(int id) async {
    final db = await database;
    final rows = await db.query(
      'notebooks',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return Notebook.fromDbRow(rows.first);
  }

  /// 删除笔记本
  Future<int> deleteNotebook(int id) async {
    final db = await database;
    return db.delete('notebooks', where: 'id = ?', whereArgs: [id]);
  }

  /// 获取笔记本数量
  Future<int> getNotebookCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM notebooks');
    return result.first['count'] as int;
  }
}
