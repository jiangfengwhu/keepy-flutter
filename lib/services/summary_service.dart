import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import 'api_config.dart';
import 'database_service.dart';
import 'ticket_service.dart';

/// AI 周报缓存键
const _kSummaryText = 'summary_text';
const _kSummaryTime = 'summary_time';

/// AI 周报服务 — 调用 /note/summary，每天最多一次，本地缓存
class SummaryService {
  static final SummaryService _instance = SummaryService._internal();
  factory SummaryService() => _instance;
  SummaryService._internal();

  static const String _baseUrl = apiBaseUrl;
  final DatabaseService _db = DatabaseService();

  /// 获取周报内容（优先读缓存，超过 24h 才请求）
  ///
  /// [onStreaming] 可选回调，流式内容实时推送（用于 UI 动效）
  /// 返回完整文本；如果请求失败且无缓存，返回 null
  Future<String?> getSummary({
    void Function(String partial)? onStreaming,
  }) async {
    // 1. 检查缓存
    final lastTimeStr = await _db.getKv(_kSummaryTime);
    final cachedText = await _db.getKv(_kSummaryText);

    if (lastTimeStr != null && cachedText != null && cachedText.isNotEmpty) {
      final lastTime = DateTime.tryParse(lastTimeStr);
      if (lastTime != null) {
        final elapsed = DateTime.now().difference(lastTime);
        if (elapsed.inHours < 24) {
          debugPrint('SummaryService: 使用缓存（${elapsed.inHours}h ago）');
          return cachedText;
        }
      }
    }

    // 2. 收集近 7 天数据，组装用户消息
    final userMessage = await _buildUserMessage();
    if (userMessage.isEmpty) {
      debugPrint('SummaryService: 近 7 天无数据，跳过请求');
      return cachedText; // 返回旧缓存或 null
    }

    // 3. 请求 /note/summary（流式）
    try {
      final result = await _requestSummary(userMessage, onStreaming);
      if (result != null && result.isNotEmpty) {
        // 4. 写入缓存
        await _db.setKv(_kSummaryText, result);
        await _db.setKv(_kSummaryTime, DateTime.now().toIso8601String());
        debugPrint('SummaryService: 周报已更新并缓存');
        return result;
      }
    } catch (e) {
      debugPrint('SummaryService: 请求失败: $e');
    }

    // 失败时返回旧缓存
    return cachedText;
  }

  /// 收集近 7 天的小本创建与数据添加记录
  Future<String> _buildUserMessage() async {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    // 近 7 天创建的小本
    final allNotebooks = await _db.getAllNotebooks();
    final recentNotebooks = allNotebooks
        .where((nb) => nb.createdAt.isAfter(sevenDaysAgo))
        .toList();

    // 近 7 天添加的记录
    final recentRecords = await _db.getRecentRecords(limit: 200);
    final filteredRecords = recentRecords
        .where((r) => r.createdAt.isAfter(sevenDaysAgo))
        .toList();

    if (recentNotebooks.isEmpty && filteredRecords.isEmpty) {
      return '';
    }

    final buf = StringBuffer();
    buf.writeln('以下是我近 7 天的记录数据，请帮我生成本周总结和建议：');
    buf.writeln();

    if (recentNotebooks.isNotEmpty) {
      buf.writeln('## 新建小本（${recentNotebooks.length} 个）');
      for (final nb in recentNotebooks) {
        buf.writeln('- ${nb.name}（${nb.schema.map((f) => f.field).join('、')}）');
      }
      buf.writeln();
    }

    if (filteredRecords.isNotEmpty) {
      // 按小本名分组
      final grouped = <String, List<Map<String, dynamic>>>{};
      for (final r in filteredRecords) {
        grouped.putIfAbsent(r.notebookName, () => []).add(r.data);
      }

      buf.writeln('## 新增记录（共 ${filteredRecords.length} 条）');
      for (final entry in grouped.entries) {
        buf.writeln('### ${entry.key}（${entry.value.length} 条）');
        // 最多列出 10 条的摘要
        for (var i = 0; i < entry.value.length && i < 10; i++) {
          final data = entry.value[i];
          final summary = data.entries
              .where((e) => e.value != null && e.value.toString().isNotEmpty)
              .take(3)
              .map((e) => '${e.key}: ${e.value}')
              .join('，');
          buf.writeln('- $summary');
        }
        if (entry.value.length > 10) {
          buf.writeln('- …还有 ${entry.value.length - 10} 条');
        }
        buf.writeln();
      }
    }

    // 附加全部已有小本信息
    buf.writeln('## 我的所有小本（${allNotebooks.length} 个）');
    for (final nb in allNotebooks) {
      buf.writeln('- ${nb.name}：${nb.description.isEmpty ? "无描述" : nb.description}');
    }

    return buf.toString();
  }

  /// 调用 /note/summary 流式接口
  Future<String?> _requestSummary(
    String userMessage,
    void Function(String partial)? onStreaming,
  ) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 10);
    client.idleTimeout = const Duration(minutes: 2);

    try {
      final history = [
        ChatMessage.user(userMessage),
      ];

      final body = jsonEncode({
        'chat_history': history.map((m) => m.toJson()).toList(),
      });

      final uri = Uri.parse('$_baseUrl/note/summary');
      final request = await client.postUrl(uri);
      request.headers
          .set(HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');
      final ticketId = await TicketService().getTicketId();
      if (ticketId != null) {
        request.headers.set('X-Ticket-ID', ticketId);
      }
      final bodyBytes = utf8.encode(body);
      request.headers
          .set(HttpHeaders.contentLengthHeader, bodyBytes.length.toString());
      request.add(bodyBytes);
      final response = await request.close();

      if (response.statusCode != 200) {
        final errorBody = await response.transform(utf8.decoder).join();
        debugPrint('SummaryService: 服务器错误 (${response.statusCode}): $errorBody');
        return null;
      }

      // 逐行解析 NDJSON 流，只收集 text 类型
      final result = StringBuffer();
      String buffer = '';

      await for (final chunk in response.transform(utf8.decoder)) {
        buffer += chunk;
        while (buffer.contains('\n')) {
          final idx = buffer.indexOf('\n');
          final line = buffer.substring(0, idx).trim();
          buffer = buffer.substring(idx + 1);
          if (line.isEmpty) continue;

          try {
            final json = jsonDecode(line) as Map<String, dynamic>;
            if (json['type'] == 'text') {
              final text = json['data'] as String? ?? '';
              result.write(text);
              onStreaming?.call(result.toString());
            }
          } catch (_) {}
        }
      }

      // 处理剩余
      if (buffer.trim().isNotEmpty) {
        try {
          final json = jsonDecode(buffer.trim()) as Map<String, dynamic>;
          if (json['type'] == 'text') {
            result.write(json['data'] as String? ?? '');
          }
        } catch (_) {}
      }

      return result.toString();
    } finally {
      client.close();
    }
  }
}
