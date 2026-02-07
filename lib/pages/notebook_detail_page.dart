import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/data_record.dart';
import '../models/notebook.dart';
import '../models/notebook_item.dart';
import '../services/database_service.dart';
import '../theme/miaoji_theme.dart';
import 'notebook_edit_page.dart';
import 'record_detail_page.dart';

/// 小本详情页 — 纸质拟物风格
class NotebookDetailPage extends StatefulWidget {
  final NotebookItem notebookItem;

  const NotebookDetailPage({super.key, required this.notebookItem});

  @override
  State<NotebookDetailPage> createState() => _NotebookDetailPageState();
}

class _NotebookDetailPageState extends State<NotebookDetailPage>
    with SingleTickerProviderStateMixin {
  final DatabaseService _db = DatabaseService();
  late AnimationController _enterController;

  Notebook? _notebook;
  List<DataRecord> _records = [];
  bool _isLoading = true;
  late NotebookItem _item;

  @override
  void initState() {
    super.initState();
    _item = widget.notebookItem;
    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _loadData();
  }

  @override
  void dispose() {
    _enterController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      Notebook? notebook;
      if (_item.dbId != null) {
        notebook = await _db.getNotebook(_item.dbId!);
      }
      notebook ??= await _db.getNotebookByName(_item.title);

      final records = await _db.getRecords(notebookName: notebook?.name ?? _item.title);

      if (!mounted) return;
      setState(() {
        _notebook = notebook;
        _records = records;
        _isLoading = false;
      });
      _enterController.forward();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _enterController.forward();
    }
  }

  /// 导航到编辑页面
  void _showStats() {
    if (_notebook == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StatsSheet(
        records: _records,
        schema: _notebook!.schema,
        accentColor: _item.iconColor,
      ),
    );
  }

  Future<void> _navigateToEdit() async {
    if (_notebook == null) return;

    final result = await Navigator.of(context).push<NotebookEditResult>(
      MaterialPageRoute(
        builder: (_) => NotebookEditPage(existingNotebook: _notebook),
      ),
    );

    if (result != null && mounted) {
      // 编辑成功，刷新数据和 item 信息
      setState(() {
        _notebook = result.notebook;
        _item = NotebookItem.fromNotebook(result.notebook);
      });
      _loadData();
    }
  }

  Future<void> _deleteRecord(DataRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('删除后无法恢复，确定要删除这条记录吗？'),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除',
                style: TextStyle(color: MiaojiColors.error)),
          ),
        ],
      ),
    );

    if (confirmed != true || record.id == null) return;

    await _db.deleteRecord(record.id!);
    HapticFeedback.lightImpact();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final safePadding = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: MiaojiColors.background,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: MiaojiColors.primary))
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 顶部 AppBar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        20, safePadding.top + 8, 20, 0),
                    child: _buildAppBar(),
                  ),
                ),

                // 小本封面卡片
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: _buildAnimated(
                      interval: const Interval(0.0, 0.5,
                          curve: Curves.easeOutCubic),
                      child: _buildCoverCard(),
                    ),
                  ),
                ),

                // 记录列表标题
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: _buildAnimated(
                      interval: const Interval(0.15, 0.6,
                          curve: Curves.easeOutCubic),
                      child: _buildRecordsHeader(),
                    ),
                  ),
                ),

                // 记录列表或空状态
                if (_records.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyRecords(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final delay = 0.2 + index * 0.06;
                          final end = (delay + 0.35).clamp(0.0, 1.0);
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index < _records.length - 1 ? 12 : 0,
                            ),
                            child: _buildAnimated(
                              interval: Interval(delay, end,
                                  curve: Curves.easeOutCubic),
                              child:
                                  _buildRecordCard(_records[index], index),
                            ),
                          );
                        },
                        childCount: _records.length,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  // ── AppBar ────────────────────────────────────

  Widget _buildAppBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: MiaojiColors.card,
              borderRadius: BorderRadius.circular(12),
              boxShadow: MiaojiShadows.sm,
              border: Border.all(
                  color: MiaojiColors.borderLight, width: 1),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: MiaojiColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            _item.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: MiaojiColors.textPrimary,
              letterSpacing: -0.3,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 14),
        // 统计按钮（仅当 schema 含 number 字段时显示）
        if (_notebook != null &&
            _notebook!.schema.any((f) => f.type == 'number')) ...[
          GestureDetector(
            onTap: _showStats,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: MiaojiColors.card,
                borderRadius: BorderRadius.circular(12),
                boxShadow: MiaojiShadows.sm,
                border: Border.all(
                    color: MiaojiColors.borderLight, width: 1),
              ),
              child: const Icon(
                Icons.bar_chart_rounded,
                size: 17,
                color: MiaojiColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        GestureDetector(
          onTap: _navigateToEdit,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: MiaojiColors.card,
              borderRadius: BorderRadius.circular(12),
              boxShadow: MiaojiShadows.sm,
              border: Border.all(
                  color: MiaojiColors.borderLight, width: 1),
            ),
            child: const Icon(
              Icons.edit_outlined,
              size: 16,
              color: MiaojiColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  // ── 封面卡片（笔记本封面风格） ─────────────────────

  Widget _buildCoverCard() {
    final recordCount = _records.length;
    final fieldCount = _notebook?.schema.length ?? 0;

    return Stack(
      children: [
        // 底部纸张层
        Positioned(
          left: 4,
          right: 0,
          top: 4,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF0E8D6),
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
        // 主封面
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: MiaojiColors.paperGradient,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: MiaojiColors.borderLight, width: 1),
            boxShadow: MiaojiShadows.paper,
          ),
          child: Row(
            children: [
              // 封面图标
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _item.iconBg.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _item.iconColor.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child:
                    Icon(_item.icon, color: _item.iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _item.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: MiaojiColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (_notebook?.description.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(
                        _notebook!.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: MiaojiColors.textTertiary,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatChip(
                          Icons.description_outlined,
                          '$fieldCount 个字段',
                          _item.iconColor,
                        ),
                        const SizedBox(width: 10),
                        _buildStatChip(
                          Icons.layers_outlined,
                          '$recordCount 条记录',
                          _item.iconColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // 左侧装订线
        Positioned(
          left: 0,
          top: 12,
          bottom: 12,
          child: Container(
            width: 4,
            decoration: BoxDecoration(
              color: _item.iconColor.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  (IconData, Color) _fieldTypeStyle(String type) {
    return switch (type) {
      'string' => (Icons.text_fields_rounded, const Color(0xFF5B7FA5)),
      'number' => (Icons.tag_rounded, const Color(0xFFD4A24C)),
      'date' => (Icons.calendar_today_rounded, const Color(0xFF8B6BAD)),
      _ => (Icons.data_object_rounded, const Color(0xFF8B7355)),
    };
  }

  // ── 记录列表标题 ──────────────────────────────

  Widget _buildRecordsHeader() {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: MiaojiColors.primary,
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          '记录列表',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: MiaojiColors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(width: 8),
        if (_records.isNotEmpty)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: MiaojiColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${_records.length}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: MiaojiColors.primary,
              ),
            ),
          ),
      ],
    );
  }

  // ── 空记录状态 ────────────────────────────────

  Widget _buildEmptyRecords() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: MiaojiColors.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: MiaojiColors.borderLight, width: 1.5),
              boxShadow: MiaojiShadows.paper,
            ),
            child: const Icon(
              Icons.note_add_outlined,
              size: 30,
              color: MiaojiColors.textHint,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '暂无记录',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: MiaojiColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '试试和 AI 助手说「帮我记一笔 ${_item.title}」',
            style: TextStyle(
              fontSize: 13,
              color: MiaojiColors.textTertiary.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── 记录卡片（横线信纸风格） ─────────────────────

  Widget _buildRecordCard(DataRecord record, int index) {
    final entries = record.data.entries.toList();
    final schemaFields = _notebook?.schema ?? [];

    return Dismissible(
      key: ValueKey(record.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        _deleteRecord(record);
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: MiaojiColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: MiaojiColors.error,
          size: 22,
        ),
      ),
      child: GestureDetector(
        onTap: () => _openReadMode(record),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: MiaojiColors.card,
            borderRadius: BorderRadius.circular(14),
            boxShadow: MiaojiShadows.paper,
            border: Border.all(
                color: MiaojiColors.borderLight, width: 1),
          ),
          child: CustomPaint(
          painter: _LinedPaperPainter(
            lineColor: MiaojiColors.divider.withValues(alpha: 0.5),
            lineSpacing: 28.0,
            topOffset: 44.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部：编号条 + 时间
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: MiaojiColors.divider.withValues(alpha: 0.6),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // 编号标签
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color:
                            _item.iconColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '#${record.id}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _item.iconColor,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    // 提醒状态标签
                    if (record.reminderAt != null) ...[
                      const SizedBox(width: 8),
                      _buildReminderBadge(record),
                    ],
                    const Spacer(),
                    Icon(
                      Icons.access_time_rounded,
                      size: 12,
                      color: MiaojiColors.textHint
                          .withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(record.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: MiaojiColors.textHint
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // 字段列表（在横线上书写的感觉）
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                child: Column(
                  children: entries.map((entry) {
                    final schema = schemaFields
                        .where((s) => s.field == entry.key)
                        .firstOrNull;
                    final fieldType = schema?.type ?? 'string';
                    final (iconData, color) =
                        _fieldTypeStyle(fieldType);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 字段名（左边距标签）
                          SizedBox(
                            width: 88,
                            child: Row(
                              children: [
                                Icon(iconData,
                                    size: 12, color: color),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    entry.key,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: color
                                          .withValues(alpha: 0.7),
                                    ),
                                    overflow:
                                        TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // 字段值 — 点击编辑
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                _editFieldValue(
                                  record,
                                  entry.key,
                                  fieldType,
                                  entry.value,
                                );
                              },
                              child: Text(
                                _formatValue(entry.value, schema?.type),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: MiaojiColors.textPrimary,
                                  height: 1.5,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  /// 打开沉浸式阅读页
  void _openReadMode(DataRecord record) {
    if (_notebook == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RecordDetailPage(
          record: record,
          schema: _notebook!.schema,
          accentColor: _item.iconColor,
        ),
      ),
    );
  }

  /// 编辑字段值 — 文本/数字弹出 BottomSheet，日期弹出日期选择器
  Future<void> _editFieldValue(
    DataRecord record,
    String fieldName,
    String fieldType,
    dynamic currentValue,
  ) async {
    if (record.id == null) return;

    if (fieldType == 'date') {
      await _editDateField(record, fieldName, currentValue);
    } else {
      await _editTextOrNumberField(record, fieldName, fieldType, currentValue);
    }
  }

  Future<void> _editDateField(
    DataRecord record,
    String fieldName,
    dynamic currentValue,
  ) async {
    final initial = currentValue is String && currentValue.isNotEmpty
        ? DateTime.tryParse(currentValue) ?? DateTime.now()
        : DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: _item.iconColor,
            onPrimary: Colors.white,
            surface: MiaojiColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: _item.iconColor,
            onPrimary: Colors.white,
            surface: MiaojiColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (!mounted) return;

    final dt = DateTime(
      date.year, date.month, date.day,
      time?.hour ?? 0, time?.minute ?? 0,
    );

    final newData = Map<String, dynamic>.from(record.data);
    newData[fieldName] = dt.toIso8601String();
    await DatabaseService().updateRecord(record.id!, newData);
    HapticFeedback.lightImpact();
    _loadData();
  }

  Future<void> _editTextOrNumberField(
    DataRecord record,
    String fieldName,
    String fieldType,
    dynamic currentValue,
  ) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _FieldEditSheet(
        fieldName: fieldName,
        fieldType: fieldType,
        initialValue: currentValue?.toString() ?? '',
        accentColor: _item.iconColor,
      ),
    );

    if (result == null || !mounted) return;

    final newData = Map<String, dynamic>.from(record.data);
    if (fieldType == 'number') {
      newData[fieldName] = num.tryParse(result) ?? result;
    } else {
      newData[fieldName] = result;
    }
    await DatabaseService().updateRecord(record.id!, newData);
    HapticFeedback.lightImpact();
    _loadData();
  }

  /// 提醒状态标签
  Widget _buildReminderBadge(DataRecord record) {
    final isPending = record.hasPendingReminder;
    final isOverdue = record.isReminderOverdue;
    final isSent = record.reminderSent;

    final Color bgColor;
    final Color textColor;
    final IconData icon;
    final String label;

    if (isSent) {
      bgColor = MiaojiColors.success.withValues(alpha: 0.1);
      textColor = MiaojiColors.success;
      icon = Icons.notifications_active_rounded;
      label = '已提醒';
    } else if (isOverdue) {
      bgColor = MiaojiColors.warning.withValues(alpha: 0.1);
      textColor = MiaojiColors.warning;
      icon = Icons.notification_important_rounded;
      label = '已过期';
    } else if (isPending) {
      bgColor = MiaojiColors.info.withValues(alpha: 0.1);
      textColor = MiaojiColors.info;
      icon = Icons.notifications_outlined;
      label = _formatReminderTime(record.reminderAt!);
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: textColor.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: textColor),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatReminderTime(DateTime time) {
    final now = DateTime.now();
    final diff = time.difference(now);

    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟后';
    if (diff.inHours < 24) return '${diff.inHours}小时后';
    if (diff.inDays < 7) return '${diff.inDays}天后';
    return '${time.month}/${time.day} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatValue(dynamic value, [String? fieldType]) {
    if (value == null) return '-';
    if (value is bool) return value ? '是' : '否';

    // 日期类型格式化为 YYYY-MM-DD HH:MM:SS
    if (fieldType == 'date' && value is String && value.isNotEmpty) {
      final dt = DateTime.tryParse(value);
      if (dt != null) {
        return '${dt.year}-'
            '${dt.month.toString().padLeft(2, '0')}-'
            '${dt.day.toString().padLeft(2, '0')} '
            '${dt.hour.toString().padLeft(2, '0')}:'
            '${dt.minute.toString().padLeft(2, '0')}:'
            '${dt.second.toString().padLeft(2, '0')}';
      }
    }

    return value.toString();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes} 分钟前';
    if (diff.inDays < 1) return '${diff.inHours} 小时前';
    if (diff.inDays < 7) return '${diff.inDays} 天前';

    return '${date.month}/${date.day} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // ── 入场动画 ──────────────────────────────────

  Widget _buildAnimated({
    required Interval interval,
    required Widget child,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.12),
        end: Offset.zero,
      ).animate(CurvedAnimation(
          parent: _enterController, curve: interval)),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _enterController,
          curve: Interval(
              interval.begin, (interval.end - 0.05).clamp(0, 1)),
        ),
        child: child,
      ),
    );
  }
}

/// 横线信纸背景绘制器
class _LinedPaperPainter extends CustomPainter {
  final Color lineColor;
  final double lineSpacing;
  final double topOffset;

  _LinedPaperPainter({
    required this.lineColor,
    required this.lineSpacing,
    required this.topOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    double y = topOffset;
    while (y < size.height) {
      canvas.drawLine(
        Offset(16, y),
        Offset(size.width - 16, y),
        paint,
      );
      y += lineSpacing;
    }

    // 左侧红色装订线
    final redLinePaint = Paint()
      ..color = MiaojiColors.accent.withValues(alpha: 0.15)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(12, topOffset - 4),
      Offset(12, size.height),
      redLinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ══════════════════════════════════════════════════
// 记录编辑底部弹窗
// ══════════════════════════════════════════════════

/// 单字段编辑 BottomSheet（文本/数字）
class _FieldEditSheet extends StatefulWidget {
  final String fieldName;
  final String fieldType;
  final String initialValue;
  final Color accentColor;

  const _FieldEditSheet({
    required this.fieldName,
    required this.fieldType,
    required this.initialValue,
    required this.accentColor,
  });

  @override
  State<_FieldEditSheet> createState() => _FieldEditSheetState();
}

class _FieldEditSheetState extends State<_FieldEditSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNumber = widget.fieldType == 'number';

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: const BoxDecoration(
          color: MiaojiColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖拽条
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: MiaojiColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // 标题栏
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                children: [
                  Text(
                    widget.fieldName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: MiaojiColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .pop(_controller.text.trim());
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5A4532), Color(0xFF8B6914)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '完成',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: MiaojiColors.borderLight),

            // 编辑区（可滚动）
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  keyboardType: isNumber
                      ? TextInputType.number
                      : TextInputType.multiline,
                  maxLines: null,
                  minLines: isNumber ? 1 : 3,
                  decoration: InputDecoration(
                    hintText:
                        isNumber ? '输入数字...' : '支持 Markdown 语法...',
                    hintStyle: TextStyle(
                      color: MiaojiColors.textHint.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    filled: true,
                    fillColor: MiaojiColors.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: MiaojiColors.borderLight,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: MiaojiColors.borderLight,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color:
                            widget.accentColor.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    color: MiaojiColors.textPrimary,
                    height: isNumber ? 1.4 : 1.7,
                    fontFamily: isNumber ? null : 'monospace',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  数据统计
// ══════════════════════════════════════════════════════════

/// 饼图色板
const _kPieColors = [
  Color(0xFF5B8DEF),
  Color(0xFFEF8B5B),
  Color(0xFF5BCC8A),
  Color(0xFFD4A24C),
  Color(0xFF8B6BAD),
  Color(0xFFE57373),
  Color(0xFF4DB6AC),
  Color(0xFF7986CB),
];

/// 单个字段的统计结果
class _FieldStats {
  final String fieldName;
  final int count;
  final double sum;
  final double avg;
  final double min;
  final double max;
  final List<(DateTime, double)> points;

  _FieldStats({
    required this.fieldName,
    required this.count,
    required this.sum,
    required this.avg,
    required this.min,
    required this.max,
    required this.points,
  });

  /// [timeField] 为 null 时使用 record.createdAt，否则使用 data[timeField] 的日期值
  factory _FieldStats.compute(String fieldName, List<DataRecord> records,
      {String? timeField}) {
    final points = <(DateTime, double)>[];
    for (final r in records) {
      final raw = r.data[fieldName];
      if (raw == null) continue;
      final v = raw is num ? raw.toDouble() : double.tryParse(raw.toString());
      if (v == null) continue;

      // 解析时间轴
      DateTime? t;
      if (timeField == null) {
        t = r.createdAt;
      } else {
        final tRaw = r.data[timeField];
        if (tRaw == null) continue;
        t = DateTime.tryParse(tRaw.toString());
        if (t == null) continue;
      }
      points.add((t, v));
    }
    points.sort((a, b) => a.$1.compareTo(b.$1));

    if (points.isEmpty) {
      return _FieldStats(
          fieldName: fieldName,
          count: 0, sum: 0, avg: 0, min: 0, max: 0, points: []);
    }

    final values = points.map((p) => p.$2).toList();
    final sum = values.fold<double>(0, (a, b) => a + b);
    return _FieldStats(
      fieldName: fieldName,
      count: values.length,
      sum: sum,
      avg: sum / values.length,
      min: values.reduce(math.min),
      max: values.reduce(math.max),
      points: points,
    );
  }
}

/// 饼图扇区数据
class _PieSlice {
  final String label;
  final double value;
  final double percentage;
  final Color color;

  const _PieSlice({
    required this.label,
    required this.value,
    required this.percentage,
    required this.color,
  });

  /// 按 [groupField] 对记录分组，对 [numberField] 求和
  static List<_PieSlice> compute({
    required String numberField,
    required String groupField,
    required List<DataRecord> records,
  }) {
    final groups = <String, double>{};
    for (final r in records) {
      final label = r.data[groupField]?.toString().trim() ?? '';
      if (label.isEmpty) continue;
      final raw = r.data[numberField];
      if (raw == null) continue;
      final v = raw is num ? raw.toDouble() : double.tryParse(raw.toString());
      if (v == null) continue;
      groups[label] = (groups[label] ?? 0) + v;
    }

    if (groups.isEmpty) return [];

    // 按值降序
    final sorted = groups.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = sorted.fold<double>(0, (a, b) => a + b.value);
    if (total == 0) return [];

    // 超过 6 个合并为"其他"
    final capped = <MapEntry<String, double>>[];
    double otherSum = 0;
    for (var i = 0; i < sorted.length; i++) {
      if (i < 6) {
        capped.add(sorted[i]);
      } else {
        otherSum += sorted[i].value;
      }
    }
    if (otherSum > 0) {
      capped.add(MapEntry('其他', otherSum));
    }

    return capped.asMap().entries.map((e) {
      final i = e.key;
      final entry = e.value;
      return _PieSlice(
        label: entry.key,
        value: entry.value,
        percentage: entry.value / total * 100,
        color: _kPieColors[i % _kPieColors.length],
      );
    }).toList();
  }
}

/// 统计面板 BottomSheet（StatefulWidget — 管理筛选状态）
class _StatsSheet extends StatefulWidget {
  final List<DataRecord> records;
  final List<SchemaField> schema;
  final Color accentColor;

  const _StatsSheet({
    required this.records,
    required this.schema,
    required this.accentColor,
  });

  @override
  State<_StatsSheet> createState() => _StatsSheetState();
}

class _StatsSheetState extends State<_StatsSheet> {
  /// 文本字段筛选：fieldName -> 选中值（null = 全部）
  final Map<String, String?> _textFilters = {};

  /// 日期范围筛选（null = 不限）
  DateTime? _dateStart;
  DateTime? _dateEnd;

  /// 每个 number 字段的饼图分组依据（fieldName -> groupByField）
  final Map<String, String> _pieGroupBy = {};

  /// 趋势图时间粒度：day / week / month（默认 day = 原始数据）
  String _trendGranularity = 'day';

  /// 趋势图横轴时间字段：null = createdAt，否则为 schema 中 date 字段名
  /// 默认优先使用 schema 中第一个 date 字段
  String? _trendTimeField;
  bool _trendTimeFieldInitialized = false;

  // ── 筛选后的记录 ────────────────────────

  List<DataRecord> get _filteredRecords {
    return widget.records.where((r) {
      // 文本字段筛选
      for (final entry in _textFilters.entries) {
        final filterVal = entry.value;
        if (filterVal == null) continue; // 全部
        final recordVal = r.data[entry.key]?.toString().trim() ?? '';
        if (recordVal != filterVal) return false;
      }
      // 日期范围筛选
      for (final field in widget.schema.where((f) => f.type == 'date')) {
        final raw = r.data[field.field];
        if (raw == null || raw.toString().isEmpty) continue;
        final dt = DateTime.tryParse(raw.toString());
        if (dt == null) continue;
        if (_dateStart != null && dt.isBefore(_dateStart!)) return false;
        if (_dateEnd != null && dt.isAfter(_dateEnd!.add(const Duration(days: 1)))) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  // ── 辅助 ────────────────────────────────

  List<SchemaField> get _textFields =>
      widget.schema.where((f) => f.type == 'string').toList();
  List<SchemaField> get _dateFields =>
      widget.schema.where((f) => f.type == 'date').toList();
  List<SchemaField> get _numberFields =>
      widget.schema.where((f) => f.type == 'number').toList();

  /// 获取某个文本字段在所有记录中的去重值
  List<String> _distinctValues(String fieldName) {
    final set = <String>{};
    for (final r in widget.records) {
      final v = r.data[fieldName]?.toString().trim() ?? '';
      if (v.isNotEmpty) set.add(v);
    }
    return set.toList()..sort();
  }

  bool get _hasActiveFilter =>
      _textFilters.values.any((v) => v != null) ||
      _dateStart != null ||
      _dateEnd != null;

  void _clearFilters() {
    setState(() {
      _textFilters.clear();
      _dateStart = null;
      _dateEnd = null;
    });
  }

  // ── build ───────────────────────────────

  @override
  Widget build(BuildContext context) {
    // 首次初始化横轴时间字段：优先使用 schema 中第一个 date 字段
    if (!_trendTimeFieldInitialized) {
      _trendTimeFieldInitialized = true;
      if (_dateFields.isNotEmpty) {
        _trendTimeField = _dateFields.first.field;
      }
      // 否则为 null → 使用 createdAt
    }

    final filtered = _filteredRecords;
    final statsList = _numberFields
        .map((f) =>
            _FieldStats.compute(f.field, filtered, timeField: _trendTimeField))
        .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (ctx, scrollController) => Container(
        decoration: const BoxDecoration(
          color: MiaojiColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // 拖拽条
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: MiaojiColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // 标题
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Row(
                children: [
                  Icon(Icons.bar_chart_rounded,
                      size: 20, color: widget.accentColor),
                  const SizedBox(width: 10),
                  const Text(
                    '数据统计',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: MiaojiColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${filtered.length} / ${widget.records.length} 条',
                    style: TextStyle(
                      fontSize: 12,
                      color: MiaojiColors.textHint,
                    ),
                  ),
                ],
              ),
            ),

            // 筛选栏
            if (_textFields.isNotEmpty || _dateFields.isNotEmpty)
              _buildFilterBar(),

            const Divider(height: 1, color: MiaojiColors.borderLight),

            // 统计内容
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                itemCount: statsList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 28),
                itemBuilder: (_, i) =>
                    _buildFieldStats(statsList[i], filtered),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 筛选栏 ──────────────────────────────

  Widget _buildFilterBar() {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
        children: [
          // 文本字段筛选 Chip
          ..._textFields.map((f) => _buildTextFilterChip(f)),

          // 日期范围 Chip
          ..._dateFields.map((f) => _buildDateFilterChip(f)),

          // 清除按钮
          if (_hasActiveFilter)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: ActionChip(
                label: Text(
                  '清除',
                  style: TextStyle(fontSize: 12, color: MiaojiColors.error),
                ),
                onPressed: _clearFilters,
                backgroundColor: MiaojiColors.error.withValues(alpha: 0.08),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
        ],
      ),
    );
  }

  static const _kAllValue = '\x00__all__';

  Widget _buildTextFilterChip(SchemaField field) {
    final selected = _textFilters[field.field];
    final options = _distinctValues(field.field);
    if (options.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: PopupMenuButton<String>(
        initialValue: selected ?? _kAllValue,
        onSelected: (v) => setState(() =>
            _textFilters[field.field] = v == _kAllValue ? null : v),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        position: PopupMenuPosition.under,
        itemBuilder: (_) => [
          PopupMenuItem(
            value: _kAllValue,
            child: Text('全部',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected == null ? FontWeight.w700 : null,
                )),
          ),
          ...options.map((v) => PopupMenuItem(
                value: v,
                child: Text(v,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected == v ? FontWeight.w700 : null,
                    )),
              )),
        ],
        child: Chip(
          label: Text(
            selected == null ? field.field : '${field.field}: $selected',
            style: TextStyle(
              fontSize: 12,
              color: selected != null
                  ? widget.accentColor
                  : MiaojiColors.textSecondary,
              fontWeight: selected != null ? FontWeight.w600 : null,
            ),
          ),
          backgroundColor: selected != null
              ? widget.accentColor.withValues(alpha: 0.1)
              : MiaojiColors.card,
          side: BorderSide(
            color: selected != null
                ? widget.accentColor.withValues(alpha: 0.3)
                : MiaojiColors.borderLight,
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          padding: EdgeInsets.zero,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }

  Widget _buildDateFilterChip(SchemaField field) {
    final hasRange = _dateStart != null || _dateEnd != null;
    String label;
    if (hasRange) {
      final s = _dateStart != null
          ? '${_dateStart!.month}/${_dateStart!.day}'
          : '...';
      final e = _dateEnd != null
          ? '${_dateEnd!.month}/${_dateEnd!.day}'
          : '...';
      label = '${field.field}: $s ~ $e';
    } else {
      label = field.field;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () async {
          final range = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            initialDateRange: _dateStart != null && _dateEnd != null
                ? DateTimeRange(start: _dateStart!, end: _dateEnd!)
                : null,
            builder: (ctx, child) => Theme(
              data: Theme.of(ctx).copyWith(
                colorScheme: ColorScheme.light(
                  primary: widget.accentColor,
                  onPrimary: Colors.white,
                  surface: MiaojiColors.surface,
                ),
              ),
              child: child!,
            ),
          );
          if (range != null) {
            setState(() {
              _dateStart = range.start;
              _dateEnd = range.end;
            });
          }
        },
        child: Chip(
          label: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: hasRange
                  ? widget.accentColor
                  : MiaojiColors.textSecondary,
              fontWeight: hasRange ? FontWeight.w600 : null,
            ),
          ),
          avatar: Icon(Icons.calendar_today_rounded,
              size: 13,
              color: hasRange
                  ? widget.accentColor
                  : MiaojiColors.textHint),
          backgroundColor: hasRange
              ? widget.accentColor.withValues(alpha: 0.1)
              : MiaojiColors.card,
          side: BorderSide(
            color: hasRange
                ? widget.accentColor.withValues(alpha: 0.3)
                : MiaojiColors.borderLight,
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          padding: EdgeInsets.zero,
          labelPadding: const EdgeInsets.only(left: -4, right: 10),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }

  // ── 字段统计区块 ────────────────────────

  Widget _buildFieldStats(_FieldStats stats, List<DataRecord> filtered) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 字段名
        Row(
          children: [
            const Icon(Icons.tag_rounded,
                size: 14, color: Color(0xFFD4A24C)),
            const SizedBox(width: 6),
            Text(
              stats.fieldName,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: MiaojiColors.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              '${stats.count} 个有效值',
              style: TextStyle(
                fontSize: 11,
                color: MiaojiColors.textHint,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (stats.count > 0) ...[
          // 4 个指标卡片
          Row(
            children: [
              Expanded(child: _metricCard(
                '总和', _formatNum(stats.sum), Icons.functions_rounded)),
              const SizedBox(width: 10),
              Expanded(child: _metricCard(
                '平均值', _formatNum(stats.avg), Icons.trending_flat_rounded)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _metricCard(
                '最大值', _formatNum(stats.max), Icons.arrow_upward_rounded,
                valueColor: const Color(0xFF4CAF50))),
              const SizedBox(width: 10),
              Expanded(child: _metricCard(
                '最小值', _formatNum(stats.min), Icons.arrow_downward_rounded,
                valueColor: const Color(0xFFE57373))),
            ],
          ),
          const SizedBox(height: 16),

          // 趋势图
          if (stats.points.length >= 2) ...[
            Row(
              children: [
                const Text('趋势',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                        color: MiaojiColors.textTertiary)),
                const Spacer(),
                ..._buildGranularityChips(),
              ],
            ),
            const SizedBox(height: 6),
            // 横轴时间字段切换
            _buildTimeAxisSelector(),
            const SizedBox(height: 8),
            Builder(builder: (_) {
              final aggregated = _aggregatePoints(stats.points);
              final aggValues = aggregated.map((p) => p.$2).toList();
              final aggMin = aggValues.reduce(math.min);
              final aggMax = aggValues.reduce(math.max);
              return Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: MiaojiColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: MiaojiColors.borderLight, width: 1),
                ),
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                child: aggregated.length >= 2
                    ? CustomPaint(
                        painter: _TrendLinePainter(
                          points: aggregated,
                          lineColor: widget.accentColor,
                          min: aggMin,
                          max: aggMax,
                        ),
                        size: Size.infinite,
                      )
                    : Center(
                        child: Text('该粒度下数据不足',
                            style: TextStyle(
                                fontSize: 12, color: MiaojiColors.textHint)),
                      ),
              );
            }),
          ] else
            _emptyBox('数据不足，至少需要 2 条记录才能生成趋势图'),

          // 饼图（如果有文本字段）
          if (_textFields.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildPieSection(stats.fieldName, filtered),
          ],
        ] else
          _emptyBox('暂无数据'),
      ],
    );
  }

  // ── 饼图区域 ────────────────────────────

  Widget _buildPieSection(String numberField, List<DataRecord> filtered) {
    final groupField = _pieGroupBy[numberField] ?? _textFields.first.field;
    final slices = _PieSlice.compute(
      numberField: numberField,
      groupField: groupField,
      records: filtered,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题 + 分组切换
        Row(
          children: [
            const Text('分布',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: MiaojiColors.textTertiary)),
            const Spacer(),
            if (_textFields.length > 1)
              ..._textFields.map((f) {
                final isActive = f.field == groupField;
                return Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: GestureDetector(
                    onTap: () => setState(
                        () => _pieGroupBy[numberField] = f.field),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isActive
                            ? widget.accentColor.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        f.field,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isActive ? FontWeight.w600 : null,
                          color: isActive
                              ? widget.accentColor
                              : MiaojiColors.textHint,
                        ),
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
        const SizedBox(height: 10),

        if (slices.isEmpty)
          _emptyBox('暂无分布数据')
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: MiaojiColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: MiaojiColors.borderLight, width: 1),
            ),
            child: Row(
              children: [
                // 饼图
                SizedBox(
                  width: 110,
                  height: 110,
                  child: CustomPaint(
                    painter: _PieChartPainter(slices: slices),
                    size: const Size(110, 110),
                  ),
                ),
                const SizedBox(width: 20),
                // 图例
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: slices.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: s.color,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              s.label,
                              style: const TextStyle(
                                fontSize: 12,
                                color: MiaojiColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${s.percentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: s.color,
                              fontFeatures: const [
                                FontFeature.tabularFigures()
                              ],
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ── 通用组件 ────────────────────────────

  Widget _emptyBox(String text) {
    return Container(
      height: 60,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: MiaojiColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MiaojiColors.borderLight, width: 1),
      ),
      child: Text(text,
          style: TextStyle(fontSize: 12, color: MiaojiColors.textHint)),
    );
  }

  Widget _metricCard(String label, String value, IconData icon,
      {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: MiaojiColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MiaojiColors.borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: MiaojiColors.textHint),
              const SizedBox(width: 5),
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: MiaojiColors.textHint)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: valueColor ?? MiaojiColors.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  String _formatNum(double v) {
    if (v == v.roundToDouble() && v.abs() < 1e15) {
      return v.toInt().toString();
    }
    final s = v.toStringAsFixed(2);
    if (s.contains('.')) {
      return s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    }
    return s;
  }

  // ── 趋势图粒度切换 ──────────────────────

  static const _granularityOptions = [
    ('day', '日'),
    ('week', '周'),
    ('month', '月'),
  ];

  List<Widget> _buildGranularityChips() {
    return _granularityOptions.map((opt) {
      final selected = _trendGranularity == opt.$1;
      return Padding(
        padding: const EdgeInsets.only(left: 6),
        child: GestureDetector(
          onTap: () => setState(() => _trendGranularity = opt.$1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: selected
                  ? widget.accentColor.withValues(alpha: 0.15)
                  : MiaojiColors.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected
                    ? widget.accentColor.withValues(alpha: 0.5)
                    : MiaojiColors.borderLight,
                width: 1,
              ),
            ),
            child: Text(
              opt.$2,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? widget.accentColor : MiaojiColors.textHint,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  // ── 横轴时间字段切换 ────────────────────

  /// 构建横轴时间选择器：所有 schema date 字段 + 创建时间
  Widget _buildTimeAxisSelector() {
    // 可选项：schema 中的 date 字段 + createdAt
    final options = <(String?, String)>[
      ...(_dateFields.map((f) => (f.field as String?, f.field))),
      (null, '创建时间'),
    ];

    // 只有一个选项时不需要显示切换
    if (options.length <= 1) return const SizedBox.shrink();

    return SizedBox(
      height: 28,
      child: Row(
        children: [
          Icon(Icons.access_time_rounded,
              size: 12, color: MiaojiColors.textHint),
          const SizedBox(width: 4),
          Text('横轴',
              style: TextStyle(
                  fontSize: 11,
                  color: MiaojiColors.textHint,
                  fontWeight: FontWeight.w500)),
          const SizedBox(width: 6),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: options.map((opt) {
                  final selected = _trendTimeField == opt.$1;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () => setState(() => _trendTimeField = opt.$1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: selected
                              ? widget.accentColor.withValues(alpha: 0.12)
                              : MiaojiColors.card,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected
                                ? widget.accentColor.withValues(alpha: 0.4)
                                : MiaojiColors.borderLight,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          opt.$2,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                            color: selected
                                ? widget.accentColor
                                : MiaojiColors.textHint,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 按粒度聚合数据点：同一「桶」内求平均
  List<(DateTime, double)> _aggregatePoints(List<(DateTime, double)> raw) {
    if (_trendGranularity == 'day') return raw;

    final buckets = <String, List<(DateTime, double)>>{};

    for (final p in raw) {
      String key;
      if (_trendGranularity == 'week') {
        // ISO 周一为一周开始
        final monday = p.$1.subtract(Duration(days: p.$1.weekday - 1));
        key = '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
      } else {
        // month
        key = '${p.$1.year}-${p.$1.month.toString().padLeft(2, '0')}';
      }
      buckets.putIfAbsent(key, () => []).add(p);
    }

    final result = <(DateTime, double)>[];
    final sortedKeys = buckets.keys.toList()..sort();
    for (final key in sortedKeys) {
      final items = buckets[key]!;
      final avgVal = items.map((e) => e.$2).reduce((a, b) => a + b) / items.length;
      // 用桶内中间时间作为代表点
      final midTime = items[items.length ~/ 2].$1;
      result.add((midTime, avgVal));
    }

    return result;
  }
}

// ── 饼图绘制器 (Donut) ───────────────────

class _PieChartPainter extends CustomPainter {
  final List<_PieSlice> slices;

  _PieChartPainter({required this.slices});

  @override
  void paint(Canvas canvas, Size size) {
    if (slices.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final strokeWidth = radius * 0.38;
    final donutRadius = radius - strokeWidth / 2;

    double startAngle = -math.pi / 2; // 从 12 点钟方向开始

    for (final slice in slices) {
      final sweepAngle = slice.percentage / 100 * 2 * math.pi;
      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: donutRadius),
        startAngle,
        sweepAngle - 0.02, // 小间隙
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) =>
      oldDelegate.slices != slices;
}

// ── 折线趋势图绘制器 ────────────────────

class _TrendLinePainter extends CustomPainter {
  final List<(DateTime, double)> points;
  final Color lineColor;
  final double min;
  final double max;

  _TrendLinePainter({
    required this.points,
    required this.lineColor,
    required this.min,
    required this.max,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final w = size.width;
    final h = size.height;

    final valueRange = max - min;
    final yMin = valueRange == 0 ? min - 1 : min - valueRange * 0.1;
    final yMax = valueRange == 0 ? max + 1 : max + valueRange * 0.1;
    final yRange = yMax - yMin;

    final tMin = points.first.$1.millisecondsSinceEpoch.toDouble();
    final tMax = points.last.$1.millisecondsSinceEpoch.toDouble();
    final tRange = tMax - tMin;

    Offset toCanvas(int i) {
      final t = points[i].$1.millisecondsSinceEpoch.toDouble();
      final v = points[i].$2;
      final x = tRange == 0 ? w / 2 : (t - tMin) / tRange * w;
      final y = yRange == 0 ? h / 2 : h - ((v - yMin) / yRange * h);
      return Offset(x, y);
    }

    // 将各点转为 canvas 坐标
    final pts = List.generate(points.length, toCanvas);

    // 使用 Catmull-Rom → 三次贝塞尔 实现平滑曲线
    final linePath = Path();
    final fillPath = Path();
    linePath.moveTo(pts[0].dx, pts[0].dy);
    fillPath.moveTo(pts[0].dx, h);
    fillPath.lineTo(pts[0].dx, pts[0].dy);

    const tension = 0.3; // 越小越平滑

    for (var i = 0; i < pts.length - 1; i++) {
      final p0 = i > 0 ? pts[i - 1] : pts[i];
      final p1 = pts[i];
      final p2 = pts[i + 1];
      final p3 = i + 2 < pts.length ? pts[i + 2] : pts[i + 1];

      final cp1x = p1.dx + (p2.dx - p0.dx) * tension;
      final cp1y = p1.dy + (p2.dy - p0.dy) * tension;
      final cp2x = p2.dx - (p3.dx - p1.dx) * tension;
      final cp2y = p2.dy - (p3.dy - p1.dy) * tension;

      linePath.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
      fillPath.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
    }

    final last = pts.last;
    fillPath.lineTo(last.dx, h);
    fillPath.close();

    // 渐变填充
    final fillPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        Offset(0, h),
        [lineColor.withValues(alpha: 0.18), lineColor.withValues(alpha: 0.01)],
      );
    canvas.drawPath(fillPath, fillPaint);

    // 平滑曲线
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, linePaint);

    // 数据点
    final dotPaint = Paint()..color = lineColor;
    final dotBgPaint = Paint()..color = Colors.white;
    for (final pt in pts) {
      canvas.drawCircle(pt, 3.5, dotBgPaint);
      canvas.drawCircle(pt, 2.2, dotPaint);
    }

    // 左侧 Y 轴标签
    final labelStyle = ui.TextStyle(color: MiaojiColors.textHint, fontSize: 9);

    final maxBuilder = ui.ParagraphBuilder(ui.ParagraphStyle())
      ..pushStyle(labelStyle)
      ..addText(_shortNum(max));
    final maxPara = maxBuilder.build()
      ..layout(const ui.ParagraphConstraints(width: 60));
    canvas.drawParagraph(maxPara, const Offset(2, 0));

    final minBuilder = ui.ParagraphBuilder(ui.ParagraphStyle())
      ..pushStyle(labelStyle)
      ..addText(_shortNum(min));
    final minPara = minBuilder.build()
      ..layout(const ui.ParagraphConstraints(width: 60));
    canvas.drawParagraph(minPara, Offset(2, h - 12));

    // 底部时间标签（首尾）
    final timeLabelStyle = ui.TextStyle(color: MiaojiColors.textHint, fontSize: 8);
    final firstDate = points.first.$1;
    final lastDate = points.last.$1;

    String fmtDate(DateTime d) =>
        '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';

    final firstLabelBuilder = ui.ParagraphBuilder(ui.ParagraphStyle())
      ..pushStyle(timeLabelStyle)
      ..addText(fmtDate(firstDate));
    final firstLabelPara = firstLabelBuilder.build()
      ..layout(const ui.ParagraphConstraints(width: 40));
    canvas.drawParagraph(firstLabelPara, Offset(0, h - 1));

    final lastLabelBuilder = ui.ParagraphBuilder(
        ui.ParagraphStyle(textAlign: TextAlign.right))
      ..pushStyle(timeLabelStyle)
      ..addText(fmtDate(lastDate));
    final lastLabelPara = lastLabelBuilder.build()
      ..layout(const ui.ParagraphConstraints(width: 40));
    canvas.drawParagraph(lastLabelPara, Offset(w - 40, h - 1));
  }

  String _shortNum(double v) {
    if (v == v.roundToDouble() && v.abs() < 1e6) return v.toInt().toString();
    if (v.abs() >= 1e6) return '${(v / 1e6).toStringAsFixed(1)}M';
    return v.toStringAsFixed(1);
  }

  @override
  bool shouldRepaint(covariant _TrendLinePainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.lineColor != lineColor;
}
