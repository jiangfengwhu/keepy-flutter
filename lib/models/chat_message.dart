import '../services/tool_executor.dart';

/// 匹配后端协议的聊天消息模型
class ChatMessage {
  String role; // "system", "user", "assistant", "tool"
  String content;
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

  /// 转为后端 API JSON 格式
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'role': role, 'content': content};
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
