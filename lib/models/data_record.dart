import 'dart:convert';

/// 数据记录模型
class DataRecord {
  final int? id;
  final String notebookName;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// 提醒时间（null 表示无提醒）
  final DateTime? reminderAt;

  /// 提醒是否已发送
  final bool reminderSent;

  DataRecord({
    this.id,
    required this.notebookName,
    required this.data,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.reminderAt,
    this.reminderSent = false,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory DataRecord.fromDbRow(Map<String, dynamic> row, {Map<String, dynamic>? parsedData}) {
    final reminderStr = row['reminder_at'] as String?;
    return DataRecord(
      id: row['id'] as int,
      notebookName: row['notebook_name'] as String,
      data: parsedData ?? (jsonDecode(row['data_json'] as String) as Map<String, dynamic>),
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
      reminderAt:
          (reminderStr != null && reminderStr.isNotEmpty)
              ? DateTime.tryParse(reminderStr)
              : null,
      reminderSent: (row['reminder_sent'] as int?) == 1,
    );
  }

  Map<String, dynamic> toDbRow() {
    return {
      if (id != null) 'id': id,
      'notebook_name': notebookName,
      'data_json': jsonEncode(data),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'reminder_at': reminderAt?.toIso8601String() ?? '',
      'reminder_sent': reminderSent ? 1 : 0,
    };
  }

  /// 用于 AI 工具响应的简要描述
  Map<String, dynamic> toSummaryJson() {
    return {
      'id': id.toString(),
      'type': notebookName,
      'data': data,
      'created_at': createdAt.toIso8601String(),
      if (reminderAt != null) 'reminder_at': reminderAt!.toIso8601String(),
    };
  }

  /// 是否有未来的提醒
  bool get hasPendingReminder =>
      reminderAt != null &&
      !reminderSent &&
      reminderAt!.isAfter(DateTime.now());

  /// 是否提醒已过期但未发送
  bool get isReminderOverdue =>
      reminderAt != null &&
      !reminderSent &&
      reminderAt!.isBefore(DateTime.now());

  /// 复制并替换部分字段
  DataRecord copyWith({
    int? id,
    String? notebookName,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? reminderAt,
    bool? reminderSent,
    bool clearReminder = false,
  }) {
    return DataRecord(
      id: id ?? this.id,
      notebookName: notebookName ?? this.notebookName,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reminderAt: clearReminder ? null : (reminderAt ?? this.reminderAt),
      reminderSent: reminderSent ?? this.reminderSent,
    );
  }
}
