import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/miaoji_theme.dart';
import 'user_agreement_page.dart';
import 'privacy_policy_page.dart';
import 'main_shell.dart';

/// 引导页 - 首次启动时展示
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      icon: Icons.menu_book_rounded,
      title: '欢迎使用妙记',
      subtitle: '你的智能笔记伙伴',
      description: '妙记帮你轻松管理生活中的每一条重要信息，\n让记录变得简单、有序、有温度。',
    ),
    _OnboardingData(
      icon: Icons.auto_awesome_rounded,
      title: 'AI 智能助手',
      subtitle: '懂你所想，记你所需',
      description: '内置 AI 助手，支持语音输入、智能总结、\n内容分析，让你的笔记更加智能高效。',
    ),
    _OnboardingData(
      icon: Icons.notifications_active_rounded,
      title: '贴心提醒',
      subtitle: '重要的事，不再遗忘',
      description: '灵活的提醒功能，为每条笔记设定通知，\n确保你不会错过任何重要时刻。',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MiaojiColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 跳过按钮
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, right: 16),
                child: AnimatedOpacity(
                  opacity: _currentPage < _pages.length - 1 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: TextButton(
                    onPressed: _currentPage < _pages.length - 1
                        ? () {
                            _pageController.animateToPage(
                              _pages.length - 1,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                    child: Text(
                      '跳过',
                      style: TextStyle(
                        color: MiaojiColors.textTertiary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 页面内容
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index], index == _pages.length - 1);
                },
              ),
            ),

            // 页面指示器
            _buildPageIndicator(),

            const SizedBox(height: 24),

            // 底部按钮区域
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: _currentPage == _pages.length - 1
                  ? _buildLastPageButtons()
                  : _buildNextButton(),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingData data, bool isLastPage) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 图标容器 - 纸质风格卡片
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: MiaojiColors.card,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: MiaojiColors.borderLight,
                width: 1,
              ),
              boxShadow: MiaojiShadows.md,
            ),
            child: Icon(
              data.icon,
              size: 56,
              color: MiaojiColors.primary,
            ),
          ),
          const SizedBox(height: 48),

          // 标题
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: MiaojiColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),

          // 副标题
          Text(
            data.subtitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: MiaojiColors.primary,
            ),
          ),
          const SizedBox(height: 20),

          // 描述
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: MiaojiColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? MiaojiColors.primary
                : MiaojiColors.borderLight,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _nextPage,
        style: ElevatedButton.styleFrom(
          backgroundColor: MiaojiColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MiaojiRadius.md),
          ),
        ),
        child: const Text(
          '下一步',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLastPageButtons() {
    return Column(
      children: [
        // 协议文字
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Wrap(
            alignment: WrapAlignment.center,
            children: [
              Text(
                '点击"同意并开始"即表示您已阅读并同意',
                style: TextStyle(
                  fontSize: 12,
                  color: MiaojiColors.textTertiary,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UserAgreementPage(),
                    ),
                  );
                },
                child: Text(
                  '《用户服务协议》',
                  style: TextStyle(
                    fontSize: 12,
                    color: MiaojiColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '和',
                style: TextStyle(
                  fontSize: 12,
                  color: MiaojiColors.textTertiary,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PrivacyPolicyPage(),
                    ),
                  );
                },
                child: Text(
                  '《隐私政策》',
                  style: TextStyle(
                    fontSize: 12,
                    color: MiaojiColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 同意并开始按钮
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _completeOnboarding,
            style: ElevatedButton.styleFrom(
              backgroundColor: MiaojiColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(MiaojiRadius.md),
              ),
            ),
            child: const Text(
              '同意并开始',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 引导页数据模型
class _OnboardingData {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;

  const _OnboardingData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
  });
}
