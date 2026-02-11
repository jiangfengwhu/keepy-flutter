import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_markdown_plus_latex/flutter_markdown_plus_latex.dart';
import 'package:markdown/markdown.dart' as md;
import '../l10n/l10n_ext.dart';
import '../models/data_record.dart';
import '../models/notebook_item.dart';
import '../services/checkin_service.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../services/summary_service.dart';
import '../theme/miaoji_theme.dart';
import '../widgets/app_toast.dart';
import '../widgets/notebook_grid_tile.dart';
import 'all_notebooks_page.dart';
import 'notebook_detail_page.dart';
import 'search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _enterController;
  late AnimationController _checkinLikeController;
  final DatabaseService _dbService = DatabaseService();
  final SummaryService _summaryService = SummaryService();
  final CheckinService _checkinService = CheckinService();

  List<NotebookItem> _notebooks = [];
  List<DataRecord> _upcomingReminders = [];
  bool _isLoading = true;
  bool _checkedInToday = false;
  bool _checkinSubmitting = false;
  bool _checkinSuccessAnimating = false;

  /// 每日一语内容
  String? _summaryText;
  bool _summaryLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _checkinLikeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );
    _loadData();
    _loadCheckinStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _enterController.dispose();
    _checkinLikeController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // app 从后台回到前台时，先标记所有已到期提醒为已发送
      NotificationService().checkAndMarkOverdueReminders();
      _loadData();
      _loadCheckinStatus();
    }
  }

  Future<void> _loadData() async {
    try {
      final notebooks = await _dbService.getAllNotebooks();
      final reminders = await _dbService.getUpcomingReminders();
      final counts = await _dbService.getRecordCountsAll();
      if (!mounted) return;
      final l10n = context.l10n;
      setState(() {
        _notebooks = notebooks.map((nb) {
          final item = NotebookItem.fromNotebook(nb, l10n: l10n);
          return item.withRecordCount(counts[nb.name] ?? 0);
        }).toList();
        _upcomingReminders = reminders;
        _isLoading = false;
      });
      if (!_enterController.isCompleted) {
        _enterController.forward();
      }
      // 异步加载每日一语（不阻塞主界面）
      _loadSummary();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _enterController.forward();
    }
  }

  Future<void> _loadSummary() async {
    if (_notebooks.isEmpty) return;
    if (_summaryLoading) return; // 防止重复调用
    setState(() => _summaryLoading = true);
    try {
      final text = await _summaryService.getSummary(
        onStreaming: (partial) {
          if (mounted) setState(() => _summaryText = partial);
        },
      );
      if (!mounted) return;
      setState(() {
        _summaryText = text;
        _summaryLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _summaryLoading = false);
    }
  }

  Future<void> _loadCheckinStatus() async {
    final checkedIn = await _checkinService.hasCheckedInToday();
    if (!mounted) return;
    setState(() => _checkedInToday = checkedIn);
  }

  Future<void> _onCheckinTap() async {
    if (_checkedInToday || _checkinSubmitting) return;
    setState(() => _checkinSubmitting = true);
    final result = await _checkinService.checkIn();
    if (!mounted) return;
    final l10n = context.l10n;
    final toastMessage =
        result.message ??
        (result.errorType == CheckinErrorType.ticketUnavailable
            ? l10n.ticketInitializing
            : (result.success
                  ? l10n.checkinSuccessFallback
                  : l10n.checkinFailedFallback));
    setState(() {
      _checkinSubmitting = false;
      if (result.success) {
        _checkedInToday = true;
        _checkinSuccessAnimating = true;
      }
    });
    AppToast.show(toastMessage);
    if (result.success) {
      _checkinLikeController.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        setState(() => _checkinSuccessAnimating = false);
      });
    }
  }

  /// 外部调用刷新笔记本列表
  void refreshNotebooks() {
    _loadData();
  }

  void _openAllNotebooks() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => AllNotebooksPage(notebooks: _notebooks),
          ),
        )
        .then((_) => _loadData());
  }

  void _openNotebook(NotebookItem item) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => NotebookDetailPage(notebookItem: item),
          ),
        )
        .then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MiaojiColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── 吸顶 Header ──
          SliverAppBar(
            pinned: true,
            floating: false,
            expandedHeight: 0,
            toolbarHeight: 60,
            backgroundColor: MiaojiColors.background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0.5,
            title: _buildAnimated(
              interval: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
              fadeInterval: const Interval(0.0, 0.4),
              child: Row(
                children: [
                  Text(
                    context.l10n.homeTitle,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: MiaojiColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              _buildAnimated(
                interval: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
                fadeInterval: const Interval(0.0, 0.4),
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _IconButton(
                    icon: Icons.search_rounded,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SearchPage()),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),

          // ── 提示卡片区域 ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: _buildAnimated(
                interval: const Interval(0.1, 0.6, curve: Curves.easeOutCubic),
                fadeInterval: const Interval(0.1, 0.5),
                child: _buildInsightCards(),
              ),
            ),
          ),

          // ── "妙记本" 标题 ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: _buildAnimated(
                interval: const Interval(0.25, 0.7, curve: Curves.easeOutCubic),
                fadeInterval: const Interval(0.25, 0.6),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildMiniSectionTitle(
                        Icons.menu_book_rounded,
                        context.l10n.notebookSection,
                      ),
                    ),
                    GestureDetector(
                      onTap: _notebooks.length > 6
                          ? () => _openAllNotebooks()
                          : null,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            context.l10n.notebookCount(_notebooks.length),
                            style: TextStyle(
                              color: _notebooks.length > 6
                                  ? MiaojiColors.primary
                                  : MiaojiColors.textHint,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (_notebooks.length > 6) ...[
                            const SizedBox(width: 2),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 18,
                              color: MiaojiColors.primary,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── 笔记本列表 / 空状态 / 加载中 ──
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: MiaojiColors.primary,
                ),
              ),
            )
          else if (_notebooks.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyNotebooks(),
            )
          else ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.95,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final delay = 0.35 + index * 0.08;
                  final end = (delay + 0.4).clamp(0.0, 1.0);
                  return _buildAnimated(
                    interval: Interval(delay, end, curve: Curves.easeOutCubic),
                    fadeInterval: Interval(delay, end - 0.05),
                    child: NotebookGridTile(
                      item: _notebooks[index],
                      onTap: () => _openNotebook(_notebooks[index]),
                    ),
                  );
                }, childCount: _notebooks.length > 6 ? 6 : _notebooks.length),
              ),
            ),
            // "查看全部" 按钮（超过 6 个时显示）
            if (_notebooks.length > 6)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  child: GestureDetector(
                    onTap: _openAllNotebooks,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: MiaojiColors.card,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: MiaojiShadows.sm,
                        border: Border.all(
                          color: MiaojiColors.borderLight,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            context.l10n.viewAllNotebooks(_notebooks.length),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: MiaojiColors.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: MiaojiColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  //  提示卡片区域
  // ══════════════════════════════════════════

  Widget _buildInsightCards() {
    final hasReminders = _upcomingReminders.isNotEmpty;
    final hasNotebooks = _notebooks.isNotEmpty;
    final showReminderSection = true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1) 每日一语 — 放最上面
        if (hasNotebooks) ...[
          _buildMiniSectionTitle(
            Icons.auto_awesome,
            context.l10n.aiWeeklyTitle,
          ),
          const SizedBox(height: 10),
          _buildAiSuggestionCard(),
        ],

        // 2) 没有任何数据时：功能引导（欢迎使用妙记）
        if (!hasNotebooks && !hasReminders) _buildFeatureGuideCard(),

        // 3) 近期提醒 — 放在欢迎使用妙记下面
        if (showReminderSection) ...[
          SizedBox(height: hasNotebooks || (!hasNotebooks && !hasReminders) ? 20 : 0),
          _buildMiniSectionTitle(
            Icons.notifications_active_rounded,
            context.l10n.upcomingRemindersTitle,
          ),
          const SizedBox(height: 10),
          _buildReminderCard(),
        ],
      ],
    );
  }

  /// 小标题（类似"我的小本"风格）
  Widget _buildMiniSectionTitle(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
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
          Icon(icon, size: 16, color: MiaojiColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: MiaojiColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  // ── 待办提醒卡片 ──

  Widget _buildReminderCard() {
    final previewReminders = _upcomingReminders.take(3).toList();
    const showCheckinItem = true;
    final contentTopSpacing = showCheckinItem
        ? 12.0
        : (previewReminders.isNotEmpty ? 8.0 : 0.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF3DE), Color(0xFFFFF8EB), Color(0xFFFFFCF4)],
          stops: [0.0, 0.5, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(MiaojiRadius.lg),
        border: Border.all(color: const Color(0xFFE8D7BC), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x20C8A36D),
            blurRadius: 20,
            offset: Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF6E8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    size: 17,
                    color: Color(0xFFD97706),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  context.l10n.upcomingRemindersTitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: MiaojiColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFF2D7A6),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    context.l10n.reminderCount(_upcomingReminders.length),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFD97706),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (contentTopSpacing > 0) SizedBox(height: contentTopSpacing),
          // 签到与提醒统一列表
          if (showCheckinItem)
            Padding(
              padding: EdgeInsets.only(
                bottom: previewReminders.isNotEmpty ? 8 : 0,
              ),
              child: _buildCheckinItem(),
            ),
          ...List.generate(
            previewReminders.length,
            (index) => Padding(
              padding: EdgeInsets.only(
                bottom: index == previewReminders.length - 1 ? 0 : 8,
              ),
              child: _buildReminderItem(previewReminders[index]),
            ),
          ),
          if (_upcomingReminders.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                context.l10n.moreReminders(_upcomingReminders.length - 3),
                style: const TextStyle(
                  fontSize: 12,
                  color: MiaojiColors.textHint,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReminderItem(DataRecord record) {
    final reminderAt = record.reminderAt!;
    final now = DateTime.now();
    final diff = reminderAt.difference(now);
    String timeText;
    if (diff.inDays > 0) {
      timeText = context.l10n.reminderInDays(diff.inDays);
    } else if (diff.inHours > 0) {
      timeText = context.l10n.reminderInHours(diff.inHours);
    } else if (diff.inMinutes > 0) {
      timeText = context.l10n.reminderInMinutes(diff.inMinutes);
    } else {
      timeText = context.l10n.reminderSoon;
    }

    // 从 data 中取第一个文本值作为摘要
    final summary = record.data.values
        .where((v) => v is String && v.trim().isNotEmpty)
        .map((v) => v.toString())
        .firstOrNull;
    final displayText = summary ?? record.notebookName;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7EA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0DFC5), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: diff.inHours < 24
                    ? const Color(0xFFEF4444)
                    : const Color(0xFFD4A24C),
                width: 1.5,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              displayText,
              style: const TextStyle(
                fontSize: 13,
                color: MiaojiColors.textSecondary,
                height: 1.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: diff.inHours < 24
                  ? const Color(0xFFFFF1F2)
                  : const Color(0xFFF4F1EA),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              timeText,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: diff.inHours < 24
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF9A7B44),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckinItem() {
    final isDone = _checkedInToday;
    final showLikeBurst = _checkinSuccessAnimating;
    final circleColor = isDone
        ? const Color(0xFF22C55E)
        : const Color(0xFFD4A24C);
    return InkWell(
      onTap: isDone ? null : _onCheckinTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7EA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF0DFC5), width: 1),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 13,
              height: 13,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (showLikeBurst)
                    AnimatedBuilder(
                      animation: _checkinLikeController,
                      builder: (context, child) {
                        final progress = Curves.easeOutCubic.transform(
                          _checkinLikeController.value,
                        );
                        return _CheckinLikeBurst(progress: progress);
                      },
                    ),
                  AnimatedBuilder(
                    animation: _checkinLikeController,
                    builder: (context, child) {
                      final raw = _checkinLikeController.value;
                      final bounce = showLikeBurst
                          ? (raw < 0.45
                                ? 0.7 + (raw / 0.45) * 0.55
                                : 1.25 - ((raw - 0.45) / 0.55) * 0.25)
                          : 1.0;
                      if (isDone) {
                        return Transform.scale(
                          scale: bounce.clamp(0.8, 1.3),
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 11,
                              color: Colors.white,
                            ),
                          ),
                        );
                      }
                      return Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: circleColor,
                            width: 1.5,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.l10n.checkinTitle,
                style: TextStyle(
                  fontSize: 13,
                  color: isDone
                      ? MiaojiColors.textTertiary
                      : MiaojiColors.textSecondary,
                  height: 1.3,
                  // decoration: isDone ? TextDecoration.lineThrough : null,
                  decorationColor: MiaojiColors.textTertiary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (_checkinSubmitting)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 1.8,
                  color: Color(0xFFD4A24C),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: isDone
                      ? const Color(0xFFECFDF5)
                      : const Color.fromARGB(255, 229, 192, 192),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isDone
                      ? context.l10n.checkinDone
                      : context.l10n.checkinAction,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isDone
                        ? const Color(0xFF22C55E)
                        : const Color.fromARGB(255, 131, 77, 105),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── 每日一语卡片 ──

  Widget _buildAiSuggestionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFF8E8),
            Color(0xFFFFF1D4),
            Color(0xFFFDEBC2),
          ],
          stops: [0.0, 0.55, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(MiaojiRadius.lg),
        border: Border.all(
          color: const Color(0xFFE8D09A),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4A24C).withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFFD4A24C).withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFBF8A2E), Color(0xFFD4A24C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      size: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      context.l10n.aiWeeklyCardLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                context.l10n.aiWeeklyBasedOnDays(1),
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFFC0A06A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // 内容区域
          if (_summaryLoading && _summaryText == null)
            // 首次加载中
            Row(
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: const Color(0xFFD4A24C).withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  context.l10n.aiWeeklyGenerating,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9A8460),
                  ),
                ),
              ],
            )
          else if (_summaryText != null && _summaryText!.isNotEmpty)
            // Markdown 渲染每日一语内容
            MarkdownBody(
              data: _summaryText!,
              softLineBreak: true,
              builders: {
                'latex': LatexElementBuilder(
                  textStyle: const TextStyle(color: Color(0xFF4A3B26)),
                ),
              },
              extensionSet: md.ExtensionSet(
                [LatexBlockSyntax()],
                [LatexInlineSyntax()],
              ),
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4A3B26),
                  height: 1.5,
                ),
                h1: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3D3020),
                ),
                h2: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3D3020),
                ),
                h3: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3D3020),
                ),
                strong: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFB8860B),
                ),
                listBullet: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B5A3E),
                ),
                blockSpacing: 8,
              ),
              shrinkWrap: true,
            )
          else
            // 无内容或请求失败
            Text(
              context.l10n.aiWeeklyEmpty,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFFB0996E),
              ),
            ),
          // 流式加载中提示
          if (_summaryLoading && _summaryText != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 10,
                    height: 10,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.2,
                      color: const Color(0xFFD4A24C).withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    context.l10n.aiWeeklyStreaming,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFFC0A06A),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── 功能引导卡片（无数据时） ──

  Widget _buildFeatureGuideCard() {
    final features = [
      _FeatureItem(
        icon: Icons.auto_awesome,
        iconColor: const Color(0xFFD4A24C),
        title: context.l10n.featureAiCreateTitle,
        desc: context.l10n.featureAiCreateDesc,
      ),
      _FeatureItem(
        icon: Icons.notifications_active_rounded,
        iconColor: const Color(0xFFEF4444),
        title: context.l10n.featureReminderTitle,
        desc: context.l10n.featureReminderDesc,
      ),
      _FeatureItem(
        icon: Icons.bar_chart_rounded,
        iconColor: const Color(0xFF3B82F6),
        title: context.l10n.featureAnalyticsTitle,
        desc: context.l10n.featureAnalyticsDesc,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MiaojiColors.card,
        borderRadius: BorderRadius.circular(MiaojiRadius.lg),
        border: Border.all(color: MiaojiColors.borderLight, width: 1),
        boxShadow: MiaojiShadows.paper,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.waving_hand_rounded,
                size: 20,
                color: Color(0xFFD4A24C),
              ),
              SizedBox(width: 8),
              Text(
                context.l10n.featureGuideTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: MiaojiColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.featureGuideSubtitle,
            style: const TextStyle(
              fontSize: 13,
              color: MiaojiColors.textTertiary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: MiaojiColors.borderLight),
          const SizedBox(height: 14),
          ...features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: f.iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(f.icon, size: 18, color: f.iconColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          f.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: MiaojiColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          f.desc,
                          style: const TextStyle(
                            fontSize: 12,
                            color: MiaojiColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  //  空状态
  // ══════════════════════════════════════════

  Widget _buildEmptyNotebooks() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: MiaojiColors.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: MiaojiColors.borderLight, width: 1.5),
              boxShadow: MiaojiShadows.paper,
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              size: 36,
              color: MiaojiColors.textHint,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            context.l10n.emptyNotebooksTitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: MiaojiColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.emptyNotebooksHint,
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

  // ══════════════════════════════════════════
  //  入场动画
  // ══════════════════════════════════════════

  Widget _buildAnimated({
    required Interval interval,
    required Interval fadeInterval,
    required Widget child,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.15),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _enterController, curve: interval)),
      child: FadeTransition(
        opacity: CurvedAnimation(parent: _enterController, curve: fadeInterval),
        child: child,
      ),
    );
  }

  // ══════════════════════════════════════════
  //  "我的小本" 标题
  // ══════════════════════════════════════════
}

