import 'dart:typed_data';
import 'dart:convert';
import '../services/tool_executor.dart';

/// 多模态消息内容部分
class ContentPart {
  final String type; // "text", "image", "audio", "file"
  final String data; // 文本内容 / base64 编码数据 / URL
  final String? mimeType; // MIME 类型，如 "image/jpeg"
  final Map<String, String>? metadata;

  ContentPart({
    required this.type,
    required this.data,
    this.mimeType,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'type': type, 'data': data};
    if (mimeType != null) json['mime_type'] = mimeType;
    if (metadata != null && metadata!.isNotEmpty) json['metadata'] = metadata;
    return json;
  }

  /// 是否为图片类型
  bool get isImage => type == 'image';

  /// 缓存解码后的图片字节，避免每次 rebuild 重新解码
  Uint8List? _cachedImageBytes;
  bool _imageBytesResolved = false;

  /// 将 base64 图片数据解码为字节（用于 UI 展示）
  /// 自动处理 data:mime;base64, 前缀，结果会缓存
  Uint8List? get imageBytes {
    if (!isImage) return null;
    if (_imageBytesResolved) return _cachedImageBytes;
    _imageBytesResolved = true;
    try {
      String raw = data;
      // 去掉 data URI 前缀（如 data:image/jpeg;base64,）
      final commaIndex = raw.indexOf(',');
      if (commaIndex != -1 && raw.startsWith('data:')) {
        raw = raw.substring(commaIndex + 1);
      }
      _cachedImageBytes = base64Decode(raw);
    } catch (_) {
      _cachedImageBytes = null;
    }
    return _cachedImageBytes;
  }
}

/// 匹配后端协议的聊天消息模型
class ChatMessage {
  String role; // "system", "user", "assistant", "tool"
  String content;
  List<ContentPart>? contentParts; // 多模态内容（与 content 互斥）
  String? toolCallId;
  List<ToolCallInfo>? toolCalls;

  // UI 辅助字段（不序列化）
  bool isStreaming;

  /// UI 显示的文本（如果为 null 则用 content）
  /// 用于隐藏发给 AI 的额外信息（如时间前缀）
  String? displayContent;

  /// Tool call 执行结果（UI 展示用，不序列化）
  List<ToolResult>? toolResults;

  ChatMessage({
    required this.role,
    this.content = '',
    this.contentParts,
    this.toolCallId,
    this.toolCalls,
    this.isStreaming = false,
    this.displayContent,
    this.toolResults,
  });

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';
  bool get isSystem => role == 'system';
  bool get isTool => role == 'tool';

  /// 是否包含图片
  bool get hasImages =>
      contentParts?.any((p) => p.isImage) ?? false;

  /// 获取所有图片部分
  List<ContentPart> get imageParts =>
      contentParts?.where((p) => p.isImage).toList() ?? [];

  /// 是否为纯图片消息（无文字）
  bool get isImageOnly =>
      hasImages &&
      content.isEmpty &&
      (contentParts?.every((p) => p.isImage) ?? false);

  /// 转为后端 API JSON 格式
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'role': role};

    // content 和 content_parts 互斥
    if (contentParts != null && contentParts!.isNotEmpty) {
      json['content_parts'] = contentParts!.map((p) => p.toJson()).toList();
    } else {
      json['content'] = content;
    }

    if (toolCallId != null) {
      json['tool_call_id'] = toolCallId;
    }
    if (toolCalls != null && toolCalls!.isNotEmpty) {
      json['tool_calls'] = toolCalls!.map((t) => t.toJson()).toList();
    }
    return json;
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'] as String,
      content: json['content'] as String? ?? '',
      toolCallId: json['tool_call_id'] as String?,
      toolCalls: (json['tool_calls'] as List?)
          ?.map((t) => ToolCallInfo.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 创建用户消息
  factory ChatMessage.user(String text) =>
      ChatMessage(role: 'user', content: text);

  /// 创建用户图片消息（base64）
  factory ChatMessage.userImage({
    required String base64Data,
    required String mimeType,
  }) =>
      ChatMessage(
        role: 'user',
        contentParts: [
          ContentPart(type: 'image', data: base64Data, mimeType: mimeType),
        ],
      );

  /// 创建 system 消息
  factory ChatMessage.system(String text) =>
      ChatMessage(role: 'system', content: text);

  /// 创建空的 assistant 消息（用于流式填充）
  factory ChatMessage.assistantStreaming() =>
      ChatMessage(role: 'assistant', isStreaming: true);

  /// 创建 tool response 消息
  factory ChatMessage.tool({
    required String content,
    required String toolCallId,
  }) =>
      ChatMessage(role: 'tool', content: content, toolCallId: toolCallId);
}

/// Tool call 信息
class ToolCallInfo {
  final String id;
  final ToolCallFunction function;

  const ToolCallInfo({required this.id, required this.function});

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': 'function',
        'function': function.toJson(),
      };

  factory ToolCallInfo.fromJson(Map<String, dynamic> json) {
    return ToolCallInfo(
      id: json['id'] as String,
      function: ToolCallFunction.fromJson(
        json['function'] as Map<String, dynamic>,
      ),
    );
  }
}

/// Tool call 函数信息
class ToolCallFunction {
  final String name;
  final String arguments;

  const ToolCallFunction({required this.name, required this.arguments});

  Map<String, dynamic> toJson() => {'name': name, 'arguments': arguments};

  factory ToolCallFunction.fromJson(Map<String, dynamic> json) {
    return ToolCallFunction(
      name: json['name'] as String,
      arguments: json['arguments'] as String? ?? '',
    );
  }
}
