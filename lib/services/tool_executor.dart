import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:ui';
import 'package:keepy_flutter/l10n/app_localizations.dart';
import '../models/data_record.dart';
import '../models/notebook.dart';
import '../models/notebook_item.dart';
import 'database_service.dart';
import 'grep_search_service.dart';
import 'notification_service.dart';

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

/// 服务端 Tool 执行状态（用于 UI 展示）
class ServerToolStatus {
  final String name;
  String message;
  bool isRunning;
  bool? success; // null = 运行中, true = 成功, false = 失败

  ServerToolStatus({
    required this.name,
    required this.message,
    this.isRunning = true,
    this.success,
  });

  /// 标记执行完成
  void complete({required bool succeeded, required String endMessage}) {
    isRunning = false;
    success = succeeded;
    message = endMessage;
  }
}

/// 本地 Tool 执行器
class ToolExecutor {
  final DatabaseService _db = DatabaseService();
  final GrepSearchService _grep = GrepSearchService();
  final NotificationService _notify = NotificationService();

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

  // ── 提醒时间解析辅助 ──────────────────────────

  /// 从 tool call 参数中解析提醒时间
  /// 支持 args 中的 reminder_at / reminder_time 字段，
  /// 也支持从 data 对象中提取同名字段
  DateTime? _parseReminderTime(Map<String, dynamic> args,
      [Map<String, dynamic>? data]) {
    // 先从顶层 args 中查找
    final directReminder = args['reminder_at'] ?? args['reminder_time'];
    if (directReminder != null) {
      final parsed = DateTime.tryParse(directReminder.toString());
      if (parsed != null) return parsed;
    }

    // 再从 data 中查找
    if (data != null) {
      for (final key in [
        'reminder_at',
        'reminder_time',
        '提醒时间',
        'remind_at',
        'due_date',
        'deadline',
      ]) {
        final val = data[key];
        if (val != null) {
          final parsed = DateTime.tryParse(val.toString());
          if (parsed != null) return parsed;
        }
      }
    }

    return null;
  }

  /// 为记录调度通知提醒
  Future<void> _scheduleReminderIfNeeded(
      DataRecord record, DateTime? reminderAt) async {
    if (reminderAt == null || record.id == null) return;

    // 更新数据库中的提醒时间
    await _db.updateRecordReminder(record.id!, reminderAt);

    // 从 data 提取摘要作为通知标题
    final summary = _buildNotifySummary(record);

    // 调度通知
    await _notify.scheduleReminder(
      recordId: record.id!,
      reminderAt: reminderAt,
      notebookName: record.notebookName,
      title: summary,
    );
  }

  /// 提取记录摘要用于通知
  String _buildNotifySummary(DataRecord record) {
    final data = record.data;
    for (final key in [
      'title',
      'name',
      '标题',
      '名称',
      '事项',
      '内容',
      'task',
      'content',
    ]) {
      if (data.containsKey(key) && data[key] != null) {
        return data[key].toString();
      }
    }
    if (data.isNotEmpty) {
      final first = data.values.first;
      if (first != null) return first.toString();
    }
    final l10n = _l10nForLocale(PlatformDispatcher.instance.locale);
    return l10n.notificationFallbackBody;
  }

  AppLocalizations _l10nForLocale(Locale locale) {
    return lookupAppLocalizations(locale);
  }

  // ── Tool 实现 ────────────────────────────────

