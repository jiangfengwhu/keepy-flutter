import 'package:flutter/material.dart';
import '../models/notebook_item.dart';
import '../services/database_service.dart';
import '../theme/miaoji_theme.dart';
import '../widgets/ai_assistant_card.dart';
import '../widgets/category_tabs.dart';
import '../widgets/notebook_tile.dart';
import 'notebook_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _enterController;
  int _selectedTabIndex = 0;
  final DatabaseService _dbService = DatabaseService();

  final List<String> _tabs = ['全部', '个人', '工作', '健康', '财务'];

  List<NotebookItem> _notebooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadNotebooks();
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
      _loadNotebooks();
    }
  }

  Future<void> _loadNotebooks() async {
    try {
      final notebooks = await _dbService.getAllNotebooks();
      if (!mounted) return;
      setState(() {
        _notebooks =
            notebooks.map((nb) => NotebookItem.fromNotebook(nb)).toList();
        _isLoading = false;
      });
      if (!_enterController.isCompleted) {
        _enterController.forward();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _enterController.forward();
    }
  }

  /// 外部调用刷新笔记本列表
  void refreshNotebooks() {
    _loadNotebooks();
  }

  void _openNotebook(NotebookItem item) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => NotebookDetailPage(notebookItem: item),
          ),
        )
        .then((_) => _loadNotebooks());
  }

  @override
  Widget build(BuildContext context) {
    final safePadding = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: MiaojiColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 顶部栏
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, safePadding.top + 16, 24, 0),
              child: _buildTopBar(),
            ),
          ),

          // AI 助手卡片
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: _buildAnimated(
                interval:
                    const Interval(0.1, 0.6, curve: Curves.easeOutCubic),
                fadeInterval: const Interval(0.1, 0.5),
                child: AiAssistantCard(onTap: () {}),
              ),
            ),
          ),

          // 标题
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: _buildSectionHeader(),
            ),
          ),

          // 分类 Tab
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
              child: _buildAnimated(
                interval:
                    const Interval(0.3, 0.75, curve: Curves.easeOutCubic),
                fadeInterval: const Interval(0.3, 0.65),
                child: CategoryTabs(
                  tabs: _tabs,
                  selectedIndex: _selectedTabIndex,
                  onTabSelected: (i) =>
                      setState(() => _selectedTabIndex = i),
                ),
              ),
            ),
          ),

          // 笔记本列表 / 空状态 / 加载中
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
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final delay = 0.35 + index * 0.08;
                    final end = (delay + 0.4).clamp(0.0, 1.0);
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index < _notebooks.length - 1 ? 14 : 0,
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
                  childCount: _notebooks.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── 空状态 ──────────────────────────────────

  Widget _buildEmptyNotebooks() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 空白笔记本图标
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

  // ── 入场动画辅助 ──────────────────────────────

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

  // ── 顶部栏 ──────────────────────────────────

  Widget _buildTopBar() {
    return _buildAnimated(
      interval: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      fadeInterval: const Interval(0.0, 0.4),
      child: Row(
        children: [
          // 品牌名 — 笔墨书法感
          Text(
            '小本',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: MiaojiColors.textPrimary,
                ),
          ),
          const SizedBox(width: 6),
          // 小墨点装饰
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: MiaojiColors.primary.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
          ),
          const Spacer(),
          _IconButton(
            icon: Icons.search_rounded,
            onTap: () {},
          ),
          const SizedBox(width: 10),
          _IconButton(
            icon: Icons.person_outline_rounded,
            onTap: () {},
            accent: true,
          ),
        ],
      ),
    );
  }

  // ── 标题栏 ──────────────────────────────────

  Widget _buildSectionHeader() {
    return _buildAnimated(
      interval: const Interval(0.25, 0.7, curve: Curves.easeOutCubic),
      fadeInterval: const Interval(0.25, 0.6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // 小装饰线
              Container(
                width: 3,
                height: 18,
                decoration: BoxDecoration(
                  color: MiaojiColors.primary,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '我的小本',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {},
            child: const Text(
              '查看全部',
              style: TextStyle(
                color: MiaojiColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 顶部栏图标按钮 — 纸质风格
class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool accent;

  const _IconButton({
    required this.icon,
    required this.onTap,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: accent
              ? MiaojiColors.primary.withValues(alpha: 0.08)
              : MiaojiColors.card,
          borderRadius: BorderRadius.circular(13),
          boxShadow: accent ? null : MiaojiShadows.sm,
          border: Border.all(
            color: accent
                ? MiaojiColors.primary.withValues(alpha: 0.2)
                : MiaojiColors.borderLight,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: accent
              ? MiaojiColors.primary
              : MiaojiColors.textSecondary,
          size: 20,
        ),
      ),
    );
  }
}