/// 顶部栏图标按钮 — 纸质风格
class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: MiaojiColors.card,
          borderRadius: BorderRadius.circular(13),
          boxShadow: MiaojiShadows.sm,
          border: Border.all(color: MiaojiColors.borderLight, width: 1),
        ),
        child: Icon(icon, color: MiaojiColors.textSecondary, size: 20),
      ),
    );
  }
}

// ── 内部数据模型 ──

class _FeatureItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String desc;

  const _FeatureItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.desc,
  });
}

class _CheckinLikeBurst extends StatelessWidget {
  final double progress;

  const _CheckinLikeBurst({required this.progress});

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    final radius = 2 + clamped * 11;
    final dotOpacity = (1 - clamped).clamp(0.0, 1.0);
    final ringOpacity = (0.38 * (1 - clamped)).clamp(0.0, 0.38);
    final dotColor = const Color(0xFFF91880).withValues(alpha: dotOpacity);
    final ringColor = const Color(0xFFF91880).withValues(alpha: ringOpacity);

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 12 + clamped * 14,
          height: 12 + clamped * 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ringColor, width: 1.2),
          ),
        ),
        ...List.generate(8, (i) {
          final angle = (math.pi * 2 / 8) * i - math.pi / 2;
          final dx = math.cos(angle) * radius;
          final dy = math.sin(angle) * radius;
          return Transform.translate(
            offset: Offset(dx, dy),
            child: Container(
              width: i.isEven ? 3.2 : 2.4,
              height: i.isEven ? 3.2 : 2.4,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
          );
        }),
      ],
    );
  }
}
