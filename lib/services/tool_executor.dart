import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/data_record.dart';
import '../models/notebook.dart';
import 'database_service.dart';

/// Tool 执行结果
class ToolResult {
  final String toolName;
  final bool success;
  final String responseForAi; // 发送给 AI 的 tool response content
  final Map<String, dynamic>? uiData; // 给 UI 展示的结构化数据

  const ToolResult({
    required this.toolName,
    required this.success,
    required this.responseForAi,
    this.uiData,
  });
}

/// 本地 Tool 执行器
class ToolExecutor {
  final DatabaseService _db = DatabaseService();

  /// 根据 tool name 和 args 执行对应操作
  Future<ToolResult> execute(String name, String argsJson) async {
    try {
      switch (name) {
        case 'create_data_schema':
          return await _createDataSchema(argsJson);
        case 'update_data_schema':
          return await _updateDataSchema(argsJson);
        case 'delete_data_schema':
          return await _deleteDataSchema(argsJson);
        case 'add_data_record':
          return await _addDataRecord(argsJson);
        case 'update_data_record':
          return await _updateDataRecord(argsJson);
        case 'delete_data_record':
          return await _deleteDataRecord(argsJson);
        case 'get_data_record':
          return await _getDataRecord(argsJson);
        default:
          return ToolResult(
            toolName: name,
            success: false,
            responseForAi: 'Unknown tool: $name',
          );
      }
    } catch (e) {
      debugPrint('Tool execution error ($name): $e');
      return ToolResult(
        toolName: name,
        success: false,
        responseForAi: 'Error executing $name: $e',
      );
    }
  }

  /// create_data_schema: 创建笔记本
  Future<ToolResult> _createDataSchema(String argsJson) async {
    final notebook = Notebook.fromToolCallArgs(argsJson);
    final insertedId = await _db.createNotebook(notebook);
    final saved = await _db.getNotebook(insertedId);

    return ToolResult(
      toolName: 'create_data_schema',
      success: true,
      responseForAi: jsonEncode({
        'status': 'success',
        'message': 'Schema "${notebook.name}" created successfully with id $insertedId',
        'id': insertedId,
        'name': notebook.name,
        'fields': notebook.schema.map((f) => f.field).toList(),
      }),
      uiData: {
        'action': 'create_schema',
        'notebook': saved ?? notebook,
      },
    );
  }

  /// update_data_schema: 更新笔记本 schema
  Future<ToolResult> _updateDataSchema(String argsJson) async {
    final args = jsonDecode(argsJson) as Map<String, dynamic>;
    final name = args['name'] as String? ?? '';
    final description = args['description'] as String?;
    final schemaList = args['schema'] as List?;

    List<SchemaField>? newSchema;
    if (schemaList != null) {
      newSchema = schemaList
          .map((f) => SchemaField.fromJson(f as Map<String, dynamic>))
          .toList();
    }

    final updated = await _db.updateNotebookByName(
      name,
      newDescription: description,
      newSchema: newSchema,
    );

    if (updated == null) {
      return ToolResult(
        toolName: 'update_data_schema',
        success: false,
        responseForAi: 'Schema "$name" not found',
      );
    }

    return ToolResult(
      toolName: 'update_data_schema',
      success: true,
      responseForAi: jsonEncode({
        'status': 'success',
        'message': 'Schema "$name" updated successfully',
        'name': updated.name,
        'fields': updated.schema.map((f) => f.field).toList(),
      }),
      uiData: {
        'action': 'update_schema',
        'notebook': updated,
      },
    );
  }

  /// delete_data_schema: 删除笔记本
  Future<ToolResult> _deleteDataSchema(String argsJson) async {
    final args = jsonDecode(argsJson) as Map<String, dynamic>;
    final name = args['name'] as String? ?? '';

    final existing = await _db.getNotebookByName(name);
    final deleted = await _db.deleteNotebookByName(name);

    if (!deleted) {
      return ToolResult(
        toolName: 'delete_data_schema',
        success: false,
        responseForAi: 'Schema "$name" not found',
      );
    }

    return ToolResult(
      toolName: 'delete_data_schema',
      success: true,
      responseForAi: jsonEncode({
        'status': 'success',
        'message': 'Schema "$name" and all its records deleted successfully',
      }),
      uiData: {
        'action': 'delete_schema',
        'name': name,
        'notebook': existing,
      },
    );
  }

  /// add_data_record: 添加记录
  Future<ToolResult> _addDataRecord(String argsJson) async {
    final args = jsonDecode(argsJson) as Map<String, dynamic>;
    final type = args['type'] as String? ?? '';
    final dataStr = args['data'] as String? ?? '{}';

    Map<String, dynamic> data;
    try {
      data = jsonDecode(dataStr) as Map<String, dynamic>;
    } catch (_) {
      // 如果 data 不是 JSON 字符串，尝试直接当 Map 用
      if (args['data'] is Map) {
        data = Map<String, dynamic>.from(args['data'] as Map);
      } else {
        data = {'raw': dataStr};
      }
    }

    final record = DataRecord(notebookName: type, data: data);
    final insertedId = await _db.createRecord(record);
    final saved = await _db.getRecord(insertedId);

    return ToolResult(
      toolName: 'add_data_record',
      success: true,
      responseForAi: jsonEncode({
        'status': 'success',
        'message': 'Record added to "$type" with id $insertedId',
        'id': insertedId.toString(),
        'type': type,
        'data': data,
      }),
      uiData: {
        'action': 'add_record',
        'record': saved ?? record,
        'type': type,
      },
    );
  }

