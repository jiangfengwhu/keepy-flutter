import 'package:flutter/material.dart';
import '../models/notebook_item.dart';
import '../theme/miaoji_theme.dart';
import '../widgets/ai_assistant_card.dart';
import '../widgets/category_tabs.dart';
import '../widgets/notebook_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _enterController;
  int _selectedTabIndex = 0;

  final List<String> _tabs = ['全部', '个人', '工作', '健康', '财务'];

  final List<NotebookItem> _notebooks = const [
    NotebookItem(
      icon: Icons.directions_run_rounded,
      iconColor: Color(0xFFEF4444),
      iconBg: Color(0xFFFEE2E2),
      title: '健身记录',
      subtitle: '上次记录：15 分钟前 · 跑步 5km',
    ),
    NotebookItem(
      icon: Icons.auto_stories_rounded,
      iconColor: Color(0xFF8B5CF6),
      iconBg: Color(0xFFEDE9FE),
      title: '阅读清单',
      subtitle: '正在阅读：三体',
    ),
    NotebookItem(
      icon: Icons.medication_rounded,
      iconColor: Color(0xFF10B981),
      iconBg: Color(0xFFD1FAE5),
      title: '用药记录',
      subtitle: '已服用：08:00 AM',
    ),
    NotebookItem(
      icon: Icons.payments_rounded,
      iconColor: Color(0xFFF59E0B),
      iconBg: Color(0xFFFEF3C7),
      title: '消费记录',
      subtitle: '咖啡：¥32.00',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _enterController.forward();
  }

  @override
  void dispose() {
    _enterController.dispose();
    super.dispose();
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

          // 笔记本列表
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
                      interval: Interval(delay, end, curve: Curves.easeOutCubic),
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
