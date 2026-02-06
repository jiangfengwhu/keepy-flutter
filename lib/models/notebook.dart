import 'dart:convert';

// ── 编辑页面使用的旧模型（兼容） ──────────────

enum DataFieldType {
  text,
  number,
  date,
  checkbox;

  String get displayName {
    switch (this) {
      case DataFieldType.text:
        return '文本';
      case DataFieldType.number:
        return '数字';
      case DataFieldType.date:
        return '日期';
      case DataFieldType.checkbox:
        return '选项';
    }
  }

  /// 转为 SchemaField 的 type 字符串
  String get schemaType {
    switch (this) {
      case DataFieldType.text:
        return 'string';
      case DataFieldType.number:
        return 'number';
      case DataFieldType.date:
        return 'date';
      case DataFieldType.checkbox:
        return 'boolean';
    }
  }
}

class DataFieldDefinition {
  final String id;
  String name;
  DataFieldType type;
  String description;

  DataFieldDefinition({
    String? id,
    required this.name,
    required this.type,
    this.description = '',
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  /// 转为 SchemaField
  SchemaField toSchemaField() => SchemaField(
        field: name,
        type: type.schemaType,
        description: description,
      );
}

// ── 核心笔记本模型（数据库序列化） ──────────────

/// 笔记本数据模型（支持数据库序列化）
class Notebook {
  final int? id;
  final String name;
  final String description;
  final List<SchemaField> schema;
  final DateTime createdAt;
  final DateTime updatedAt;

  Notebook({
    this.id,
    required this.name,
    this.description = '',
    required this.schema,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// 从 AI tool call 的 args JSON 创建
  factory Notebook.fromToolCallArgs(String argsJson) {
    final json = jsonDecode(argsJson) as Map<String, dynamic>;
    return Notebook(
      name: json['name'] as String? ?? '未命名小本',
      description: json['description'] as String? ?? '',
      schema: (json['schema'] as List?)
              ?.map((f) => SchemaField.fromJson(f as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// 从数据库行创建
  factory Notebook.fromDbRow(Map<String, dynamic> row) {
    return Notebook(
      id: row['id'] as int,
      name: row['name'] as String,
      description: row['description'] as String? ?? '',
      schema: (jsonDecode(row['schema_json'] as String) as List)
          .map((f) => SchemaField.fromJson(f as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  /// 转为数据库行
  Map<String, dynamic> toDbRow() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'schema_json': jsonEncode(schema.map((f) => f.toJson()).toList()),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Schema 字段定义
class SchemaField {
  final String field;
  final String type;
  final String description;

  const SchemaField({
    required this.field,
    required this.type,
    this.description = '',
  });

  factory SchemaField.fromJson(Map<String, dynamic> json) {
    return SchemaField(
      field: json['field'] as String? ?? '',
      type: json['type'] as String? ?? 'string',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'field': field,
        'type': type,
        'description': description,
      };

  /// 类型的中文显示
  String get typeDisplay {
    switch (type) {
      case 'string':
        return '文本';
      case 'number':
        return '数字';
      case 'date':
        return '日期';
      case 'boolean':
        return '选项';
      default:
        return type;
    }
  }
}