  /// create_data_schema: 创建笔记本
  Future<ToolResult> _createDataSchema(String argsJson) async {
    var notebook = Notebook.fromToolCallArgs(argsJson);
    // 如果 AI 没指定 icon/color，按名称 hash 自动分配
    if (notebook.iconName == null || notebook.colorValue == null) {
      notebook = _withDefaultAppearance(notebook);
    }
    final insertedId = await _db.createNotebook(notebook);
    final saved = await _db.getNotebook(insertedId);

    return ToolResult(
      toolName: 'create_data_schema',
      success: true,
      responseForAi: jsonEncode({
        'status': 'success',
        'message':
            'Schema "${notebook.name}" created successfully with id $insertedId',
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

    // 删除笔记本前，取消所有关联记录的提醒
    if (existing != null) {
      final records = await _db.getRecords(notebookName: name);
      for (final r in records) {
        if (r.id != null && r.hasPendingReminder) {
          await _notify.cancelReminder(r.id!);
        }
      }
    }

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
        'message':
            'Schema "$name" and all its records deleted successfully',
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
      if (args['data'] is Map) {
        data = Map<String, dynamic>.from(args['data'] as Map);
      } else {
        data = {'raw': dataStr};
      }
    }

    // 解析提醒时间
    final reminderAt = _parseReminderTime(args, data);

    final record = DataRecord(
      notebookName: type,
      data: data,
      reminderAt: reminderAt,
    );
    final insertedId = await _db.createRecord(record);
    final saved = await _db.getRecord(insertedId);

    // 如果有提醒时间，调度通知
    if (saved != null && reminderAt != null) {
      await _scheduleReminderIfNeeded(saved, reminderAt);
    }

    return ToolResult(
      toolName: 'add_data_record',
      success: true,
      responseForAi: jsonEncode({
        'status': 'success',
        'message': 'Record added to "$type" with id $insertedId',
        'id': insertedId.toString(),
        'type': type,
        'data': data,
        if (reminderAt != null)
          'reminder_at': reminderAt.toIso8601String(),
      }),
      uiData: {
        'action': 'add_record',
        'record': saved ?? record,
        'type': type,
        'reminder_at': ?reminderAt,
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

    // 检查是否有新的提醒时间
    final reminderAt = _parseReminderTime(args, newData);
    if (updated != null && reminderAt != null) {
      // 先取消旧提醒
      await _notify.cancelReminder(id);
      await _scheduleReminderIfNeeded(updated, reminderAt);
    }

    // 如果 args 中显式清除提醒
    if (args['clear_reminder'] == true || args['remove_reminder'] == true) {
      await _notify.cancelReminder(id);
      await _db.updateRecordReminder(id, null);
    }

    // 重新获取最新数据
    final finalRecord = await _db.getRecord(id);

    return ToolResult(
      toolName: 'update_data_record',
      success: true,
      responseForAi: jsonEncode({
        'status': 'success',
        'message': 'Record $id updated successfully',
        'id': id.toString(),
        'updated_fields': newData.keys.toList(),
        'data': finalRecord?.data,
        if (finalRecord?.reminderAt != null)
          'reminder_at': finalRecord!.reminderAt!.toIso8601String(),
      }),
      uiData: {
        'action': 'update_record',
        'record': finalRecord,
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

    // 先获取记录信息（用于 UI 和取消提醒）
    final record = await _db.getRecord(id);

    // 取消该记录的提醒
    if (record != null && record.hasPendingReminder) {
      await _notify.cancelReminder(id);
    }

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

  /// get_data_record: 查询记录（支持正则 grep 搜索）
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
          uiData: {
            'action': 'get_record',
            'records': <DataRecord>[],
          },
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

    // 有 query 时走 grep 引擎（直接在 data_json 上正则匹配）
    if (query != null && query.isNotEmpty) {
      final records = await _grep.grep(
        pattern: query,
        notebookName: type,
        limit: 20,
      );

      return ToolResult(
        toolName: 'get_data_record',
        success: true,
        responseForAi: jsonEncode({
          'status': 'success',
          'count': records.length,
          'pattern': query,
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

    // 无 query 时简单列出记录
    final records = await _db.getRecords(
      notebookName: type,
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
        'type': type,
      },
    );
  }

  /// 根据名称 hash 为笔记本分配默认图标和颜色
  Notebook _withDefaultAppearance(Notebook nb) {
    final hash = nb.name.hashCode.abs();
    final icons = NotebookItem.availableIcons;
    final colors = NotebookItem.availableColors;
    final icon = icons[hash % icons.length];
    final color = colors[hash % colors.length];
    return Notebook(
      id: nb.id,
      name: nb.name,
      description: nb.description,
      schema: nb.schema,
      iconName: nb.iconName ?? icon.icon.codePoint.toString(),
      iconImagePath: nb.iconImagePath,
      colorValue: nb.colorValue ?? color.value,
      createdAt: nb.createdAt,
      updatedAt: nb.updatedAt,
    );
  }
}
