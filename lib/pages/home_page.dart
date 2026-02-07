import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/data_record.dart';
import '../models/notebook_item.dart';
import '../services/database_service.dart';
import '../services/summary_service.dart';
import '../theme/miaoji_theme.dart';
import '../widgets/notebook_tile.dart';
import 'all_notebooks_page.dart';
import 'notebook_detail_page.dart';
import 'search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _enterController;
  final DatabaseService _dbService = DatabaseService();
  final SummaryService _summaryService = SummaryService();

  List<NotebookItem> _notebooks = [];
  List<DataRecord> _upcomingReminders = [];
  bool _isLoading = true;

  /// AI 周报内容
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
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _enterController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    try {
      final notebooks = await _dbService.getAllNotebooks();
      final reminders = await _dbService.getUpcomingReminders();
      final counts = await _dbService.getRecordCountsAll();
      if (!mounted) return;
      setState(() {
        _notebooks = notebooks.map((nb) {
          final item = NotebookItem.fromNotebook(nb);
          return item.withRecordCount(counts[nb.name] ?? 0);
        }).toList();
        _upcomingReminders = reminders;
        _isLoading = false;
      });
      if (!_enterController.isCompleted) {
        _enterController.forward();
      }
      // 异步加载 AI 周报（不阻塞主界面）
      _loadSummary();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _enterController.forward();
    }
  }

  Future<void> _loadSummary() async {
    if (_notebooks.isEmpty) return;
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
              interval:
                  const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
              fadeInterval: const Interval(0.0, 0.4),
              child: Row(
                children: [
                  Text(
                    '妙记兜',
                    style:
                        Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                              color: MiaojiColors.textPrimary,
                            ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: MiaojiColors.primary.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              _buildAnimated(
                interval:
                    const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
                fadeInterval: const Interval(0.0, 0.4),
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _IconButton(
                    icon: Icons.search_rounded,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const SearchPage()),
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
                interval:
                    const Interval(0.1, 0.6, curve: Curves.easeOutCubic),
                fadeInterval: const Interval(0.1, 0.5),
                child: _buildInsightCards(),
              ),
            ),
          ),

          // ── "妙计本" 标题 ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 24, 0),
              child: _buildAnimated(
                interval:
                    const Interval(0.25, 0.7, curve: Curves.easeOutCubic),
                fadeInterval: const Interval(0.25, 0.6),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildMiniSectionTitle(
                          Icons.menu_book_rounded, '妙计本'),
                    ),
                    GestureDetector(
                      onTap: _notebooks.length > 6
                          ? () => _openAllNotebooks()
                          : null,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${_notebooks.length} 个',
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
                            Icon(Icons.chevron_right_rounded,
                                size: 18, color: MiaojiColors.primary),
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
              child: _buildEmptyNotebooks(),
            )
          else ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final delay = 0.35 + index * 0.08;
                    final end = (delay + 0.4).clamp(0.0, 1.0);
                    final displayCount = _notebooks.length > 6
                        ? 6
                        : _notebooks.length;
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index < displayCount - 1 ? 14 : 0,
                      ),
                      child: _buildAnimated(
                        interval: Interval(delay, end,
                            curve: Curves.easeOutCubic),
                        fadeInterval: Interval(delay, end - 0.05),
                        child: NotebookTile(
                          item: _notebooks[index],
                          onTap: () => _openNotebook(_notebooks[index]),
                        ),
                      ),
                    );
                  },
                  childCount:
                      _notebooks.length > 6 ? 6 : _notebooks.length,
                ),
              ),
            ),
            // "查看全部" 按钮（超过 6 个时显示）
            if (_notebooks.length > 6)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                  child: GestureDetector(
                    onTap: _openAllNotebooks,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: MiaojiColors.card,
                        borderRadius:
                            BorderRadius.circular(MiaojiRadius.md),
                        border: Border.all(
                            color: MiaojiColors.borderLight, width: 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '查看全部 ${_notebooks.length} 个妙计本',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: MiaojiColors.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_rounded,
                              size: 16, color: MiaojiColors.primary),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else
              const SliverToBoxAdapter(
                  child: SizedBox(height: 24)),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1) AI 周报建议（mock）— 放最上面
        if (hasNotebooks) ...[
          _buildMiniSectionTitle(Icons.auto_awesome, 'AI 周报'),
          const SizedBox(height: 10),
          _buildAiSuggestionCard(),
        ],

        // 2) 近期提醒
        if (hasReminders) ...[
          SizedBox(height: hasNotebooks ? 20 : 0),
          _buildMiniSectionTitle(
              Icons.notifications_active_rounded, '近期提醒'),
          const SizedBox(height: 10),
          _buildReminderCard(),
        ],

        // 3) 没有任何数据时：功能引导
        if (!hasNotebooks && !hasReminders) _buildFeatureGuideCard(),
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
    return Container(
      padding: const EdgeInsets.all(16),
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
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.notifications_active_rounded,
                    size: 17, color: Color(0xFFD97706)),
              ),
              const SizedBox(width: 10),
              const Text(
                '近期提醒',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: MiaojiColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_upcomingReminders.length} 项',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFD97706),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 最多展示 3 条提醒
          ...(_upcomingReminders.take(3).map(_buildReminderItem)),
          if (_upcomingReminders.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '还有 ${_upcomingReminders.length - 3} 项提醒…',
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
      timeText = '${diff.inDays} 天后';
    } else if (diff.inHours > 0) {
      timeText = '${diff.inHours} 小时后';
    } else if (diff.inMinutes > 0) {
      timeText = '${diff.inMinutes} 分钟后';
    } else {
      timeText = '即将到来';
    }

    // 从 data 中取第一个文本值作为摘要
    final summary = record.data.values
        .where((v) => v is String && v.trim().isNotEmpty)
        .map((v) => v.toString())
        .firstOrNull;
    final displayText = summary ?? record.notebookName;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: diff.inHours < 24
                  ? const Color(0xFFEF4444)
                  : const Color(0xFFD4A24C),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
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
          Text(
            timeText,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: diff.inHours < 24
                  ? const Color(0xFFEF4444)
                  : MiaojiColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  // ── AI 周报卡片 ──

  Widget _buildAiSuggestionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3D3124), Color(0xFF5A4532)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(MiaojiRadius.lg),
        border: Border.all(
          color: const Color(0xFF8B7355).withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3D3124).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A24C).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFD4A24C).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome,
                        size: 12, color: Color(0xFFD4A24C)),
                    SizedBox(width: 4),
                    Text(
                      'AI 周报',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD4A24C),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '基于近 7 天数据',
                style: TextStyle(
                  fontSize: 10,
                  color: const Color(0xFFF5EFE0).withValues(alpha: 0.4),
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
                    color: const Color(0xFFD4A24C).withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '正在生成周报…',
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFFF5EFE0).withValues(alpha: 0.6),
                  ),
                ),
              ],
            )
          else if (_summaryText != null && _summaryText!.isNotEmpty)
            // Markdown 渲染周报内容
            MarkdownBody(
              data: _summaryText!,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(
                  fontSize: 13,
                  color: const Color(0xFFF5EFE0).withValues(alpha: 0.85),
                  height: 1.8,
                ),
                h1: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFF5EFE0).withValues(alpha: 0.9),
                ),
                h2: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFF5EFE0).withValues(alpha: 0.9),
                ),
                h3: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFF5EFE0).withValues(alpha: 0.9),
                ),
                strong: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFD4A24C).withValues(alpha: 0.9),
                ),
                listBullet: TextStyle(
                  fontSize: 13,
                  color: const Color(0xFFF5EFE0).withValues(alpha: 0.7),
                ),
                blockSpacing: 8,
              ),
              shrinkWrap: true,
            )
          else
            // 无内容或请求失败
            Text(
              '暂无周报数据，记录更多数据后自动生成',
              style: TextStyle(
                fontSize: 13,
                color: const Color(0xFFF5EFE0).withValues(alpha: 0.5),
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
                      color: const Color(0xFFD4A24C).withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '生成中…',
                    style: TextStyle(
                      fontSize: 10,
                      color: const Color(0xFFF5EFE0).withValues(alpha: 0.4),
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
        title: 'AI 智能创建',
        desc: '告诉 AI 你想记录什么，自动生成小本',
      ),
      _FeatureItem(
        icon: Icons.notifications_active_rounded,
        iconColor: const Color(0xFFEF4444),
        title: '智能提醒',
        desc: '为记录设置提醒，不再遗忘重要事项',
      ),
      _FeatureItem(
        icon: Icons.bar_chart_rounded,
        iconColor: const Color(0xFF3B82F6),
        title: '数据统计',
        desc: '自动生成趋势图、饼图等可视化分析',
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
          const Row(
            children: [
              Icon(Icons.waving_hand_rounded,
                  size: 20, color: Color(0xFFD4A24C)),
              SizedBox(width: 8),
              Text(
                '欢迎使用妙记兜',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: MiaojiColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            '点击底部「助理」标签，让 AI 帮你创建第一个小本吧',
            style: TextStyle(
              fontSize: 13,
              color: MiaojiColors.textTertiary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: MiaojiColors.borderLight),
          const SizedBox(height: 14),
          ...features.map((f) => Padding(
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
              )),
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
              border: Border.all(
                color: MiaojiColors.borderLight,
                width: 1.5,
              ),
              boxShadow: MiaojiShadows.paper,
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              size: 36,
              color: MiaojiColors.textHint,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '还没有小本',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: MiaojiColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '试试和 AI 助手说「帮我创建一个读书记录小本」',
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
      ).animate(
          CurvedAnimation(parent: _enterController, curve: interval)),
      child: FadeTransition(
        opacity: CurvedAnimation(
            parent: _enterController, curve: fadeInterval),
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

  const _IconButton({
    required this.icon,
    required this.onTap,
  });

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
          border: Border.all(
            color: MiaojiColors.borderLight,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: MiaojiColors.textSecondary,
          size: 20,
        ),
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
