import 'package:flutter/material.dart';
import '../theme/miaoji_theme.dart';

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

  // 模拟笔记本数据
  final List<_NotebookItem> _notebooks = [
    _NotebookItem(
      icon: Icons.directions_run_rounded,
      iconColor: Color(0xFFEF4444),
      iconBg: Color(0xFFFEE2E2),
      title: '健身记录',
      subtitle: '上次记录：15 分钟前 · 跑步 5km',
    ),
    _NotebookItem(
      icon: Icons.auto_stories_rounded,
      iconColor: Color(0xFF8B5CF6),
      iconBg: Color(0xFFEDE9FE),
      title: '阅读清单',
      subtitle: '正在阅读：三体',
    ),
    _NotebookItem(
      icon: Icons.medication_rounded,
      iconColor: Color(0xFF10B981),
      iconBg: Color(0xFFD1FAE5),
      title: '用药记录',
      subtitle: '已服用：08:00 AM',
    ),
    _NotebookItem(
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
          // 顶部区域：标题 + 搜索 + 头像
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  EdgeInsets.fromLTRB(24, safePadding.top + 16, 24, 0),
              child: _buildTopBar(),
            ),
          ),

          // AI 助手卡片
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: _buildAiCard(),
            ),
          ),

          // "我的小本" 标题 + 查看全部
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
              child: _buildCategoryTabs(),
            ),
          ),

          // 笔记本列表
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index < _notebooks.length - 1 ? 12 : 0,
                    ),
                    child: _buildNotebookTile(_notebooks[index], index),
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

  // ─────────────────────────────────────────────
  // 顶部栏：App名 + 搜索 + 头像
  // ─────────────────────────────────────────────
  Widget _buildTopBar() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      )),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _enterController,
          curve: const Interval(0.0, 0.4),
        ),
        child: Row(
          children: [
            // App 名称
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
            // 搜索按钮
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: MiaojiColors.surface,
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: MiaojiShadows.sm,
                  border: Border.all(
                    color: MiaojiColors.borderLight,
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: MiaojiColors.textSecondary,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // 头像
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      MiaojiColors.primary.withValues(alpha: 0.15),
                      MiaojiColors.accent.withValues(alpha: 0.15),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: MiaojiColors.primary.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: MiaojiColors.primary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // AI 助手入口卡片
  // ─────────────────────────────────────────────
  Widget _buildAiCard() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.1, 0.6, curve: Curves.easeOutCubic),
      )),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _enterController,
          curve: const Interval(0.1, 0.5),
        ),
        child: GestureDetector(
          onTap: () {
            // TODO: 跳转 AI 创建页
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1E1B4B),
                  Color(0xFF312E81),
                  Color(0xFF3730A3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(MiaojiRadius.xl),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF312E81).withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                // 左侧内容
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // AI 标签
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius:
                                  BorderRadius.circular(MiaojiRadius.full),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  color: Color(0xFFFBBF24),
                                  size: 14,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'AI 助手',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        '创建新的记录本',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '描述你想记录的内容，让 AI 帮你自动构建数据结构',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // 右侧箭头
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // "我的小本" 标题 + 查看全部
  // ─────────────────────────────────────────────
  Widget _buildSectionHeader() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.25, 0.7, curve: Curves.easeOutCubic),
      )),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _enterController,
          curve: const Interval(0.25, 0.6),
        ),
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
              child: Text(
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
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 分类标签
  // ─────────────────────────────────────────────
  Widget _buildCategoryTabs() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.3, 0.75, curve: Curves.easeOutCubic),
      )),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _enterController,
          curve: const Interval(0.3, 0.65),
        ),
        child: SizedBox(
          height: 38,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: _tabs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final isSelected = _selectedTabIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedTabIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? MiaojiColors.primary
                        : MiaojiColors.surface,
                    borderRadius: BorderRadius.circular(MiaojiRadius.full),
                    border: isSelected
                        ? null
                        : Border.all(
                            color: MiaojiColors.borderLight,
                            width: 1,
                          ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color:
                                  MiaojiColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : MiaojiShadows.sm,
                  ),
                  child: Text(
                    _tabs[index],
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : MiaojiColors.textSecondary,
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 笔记本列表项
  // ─────────────────────────────────────────────
  Widget _buildNotebookTile(_NotebookItem item, int index) {
    final delay = 0.35 + index * 0.08;
    final endDelay = (delay + 0.4).clamp(0.0, 1.0);

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.15),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _enterController,
        curve: Interval(delay, endDelay, curve: Curves.easeOutCubic),
      )),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _enterController,
          curve: Interval(delay, endDelay - 0.05),
        ),
        child: GestureDetector(
          onTap: () {
            // TODO: 打开笔记本
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: MiaojiColors.surface,
              borderRadius: BorderRadius.circular(MiaojiRadius.lg),
              boxShadow: MiaojiShadows.sm,
              border: Border.all(
                color: MiaojiColors.borderLight,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // 图标
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: item.iconBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    item.icon,
                    color: item.iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                // 标题 + 描述
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: MiaojiColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: MiaojiColors.textTertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // 箭头
                Icon(
                  Icons.chevron_right_rounded,
                  color: MiaojiColors.textHint,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 数据模型
// ─────────────────────────────────────────────
class _NotebookItem {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;

  const _NotebookItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
  });
}
