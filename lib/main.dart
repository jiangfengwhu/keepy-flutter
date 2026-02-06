import 'package:flutter/material.dart';
import 'theme/miaoji_theme.dart';
import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'widgets/ai_chat_sheet.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Miaoji',
      debugShowCheckedModeBanner: false,
      theme: MiaojiTheme.theme,
      home: const MainShell(),
    );
  }
}

/// 主框架 - 底部导航 + 页面
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    SizedBox.shrink(), // 助理 tab 不对应页面，点击弹出 Sheet
    ProfilePage(),
  ];

  void _onTabTapped(int index) {
    if (index == 1) {
      // 点击"助理" tab → 弹出 AI 聊天 BottomSheet，不切换页面
      showAiChatSheet(context);
      return;
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: MiaojiColors.surface,
        border: Border(
          top: BorderSide(
            color: MiaojiColors.divider.withValues(alpha: 0.4),
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 8,
          right: 8,
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom > 0
              ? MediaQuery.of(context).padding.bottom - 12
              : 8,
        ),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: '首页',
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.auto_awesome_outlined,
                activeIcon: Icons.auto_awesome,
                label: '助理',
                isSpecial: true,
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: '我的',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    bool isSpecial = false,
  }) {
    // 助理 tab 永远不会处于 selected 状态
    final isSelected = !isSpecial && _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图标
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: 48,
              height: 32,
              decoration: isSpecial
                  ? BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [MiaojiColors.primary, Color(0xFF8B5CF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: MiaojiColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    )
                  : BoxDecoration(
                      color: isSelected
                          ? MiaojiColors.primary.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
              child: Icon(
                isSelected ? activeIcon : icon,
                size: isSpecial ? 18 : 22,
                color: isSpecial
                    ? Colors.white
                    : isSelected
                        ? MiaojiColors.primary
                        : MiaojiColors.textTertiary,
              ),
            ),
            const SizedBox(height: 3),
            // 名称
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected || isSpecial
                    ? FontWeight.w600
                    : FontWeight.w400,
                color: isSpecial
                    ? MiaojiColors.primary
                    : isSelected
                        ? MiaojiColors.primary
                        : MiaojiColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
