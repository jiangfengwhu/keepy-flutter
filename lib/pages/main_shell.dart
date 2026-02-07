import 'package:flutter/material.dart';
import '../theme/miaoji_theme.dart';
import '../widgets/ai_chat_sheet.dart';
import 'home_page.dart';
import 'profile_page.dart';

/// 主框架 - 底部导航 + 页面切换
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final GlobalKey<HomePageState> _homeKey = GlobalKey<HomePageState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(key: _homeKey),
      const SizedBox.expand(), // 助手 tab 占位（点击时弹出 BottomSheet）
      const ProfilePage(),
    ];
  }

  void _onTabTapped(int index) {
    if (index == 1) {
      showAiChatSheet(context).then((_) {
        _homeKey.currentState?.refreshNotebooks();
      });
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
      bottomNavigationBar: _BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

/// 底部导航栏 — 纸质边框风格
class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MiaojiColors.card,
        border: Border(
          top: BorderSide(
            color: MiaojiColors.divider.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B6914).withValues(alpha: 0.04),
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
          bottom: MediaQuery.of(context).padding.bottom > 12
              ? MediaQuery.of(context).padding.bottom - 12
              : 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.menu_book_outlined,
              activeIcon: Icons.menu_book_rounded,
              label: '主页',
              isSelected: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _NavItem(
              icon: Icons.edit_note_outlined,
              activeIcon: Icons.edit_note_rounded,
              label: '妙记',
              isSelected: false,
              isSpecial: true,
              onTap: () => onTap(1),
            ),
            _NavItem(
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: '我的',
              isSelected: currentIndex == 2,
              onTap: () => onTap(2),
            ),
          ],
        ),
      ),
    );
  }
}

/// 底部导航栏单项
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final bool isSpecial;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    this.isSpecial = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: 48,
              height: 32,
              decoration: isSpecial
                  ? BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5A4532), Color(0xFF8B6914)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5A4532)
                              .withValues(alpha: 0.3),
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
                    ? const Color(0xFFD4A24C)
                    : isSelected
                        ? MiaojiColors.primary
                        : MiaojiColors.textTertiary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected || isSpecial
                    ? FontWeight.w600
                    : FontWeight.w400,
                color: isSpecial
                    ? MiaojiColors.primaryDark
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
