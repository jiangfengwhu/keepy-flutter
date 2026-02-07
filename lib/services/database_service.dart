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
      version: 5,
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
        icon_name TEXT DEFAULT '',
        color_value INTEGER,
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
        updated_at TEXT NOT NULL,
        reminder_at TEXT DEFAULT '',
        reminder_sent INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS kv_store (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
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
    if (oldVersion < 3) {
      // 新增提醒相关列
      await db.execute(
          "ALTER TABLE records ADD COLUMN reminder_at TEXT DEFAULT ''");
      await db.execute(
          'ALTER TABLE records ADD COLUMN reminder_sent INTEGER DEFAULT 0');
    }
    if (oldVersion < 4) {
      // 新增图标和颜色列
      await db.execute(
          "ALTER TABLE notebooks ADD COLUMN icon_name TEXT DEFAULT ''");
      await db.execute(
          'ALTER TABLE notebooks ADD COLUMN color_value INTEGER');
    }
    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS kv_store (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        )
      ''');
    }
  }

  // ── KV Store ────────────────────────────

  Future<String?> getKv(String key) async {
    final db = await database;
    final rows =
        await db.query('kv_store', where: 'key = ?', whereArgs: [key]);
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }

  Future<void> setKv(String key, String value) async {
    final db = await database;
    await db.insert(
      'kv_store',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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

  /// 完整更新笔记本（含记录数据迁移）
  ///
  /// [renamedFields] 旧字段名 -> 新字段名 的映射
  /// [removedFields] 要删除的字段名列表
  Future<Notebook?> updateNotebookFull({
    required int notebookId,
    required String oldName,
    String? newName,
    String? newDescription,
    List<SchemaField>? newSchema,
    String? newIconName,
    int? newColorValue,
    Map<String, String> renamedFields = const {},
    List<String> removedFields = const [],
  }) async {
    final db = await database;

    await db.transaction((txn) async {
      // 1. 更新笔记本本身
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (newName != null) updates['name'] = newName;
      if (newDescription != null) updates['description'] = newDescription;
      if (newSchema != null) {
        updates['schema_json'] =
            jsonEncode(newSchema.map((f) => f.toJson()).toList());
      }
      if (newIconName != null) updates['icon_name'] = newIconName;
      if (newColorValue != null) updates['color_value'] = newColorValue;
      await txn.update('notebooks', updates,
          where: 'id = ?', whereArgs: [notebookId]);

      // 2. 若名称变更，更新所有记录的 notebook_name
      if (newName != null && newName != oldName) {
        await txn.update(
          'records',
          {'notebook_name': newName},
          where: 'notebook_name = ?',
          whereArgs: [oldName],
        );
      }

      // 3. 批量迁移记录中的字段数据（重命名 / 删除）
      if (renamedFields.isNotEmpty || removedFields.isNotEmpty) {
        final targetName = newName ?? oldName;
        final rows = await txn.query('records',
            where: 'notebook_name = ?', whereArgs: [targetName]);

        for (final row in rows) {
          final data =
              jsonDecode(row['data_json'] as String) as Map<String, dynamic>;
          var changed = false;

          // 重命名字段
          for (final entry in renamedFields.entries) {
            if (data.containsKey(entry.key)) {
              data[entry.value] = data.remove(entry.key);
              changed = true;
            }
          }

          // 删除字段
          for (final field in removedFields) {
            if (data.containsKey(field)) {
              data.remove(field);
              changed = true;
            }
          }

          if (changed) {
            await txn.update(
              'records',
              {
                'data_json': jsonEncode(data),
                'updated_at': DateTime.now().toIso8601String(),
              },
              where: 'id = ?',
              whereArgs: [row['id']],
            );
          }
        }
      }
    });

    return getNotebook(notebookId);
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

  /// 更新记录数据（合并）
  Future<int> updateRecord(int id, Map<String, dynamic> newData) async {
    final db = await database;

    final existing = await getRecord(id);
    if (existing == null) return 0;

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

  /// 更新记录的提醒时间
  Future<int> updateRecordReminder(int id, DateTime? reminderAt) async {
    final db = await database;
    return db.update(
      'records',
      {
        'reminder_at': reminderAt?.toIso8601String() ?? '',
        'reminder_sent': 0, // 重新设置后标记为未发送
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 标记提醒已发送
  Future<int> markReminderSent(int id) async {
    final db = await database;
    return db.update(
      'records',
      {'reminder_sent': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 获取所有待发送提醒的记录（提醒时间不为空、未发送）
  Future<List<DataRecord>> getPendingReminders() async {
    final db = await database;
    final rows = await db.query(
      'records',
      where: "reminder_at != '' AND reminder_sent = 0",
      orderBy: 'reminder_at ASC',
    );
    return rows.map((row) => DataRecord.fromDbRow(row)).toList();
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

  /// 批量获取每个小本的记录数量
  Future<Map<String, int>> getRecordCountsAll() async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT notebook_name, COUNT(*) as count FROM records GROUP BY notebook_name',
    );
    final map = <String, int>{};
    for (final row in rows) {
      map[row['notebook_name'] as String] = row['count'] as int;
    }
    return map;
  }

  /// 搜索记录（同时匹配 data_json 和 notebook_name）
  Future<List<DataRecord>> searchRecords(String keyword,
      {int limit = 50}) async {
    final db = await database;
    final rows = await db.query(
      'records',
      where: 'data_json LIKE ? OR notebook_name LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%'],
      orderBy: 'updated_at DESC',
      limit: limit,
    );
    return rows.map((row) => DataRecord.fromDbRow(row)).toList();
  }

  /// 获取即将到来的提醒（未来 7 天内）
  Future<List<DataRecord>> getUpcomingReminders({int days = 7}) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final end = DateTime.now().add(Duration(days: days)).toIso8601String();
    final rows = await db.query(
      'records',
      where: "reminder_at != '' AND reminder_at >= ? AND reminder_at <= ? AND reminder_sent = 0",
      whereArgs: [now, end],
      orderBy: 'reminder_at ASC',
      limit: 10,
    );
    return rows.map((row) => DataRecord.fromDbRow(row)).toList();
  }

  /// 获取最近更新的记录
  Future<List<DataRecord>> getRecentRecords({int limit = 5}) async {
    final db = await database;
    final rows = await db.query(
      'records',
      orderBy: 'updated_at DESC',
      limit: limit,
    );
    return rows.map((row) => DataRecord.fromDbRow(row)).toList();
  }
}
