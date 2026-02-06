import 'package:flutter/material.dart';
import '../theme/miaoji_theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final safePadding = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: MiaojiColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 顶部
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, safePadding.top + 16, 24, 0),
              child: Text(
                '我的',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
              ),
            ),
          ),

          // 用户卡片
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: _buildProfileCard(context),
            ),
          ),

          // 设置列表
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: _buildSettingsSection(context),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MiaojiColors.surface,
        borderRadius: BorderRadius.circular(MiaojiRadius.xl),
        boxShadow: MiaojiShadows.md,
        border: Border.all(color: MiaojiColors.borderLight, width: 1),
      ),
      child: Row(
        children: [
          // 头像
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [MiaojiColors.primary, Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '用户',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: MiaojiColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '点击登录以同步数据',
                  style: TextStyle(
                    fontSize: 13,
                    color: MiaojiColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: MiaojiColors.textHint,
            size: 22,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    final items = [
      _SettingItem(Icons.palette_outlined, '主题', MiaojiColors.primary),
      _SettingItem(Icons.notifications_outlined, '通知', const Color(0xFFF59E0B)),
      _SettingItem(Icons.cloud_outlined, '数据备份', const Color(0xFF10B981)),
      _SettingItem(Icons.info_outline_rounded, '关于', const Color(0xFF8B5CF6)),
    ];

    return Container(
      decoration: BoxDecoration(
        color: MiaojiColors.surface,
        borderRadius: BorderRadius.circular(MiaojiRadius.xl),
        boxShadow: MiaojiShadows.sm,
        border: Border.all(color: MiaojiColors.borderLight, width: 1),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          return Column(
            children: [
              GestureDetector(
                onTap: () {},
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item.icon, color: item.color, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          item.label,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: MiaojiColors.textPrimary,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: MiaojiColors.textHint,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              if (index < items.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(
                    height: 1,
                    color: MiaojiColors.divider.withValues(alpha: 0.5),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _SettingItem {
  final IconData icon;
  final String label;
  final Color color;
  const _SettingItem(this.icon, this.label, this.color);
}