  /// update_data_record: 更新记录
  Future<ToolResult> _updateDataRecord(String argsJson) async {
    final args = jsonDecode(argsJson) as Map<String, dynamic>;
    final idStr = args['id'] as String? ?? '';
    final dataStr = args['data'] as String? ?? '{}';

    final id = int.tryParse(idStr);
    if (id == null) {
      return ToolResult(
        toolName: 'update_data_record',
        success: false,
        responseForAi: 'Invalid record id: $idStr',
      );
    }

    Map<String, dynamic> newData;
    try {
      newData = jsonDecode(dataStr) as Map<String, dynamic>;
    } catch (_) {
      if (args['data'] is Map) {
        newData = Map<String, dynamic>.from(args['data'] as Map);
      } else {
        return ToolResult(
          toolName: 'update_data_record',
          success: false,
          responseForAi: 'Invalid data format: $dataStr',
        );
      }
    }

    final affected = await _db.updateRecord(id, newData);
    if (affected == 0) {
      return ToolResult(
        toolName: 'update_data_record',
        success: false,
        responseForAi: 'Record with id $id not found',
      );
    }

    final updated = await _db.getRecord(id);

    return ToolResult(
      toolName: 'update_data_record',
      success: true,
      responseForAi: jsonEncode({
        'status': 'success',
        'message': 'Record $id updated successfully',
        'id': id.toString(),
        'updated_fields': newData.keys.toList(),
        'data': updated?.data,
      }),
      uiData: {
        'action': 'update_record',
        'record': updated,
        'updated_fields': newData.keys.toList(),
      },
    );
  }

  /// delete_data_record: 删除记录
  Future<ToolResult> _deleteDataRecord(String argsJson) async {
    final args = jsonDecode(argsJson) as Map<String, dynamic>;
    final idStr = args['id'] as String? ?? '';

    final id = int.tryParse(idStr);
    if (id == null) {
      return ToolResult(
        toolName: 'delete_data_record',
        success: false,
        responseForAi: 'Invalid record id: $idStr',
      );
    }

    // 先获取记录信息（用于 UI）
    final record = await _db.getRecord(id);
    final affected = await _db.deleteRecord(id);

    if (affected == 0) {
      return ToolResult(
        toolName: 'delete_data_record',
        success: false,
        responseForAi: 'Record with id $id not found',
      );
    }

    return ToolResult(
      toolName: 'delete_data_record',
      success: true,
      responseForAi: jsonEncode({
        'status': 'success',
        'message': 'Record $id deleted successfully',
        'id': id.toString(),
      }),
      uiData: {
        'action': 'delete_record',
        'deleted_id': id,
        'record': record,
      },
    );
  }

  /// get_data_record: 查询记录
  Future<ToolResult> _getDataRecord(String argsJson) async {
    final args = jsonDecode(argsJson) as Map<String, dynamic>;
    final query = args['query'] as String?;
    final type = args['type'] as String?;
    final idStr = args['id'] as String?;

    // 如果指定了 id，直接获取单条
    if (idStr != null && idStr.isNotEmpty) {
      final id = int.tryParse(idStr);
      if (id == null) {
        return ToolResult(
          toolName: 'get_data_record',
          success: false,
          responseForAi: 'Invalid record id: $idStr',
        );
      }

      final record = await _db.getRecord(id);
      if (record == null) {
        return ToolResult(
          toolName: 'get_data_record',
          success: true,
          responseForAi: jsonEncode({
            'status': 'success',
            'message': 'Record not found',
            'records': [],
          }),
          uiData: {'action': 'get_record', 'records': <DataRecord>[]},
        );
      }

      return ToolResult(
        toolName: 'get_data_record',
        success: true,
        responseForAi: jsonEncode({
          'status': 'success',
          'records': [record.toSummaryJson()],
        }),
        uiData: {
          'action': 'get_record',
          'records': [record],
        },
      );
    }

    // 否则按条件搜索
    final records = await _db.getRecords(
      notebookName: type,
      query: query,
      limit: 20,
    );

    return ToolResult(
      toolName: 'get_data_record',
      success: true,
      responseForAi: jsonEncode({
        'status': 'success',
        'count': records.length,
        'records': records.map((r) => r.toSummaryJson()).toList(),
      }),
      uiData: {
        'action': 'get_record',
        'records': records,
        'query': query,
        'type': type,
      },
    );
  }
}
