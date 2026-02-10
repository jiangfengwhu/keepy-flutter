import 'dart:convert';
import 'dart:ui';
import 'package:keepy_flutter/l10n/app_localizations.dart';

// ── 编辑页面使用的旧模型（兼容） ──────────────

enum DataFieldType {
  text,
  number,
  date;

  String displayName(AppLocalizations l10n) {
    switch (this) {
      case DataFieldType.text:
        return l10n.fieldTypeText;
      case DataFieldType.number:
        return l10n.fieldTypeNumber;
      case DataFieldType.date:
        return l10n.fieldTypeDate;
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
    }
  }
}

class DataFieldDefinition {
  final String id;
  String name;
  DataFieldType type;
  String description;

  /// 编辑已有字段时记录原始名称，用于检测重命名
  final String? originalName;

  /// 编辑模式下标记是否为已有字段（类型不可变更）
  final bool isExisting;

  DataFieldDefinition({
    String? id,
    required this.name,
    required this.type,
    this.description = '',
    this.originalName,
    this.isExisting = false,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  /// 从 SchemaField 创建（编辑模式用）
  factory DataFieldDefinition.fromSchemaField(SchemaField field) {
    return DataFieldDefinition(
      name: field.field,
      type: _parseType(field.type),
      description: field.description,
      originalName: field.field,
      isExisting: true,
    );
  }

  static DataFieldType _parseType(String type) {
    return switch (type) {
      'number' => DataFieldType.number,
      'date' => DataFieldType.date,
      _ => DataFieldType.text,
    };
  }

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
  final String? iconName;   // Material Icon 名称（如 'auto_stories_rounded'）
  final String? iconImagePath; // 用户上传图标的本地路径
  final int? colorValue;    // 颜色值（如 0xFF8B5CF6）
  final DateTime createdAt;
  final DateTime updatedAt;

  Notebook({
    this.id,
    required this.name,
    this.description = '',
    required this.schema,
    this.iconName,
    this.iconImagePath,
    this.colorValue,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// 从 AI tool call 的 args JSON 创建
  factory Notebook.fromToolCallArgs(String argsJson) {
    final json = jsonDecode(argsJson) as Map<String, dynamic>;
    final l10n = lookupAppLocalizations(PlatformDispatcher.instance.locale);
    return Notebook(
      name: json['name'] as String? ?? l10n.unnamedNotebook,
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
      iconName: _nonEmpty(row['icon_name']),
      iconImagePath: _nonEmpty(row['icon_image_path']),
      colorValue: row['color_value'] as int?,
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
      'icon_name': iconName ?? '',
      'icon_image_path': iconImagePath ?? '',
      'color_value': colorValue,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static String? _nonEmpty(dynamic v) {
    if (v == null) return null;
    final s = v.toString();
    return s.isEmpty ? null : s;
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

  String typeDisplay(AppLocalizations l10n) {
    switch (type) {
      case 'string':
        return l10n.fieldTypeText;
      case 'number':
        return l10n.fieldTypeNumber;
      case 'date':
        return l10n.fieldTypeDate;
      default:
        return type;
    }
  }
}
