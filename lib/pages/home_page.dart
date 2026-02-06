import 'package:flutter/material.dart';
import '../models/notebook_item.dart';
import '../services/database_service.dart';
import '../theme/miaoji_theme.dart';
import '../widgets/ai_assistant_card.dart';
import '../widgets/category_tabs.dart';
import '../widgets/notebook_tile.dart';

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
                interval: const Interval(0.1, 0.6, curve: Curves.easeOutCubic),
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
                interval: const Interval(0.3, 0.75, curve: Curves.easeOutCubic),
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
                child: CircularProgressIndicator(strokeWidth: 2),
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
                        bottom: index < _notebooks.length - 1 ? 12 : 0,
                      ),
                      child: _buildAnimated(
                        interval:
                            Interval(delay, end, curve: Curves.easeOutCubic),
                        fadeInterval: Interval(delay, end - 0.05),
                        child: NotebookTile(
                          item: _notebooks[index],
                          onTap: () {},
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
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: MiaojiColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(
              Icons.book_outlined,
              size: 32,
              color: MiaojiColors.primary.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 16),
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
              color: MiaojiColors.textHint.withValues(alpha: 0.7),
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
      ).animate(CurvedAnimation(parent: _enterController, curve: interval)),
      child: FadeTransition(
        opacity: CurvedAnimation(parent: _enterController, curve: fadeInterval),
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
          Text(
            'Miaoji',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [MiaojiColors.primary, Color(0xFF8B5CF6)],
                    ).createShader(const Rect.fromLTWH(0, 0, 100, 32)),
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
            gradient: true,
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
          Text(
            '我的小本',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
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

/// 顶部栏图标按钮
class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool gradient;

  const _IconButton({
    required this.icon,
    required this.onTap,
    this.gradient = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: gradient ? null : MiaojiColors.surface,
          gradient: gradient
              ? LinearGradient(
                  colors: [
                    MiaojiColors.primary.withValues(alpha: 0.15),
                    MiaojiColors.accent.withValues(alpha: 0.15),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(13),
          boxShadow: gradient ? null : MiaojiShadows.sm,
          border: Border.all(
            color: gradient
                ? MiaojiColors.primary.withValues(alpha: 0.2)
                : MiaojiColors.borderLight,
            width: gradient ? 1.5 : 1,
          ),
        ),
        child: Icon(
          icon,
          color: gradient ? MiaojiColors.primary : MiaojiColors.textSecondary,
          size: 20,
        ),
      ),
    );
  }
}
