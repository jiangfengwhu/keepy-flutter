import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/data_record.dart';
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
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
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
    await db.execute('''
      CREATE TABLE records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        notebook_name TEXT NOT NULL,
        data_json TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS records (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          notebook_name TEXT NOT NULL,
          data_json TEXT NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
    }
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
    final rows = await db.query('notebooks', orderBy: 'created_at DESC');
    return rows.map((row) => Notebook.fromDbRow(row)).toList();
  }

  /// 根据 id 获取笔记本
  Future<Notebook?> getNotebook(int id) async {
    final db = await database;
    final rows =
        await db.query('notebooks', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Notebook.fromDbRow(rows.first);
  }

  /// 根据名称获取笔记本
  Future<Notebook?> getNotebookByName(String name) async {
    final db = await database;
    final rows =
        await db.query('notebooks', where: 'name = ?', whereArgs: [name]);
    if (rows.isEmpty) return null;
    return Notebook.fromDbRow(rows.first);
  }

  /// 更新笔记本（按名称查找并更新）
  Future<Notebook?> updateNotebookByName(
    String name, {
    String? newDescription,
    List<SchemaField>? newSchema,
  }) async {
    final db = await database;
    final existing = await getNotebookByName(name);
    if (existing == null) return null;

    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (newDescription != null) updates['description'] = newDescription;
    if (newSchema != null) {
      updates['schema_json'] =
          jsonEncode(newSchema.map((f) => f.toJson()).toList());
    }

    await db.update('notebooks', updates,
        where: 'id = ?', whereArgs: [existing.id]);
    return getNotebook(existing.id!);
  }

  /// 删除笔记本
  Future<int> deleteNotebook(int id) async {
    final db = await database;
    return db.delete('notebooks', where: 'id = ?', whereArgs: [id]);
  }

  /// 按名称删除笔记本（同时删除关联记录）
  Future<bool> deleteNotebookByName(String name) async {
    final db = await database;
    final notebook = await getNotebookByName(name);
    if (notebook == null) return false;

    await db.delete('records',
        where: 'notebook_name = ?', whereArgs: [name]);
    await db.delete('notebooks', where: 'id = ?', whereArgs: [notebook.id]);
    return true;
  }

  /// 获取笔记本数量
  Future<int> getNotebookCount() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM notebooks');
    return result.first['count'] as int;
  }

  // ── Record CRUD ──────────────────────────────

  /// 添加记录，返回插入的 id
  Future<int> createRecord(DataRecord record) async {
    final db = await database;
    return db.insert('records', record.toDbRow());
  }

  /// 获取记录（可按 notebook_name 过滤）
  Future<List<DataRecord>> getRecords({
    String? notebookName,
    String? query,
    int? limit,
  }) async {
    final db = await database;
    String? where;
    List<dynamic>? whereArgs;

    if (notebookName != null && query != null) {
      where = 'notebook_name = ? AND data_json LIKE ?';
      whereArgs = [notebookName, '%$query%'];
    } else if (notebookName != null) {
      where = 'notebook_name = ?';
      whereArgs = [notebookName];
    } else if (query != null) {
      where = 'data_json LIKE ?';
      whereArgs = ['%$query%'];
    }

    final rows = await db.query(
      'records',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
      limit: limit ?? 20,
    );
    return rows.map((row) => DataRecord.fromDbRow(row)).toList();
  }

  /// 根据 id 获取单条记录
  Future<DataRecord?> getRecord(int id) async {
    final db = await database;
    final rows =
        await db.query('records', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return DataRecord.fromDbRow(rows.first);
  }

  /// 更新记录
  Future<int> updateRecord(int id, Map<String, dynamic> newData) async {
    final db = await database;

    // 先获取现有记录
    final existing = await getRecord(id);
    if (existing == null) return 0;

    // 合并数据
    final merged = Map<String, dynamic>.from(existing.data)..addAll(newData);

    return db.update(
      'records',
      {
        'data_json': jsonEncode(merged),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 删除记录
  Future<int> deleteRecord(int id) async {
    final db = await database;
    return db.delete('records', where: 'id = ?', whereArgs: [id]);
  }

  /// 获取某个小本的记录数量
  Future<int> getRecordCount(String notebookName) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM records WHERE notebook_name = ?',
      [notebookName],
    );
    return result.first['count'] as int;
  }
}
