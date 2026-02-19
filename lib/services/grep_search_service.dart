import '../models/data_record.dart';
import 'database_service.dart';

/// Grep 风格搜索引擎 —— 直接在 data_json 字符串上正则匹配，不做 JSON 解码
class GrepSearchService {
  final DatabaseService _db;

  GrepSearchService([DatabaseService? db]) : _db = db ?? DatabaseService();

  /// 核心 grep 搜索：在 data_json 原始字符串上做正则匹配
  ///
  /// [pattern]      正则表达式（支持 `|` OR、`.*` 通配等）
  /// [notebookName] 限定在某个小本内搜索
  /// [limit]        返回条数上限
  /// [offset]       分页偏移
  /// [caseSensitive] 大小写敏感，默认 false
  Future<List<DataRecord>> grep({
    required String pattern,
    String? notebookName,
    int limit = 20,
    int offset = 0,
    bool caseSensitive = false,
  }) async {
    if (pattern.isEmpty) return [];

    final regex = buildRegex(pattern, caseSensitive: caseSensitive);
    if (regex == null) return [];

    final db = await _db.database;
    const batchSize = 200;

    String? where;
    List<dynamic>? whereArgs;
    if (notebookName != null) {
      where = 'notebook_name = ?';
      whereArgs = [notebookName];
    }

    final results = <DataRecord>[];
    var skipped = 0;
    var dbOffset = 0;

    while (true) {
      final rows = await db.query(
        'records',
        where: where,
        whereArgs: whereArgs,
        orderBy: 'created_at DESC',
        limit: batchSize,
        offset: dbOffset,
      );
      if (rows.isEmpty) break;
      dbOffset += rows.length;

      for (final row in rows) {
        final dataJson = row['data_json'] as String? ?? '{}';
        if (!regex.hasMatch(dataJson)) continue;

        if (skipped < offset) {
          skipped++;
          continue;
        }

        results.add(DataRecord.fromDbRow(row));
        if (results.length >= limit) break;
      }

      if (results.length >= limit || rows.length < batchSize) break;
    }

    return results;
  }

  /// 构造正则，自动提取内联标志 (?i)/(?m)/(?s)，非法模式降级为字面量搜索
  static RegExp? buildRegex(String pattern, {bool caseSensitive = false}) {
    var cleaned = pattern;
    var multiLine = false;
    var dotAll = false;
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'\(\?([imsuUx]+)\)'),
      (m) {
        final flags = m.group(1)!;
        if (flags.contains('i')) caseSensitive = false;
        if (flags.contains('m')) multiLine = true;
        if (flags.contains('s')) dotAll = true;
        return '';
      },
    );

    try {
      return RegExp(cleaned,
          caseSensitive: caseSensitive,
          multiLine: multiLine,
          dotAll: dotAll);
    } catch (_) {
      try {
        return RegExp(RegExp.escape(cleaned), caseSensitive: caseSensitive);
      } catch (_) {
        return null;
      }
    }
  }
}
