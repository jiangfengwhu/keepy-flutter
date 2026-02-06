import 'dart:convert';

/// 数据记录模型
class DataRecord {
  final int? id;
  final String notebookName;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final DateTime updatedAt;

  DataRecord({
    this.id,
    required this.notebookName,
    required this.data,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory DataRecord.fromDbRow(Map<String, dynamic> row) {
    return DataRecord(
      id: row['id'] as int,
      notebookName: row['notebook_name'] as String,
      data: jsonDecode(row['data_json'] as String) as Map<String, dynamic>,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  Map<String, dynamic> toDbRow() {
    return {
      if (id != null) 'id': id,
      'notebook_name': notebookName,
      'data_json': jsonEncode(data),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 用于 AI 工具响应的简要描述
  Map<String, dynamic> toSummaryJson() {
    return {
      'id': id.toString(),
      'type': notebookName,
      'data': data,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
