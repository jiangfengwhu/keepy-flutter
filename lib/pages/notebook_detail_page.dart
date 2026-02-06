import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/data_record.dart';
import '../models/notebook.dart';
import '../models/notebook_item.dart';
import '../services/database_service.dart';
import '../theme/miaoji_theme.dart';

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

  NotebookItem get item => widget.notebookItem;

  @override
  void initState() {
    super.initState();
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
      if (item.dbId != null) {
        notebook = await _db.getNotebook(item.dbId!);
      }
      notebook ??= await _db.getNotebookByName(item.title);

      final records = await _db.getRecords(notebookName: item.title);

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

                // Schema 字段
                if (_notebook != null && _notebook!.schema.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: _buildAnimated(
                        interval: const Interval(0.1, 0.55,
                            curve: Curves.easeOutCubic),
                        child: _buildSchemaSection(),
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
            item.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: MiaojiColors.textPrimary,
              letterSpacing: -0.3,
            ),
            overflow: TextOverflow.ellipsis,
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
                  color: item.iconBg.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: item.iconColor.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child:
                    Icon(item.icon, color: item.iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
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
                          item.iconColor,
                        ),
                        const SizedBox(width: 10),
                        _buildStatChip(
                          Icons.layers_outlined,
                          '$recordCount 条记录',
                          item.iconColor,
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
              color: item.iconColor.withValues(alpha: 0.4),
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

  // ── Schema 区域（纸面字段标签） ──────────────────────

  Widget _buildSchemaSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MiaojiColors.card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: MiaojiShadows.sm,
        border: Border.all(color: MiaojiColors.borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: MiaojiColors.primary,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '数据结构',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: MiaojiColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _notebook!.schema.map((field) {
              final (iconData, color) = _fieldTypeStyle(field.type);
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: color.withValues(alpha: 0.12),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(iconData, size: 13, color: color),
                    const SizedBox(width: 5),
                    Text(
                      field.field,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      field.typeDisplay,
                      style: TextStyle(
                        fontSize: 10,
                        color: color.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
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
      'boolean' =>
        (Icons.check_circle_outline_rounded, const Color(0xFF5B8C5A)),
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
            '试试和 AI 助手说「帮我记一笔 ${item.title}」',
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
                            item.iconColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '#${record.id}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: item.iconColor,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
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
                    final (iconData, color) =
                        _fieldTypeStyle(schema?.type ?? 'string');

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
                          // 字段值（手写在纸上的感觉）
                          Expanded(
                            child: Text(
                              _formatValue(entry.value),
                              style: const TextStyle(
                                fontSize: 14,
                                color: MiaojiColors.textPrimary,
                                height: 1.5,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
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
    );
  }

  String _formatValue(dynamic value) {
    if (value == null) return '-';
    if (value is bool) return value ? '是' : '否';
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
