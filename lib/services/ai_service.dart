import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';

/// 流式响应事件
sealed class StreamEvent {}

/// 文本块
class TextEvent extends StreamEvent {
  final String text;
  TextEvent(this.text);
}

/// Tool call 开始
class ToolCallStartEvent extends StreamEvent {
  final String name;
  ToolCallStartEvent(this.name);
}

/// Tool call 数据（完整参数）
class ToolCallEvent extends StreamEvent {
  final String name;
  final String args;
  ToolCallEvent(this.name, this.args);
}

/// 流结束
class StreamDoneEvent extends StreamEvent {}

/// 流错误
class StreamErrorEvent extends StreamEvent {
  final String message;
  StreamErrorEvent(this.message);
}

/// AI 服务 - 负责与后端通信
class AiService {
  // TODO: 改为可配置
  static const String _baseUrl = 'http://localhost:8080';

  final HttpClient _client = HttpClient();

  AiService() {
    // 设置超时
    _client.connectionTimeout = const Duration(seconds: 10);
    _client.idleTimeout = const Duration(minutes: 2);
  }

  /// 发送聊天请求，返回流式事件 Stream
  Stream<StreamEvent> sendMessage(List<ChatMessage> chatHistory) async* {
    try {
      final body = jsonEncode({
        'chat_history': chatHistory.map((m) => m.toJson()).toList(),
      });

      final uri = Uri.parse('$_baseUrl/note/process');
      final request = await _client.postUrl(uri);
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');
      final bodyBytes = utf8.encode(body);
      request.headers.set(HttpHeaders.contentLengthHeader, bodyBytes.length.toString());
      request.add(bodyBytes);
      final response = await request.close();

      if (response.statusCode != 200) {
        final errorBody = await response.transform(utf8.decoder).join();
        yield StreamErrorEvent('服务器错误 (${response.statusCode}): $errorBody');
        return;
      }

      // 逐行解析 NDJSON 流
      String buffer = '';
      await for (final chunk in response.transform(utf8.decoder)) {
        buffer += chunk;

        // 按换行符分割，处理每一行
        while (buffer.contains('\n')) {
          final newlineIndex = buffer.indexOf('\n');
          final line = buffer.substring(0, newlineIndex).trim();
          buffer = buffer.substring(newlineIndex + 1);

          if (line.isEmpty) continue;

          final event = _parseLine(line);
          if (event != null) {
            yield event;
          }
        }
      }

      // 处理缓冲区剩余内容
      if (buffer.trim().isNotEmpty) {
        final event = _parseLine(buffer.trim());
        if (event != null) {
          yield event;
        }
      }

      yield StreamDoneEvent();
    } on SocketException catch (e) {
      yield StreamErrorEvent('无法连接到服务器: ${e.message}');
    } on HttpException catch (e) {
      yield StreamErrorEvent('HTTP 错误: ${e.message}');
    } catch (e) {
      yield StreamErrorEvent('请求失败: $e');
    }
  }

  /// 解析单行 NDJSON
  StreamEvent? _parseLine(String line) {
    try {
      final json = jsonDecode(line) as Map<String, dynamic>;
      final type = json['type'] as String?;

      switch (type) {
        case 'text':
          return TextEvent(json['data'] as String? ?? '');
        case 'toolcall_start':
          return ToolCallStartEvent(json['name'] as String? ?? '');
        case 'toolcall':
          return ToolCallEvent(
            json['name'] as String? ?? '',
            json['args'] as String? ?? '',
          );
        default:
          debugPrint('未知流事件类型: $type → $line');
          return null;
      }
    } catch (e) {
      debugPrint('解析流响应失败: $e → $line');
      return null;
    }
  }

  void dispose() {
    _client.close();
  }
}
