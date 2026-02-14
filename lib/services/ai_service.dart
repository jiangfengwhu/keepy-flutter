import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:keepy_flutter/l10n/app_localizations.dart';
import '../models/chat_message.dart';
import 'api_config.dart';
import 'assistant_persona_service.dart';
import 'ticket_service.dart';

/// 流式响应事件
sealed class StreamEvent {}

/// 文本块
class TextEvent extends StreamEvent {
  final String text;
  TextEvent(this.text);
}

/// Tool call 开始（本地或服务端）
class ToolCallStartEvent extends StreamEvent {
  final String name;
  final bool isServer;
  final String message; // 服务端 tool 的提示文案
  ToolCallStartEvent(this.name, {this.isServer = false, this.message = ''});
}

/// Tool call 数据（本地执行用 args，服务端用 message/success/result）
class ToolCallEvent extends StreamEvent {
  final String name;
  final String args;
  final bool isServer;
  final String message; // 服务端 tool 的结果描述
  final bool success; // 服务端 tool 是否成功
  final String result; // 服务端 tool 的执行结果（JSON 字符串）
  ToolCallEvent(
    this.name,
    this.args, {
    this.isServer = false,
    this.message = '',
    this.success = false,
    this.result = '',
  });
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
  static const String _baseUrl = apiBaseUrl;

  final HttpClient _client = HttpClient();
  final AssistantPersonaService _personaService = AssistantPersonaService();

  AiService() {
    // 设置超时
    _client.connectionTimeout = const Duration(seconds: 10);
    _client.idleTimeout = const Duration(minutes: 2);
  }

  /// 发送聊天请求，返回流式事件 Stream
  Stream<StreamEvent> sendMessage(List<ChatMessage> chatHistory) async* {
    try {
      final persona = await _personaService.getPersona();
      final payloadHistory = <ChatMessage>[...chatHistory];
      if (persona.isNotEmpty &&
          (payloadHistory.isEmpty || !payloadHistory.first.isSystem)) {
        payloadHistory.insert(0, ChatMessage.system(persona));
      }
      final body = jsonEncode({
        'chat_history': payloadHistory.map((m) => m.toJson()).toList(),
      });

      final uri = Uri.parse('$_baseUrl/note/process');
      final request = await _client.postUrl(uri);
      request.headers.set(
        HttpHeaders.contentTypeHeader,
        'application/json; charset=utf-8',
      );
      final ticketId = await TicketService().getTicketId();
      if (ticketId != null) {
        request.headers.set('X-Ticket-ID', ticketId);
      }
      final bodyBytes = utf8.encode(body);
      request.headers.set(
        HttpHeaders.contentLengthHeader,
        bodyBytes.length.toString(),
      );
      request.add(bodyBytes);
      final response = await request.close();

      if (response.statusCode != 200) {
        final errorBody = await response.transform(utf8.decoder).join();
        final l10n = _l10nForLocale(PlatformDispatcher.instance.locale);
        yield StreamErrorEvent(
          l10n.aiServerError(response.statusCode, errorBody),
        );
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
      final l10n = _l10nForLocale(PlatformDispatcher.instance.locale);
      yield StreamErrorEvent(l10n.aiConnectionError(e.message));
    } on HttpException catch (e) {
      final l10n = _l10nForLocale(PlatformDispatcher.instance.locale);
      yield StreamErrorEvent(l10n.aiHttpError(e.message));
    } catch (e) {
      final l10n = _l10nForLocale(PlatformDispatcher.instance.locale);
      yield StreamErrorEvent(l10n.aiRequestFailedError(e.toString()));
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
          return ToolCallStartEvent(
            json['name'] as String? ?? '',
            isServer: json['is_server'] as bool? ?? false,
            message: json['message'] as String? ?? '',
          );
        case 'toolcall':
          return ToolCallEvent(
            json['name'] as String? ?? '',
            json['args'] as String? ?? '',
            isServer: json['is_server'] as bool? ?? false,
            message: json['message'] as String? ?? '',
            success: json['success'] as bool? ?? false,
            result: json['result'] as String? ?? '',
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

  AppLocalizations _l10nForLocale(Locale locale) {
    return lookupAppLocalizations(locale);
  }
}
