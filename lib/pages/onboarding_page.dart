import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/l10n_ext.dart';
import '../theme/miaoji_theme.dart';
import '../services/ticket_service.dart';
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

  // Ticket 相关状态
  String? _ticketId;
  bool _ticketLoading = false;
  bool _ticketFailed = false;

  List<_OnboardingData> get _pages => _getPages();

  List<_OnboardingData> _getPages() {
    final l10n = context.l10n;
    return [
      _OnboardingData(
        icon: Icons.menu_book_rounded,
        title: l10n.onboardingTitle1,
        subtitle: l10n.onboardingSubtitle1,
        description: l10n.onboardingDesc1,
      ),
      _OnboardingData(
        icon: Icons.auto_awesome_rounded,
        title: l10n.onboardingTitle2,
        subtitle: l10n.onboardingSubtitle2,
        description: l10n.onboardingDesc2,
      ),
      _OnboardingData(
        icon: Icons.notifications_active_rounded,
        title: l10n.onboardingTitle3,
        subtitle: l10n.onboardingSubtitle3,
        description: l10n.onboardingDesc3,
      ),
    ];
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  /// 当滑到最后一页时获取 ticket
  void _fetchTicketIfNeeded() {
    if (_ticketId != null || _ticketLoading) return;
    _fetchTicket();
  }

  Future<void> _fetchTicket() async {
    setState(() {
      _ticketLoading = true;
      _ticketFailed = false;
    });
    try {
      final id = await TicketService().getTicketId();
      if (!mounted) return;
      setState(() {
        _ticketId = id;
        _ticketLoading = false;
        _ticketFailed = id == null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _ticketLoading = false;
        _ticketFailed = true;
      });
    }
  }

  void _copyTicketId() {
    if (_ticketId == null) return;
    Clipboard.setData(ClipboardData(text: _ticketId!));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.onboardingTicketCopied),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
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
    final pages = _getPages();
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
                  opacity: _currentPage < pages.length - 1 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: TextButton(
                    onPressed: _currentPage < pages.length - 1
                        ? () {
                            _pageController.animateToPage(
                              pages.length - 1,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                    child: Text(
                      context.l10n.onboardingSkip,
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
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                  // 滑到最后一页时自动获取 ticket
                  if (index == pages.length - 1) {
                    _fetchTicketIfNeeded();
                  }
                },
                itemBuilder: (context, index) {
                  final isLastPage = index == pages.length - 1;
                  if (isLastPage) {
                    return _buildLastPageContent(pages[index]);
                  }
                  return _buildPage(pages[index]);
                },
              ),
            ),

            // 最后一页：协议文字放在指示器上方
            if (_currentPage == pages.length - 1) _buildAgreementText(),

            // 页面指示器
            _buildPageIndicator(),

            const SizedBox(height: 24),

            // 底部按钮区域
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: _currentPage == pages.length - 1
                  ? _buildStartButton()
                  : _buildNextButton(),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingData data) {
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

  /// 最后一页：展示 ticket ID 凭证信息
  Widget _buildLastPageContent(_OnboardingData data) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 图标
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
          const SizedBox(height: 32),

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
          const SizedBox(height: 24),

          // Ticket 凭证区域
          _buildTicketSection(l10n),
        ],
      ),
    );
  }

  /// 构建 Ticket 凭证展示区域
  Widget _buildTicketSection(dynamic l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MiaojiColors.card,
        borderRadius: BorderRadius.circular(MiaojiRadius.md),
        border: Border.all(
          color: MiaojiColors.borderLight,
          width: 1,
        ),
        boxShadow: MiaojiShadows.sm,
      ),
      child: Column(
        children: [
          // 凭证标题
          Row(
            children: [
              Icon(
                Icons.vpn_key_rounded,
                size: 18,
                color: MiaojiColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.onboardingTicketTitle,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: MiaojiColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 说明文字
          Text(
            l10n.onboardingTicketDesc,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: MiaojiColors.textTertiary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // Ticket ID 显示区域
          if (_ticketLoading)
            _buildTicketLoading(l10n)
          else if (_ticketFailed || _ticketId == null)
            _buildTicketError(l10n)
          else
            _buildTicketDisplay(l10n),
        ],
      ),
    );
  }

  /// 加载中状态
  Widget _buildTicketLoading(dynamic l10n) {
    return Column(
      children: [
        const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: MiaojiColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.onboardingTicketLoading,
          style: const TextStyle(
            fontSize: 13,
            color: MiaojiColors.textTertiary,
          ),
        ),
      ],
    );
  }

  /// 失败状态
  Widget _buildTicketError(dynamic l10n) {
    return Column(
      children: [
        Icon(
          Icons.error_outline_rounded,
          size: 36,
          color: Colors.red.shade400,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.onboardingTicketFailed,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.red.shade400,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.onboardingTicketFailedDesc,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: MiaojiColors.textTertiary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 36,
          child: OutlinedButton.icon(
            onPressed: _fetchTicket,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: Text(l10n.onboardingTicketRetry),
            style: OutlinedButton.styleFrom(
              foregroundColor: MiaojiColors.primary,
              side: BorderSide(color: MiaojiColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(MiaojiRadius.sm),
              ),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 成功展示 Ticket ID
  Widget _buildTicketDisplay(dynamic l10n) {
    return Column(
      children: [
        // Ticket ID 展示框
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: MiaojiColors.background,
            borderRadius: BorderRadius.circular(MiaojiRadius.sm),
            border: Border.all(
              color: MiaojiColors.primary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            _ticketId!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: MiaojiColors.textPrimary,
              fontFamily: 'monospace',
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 复制按钮
        SizedBox(
          height: 36,
          child: OutlinedButton.icon(
            onPressed: _copyTicketId,
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: Text(l10n.onboardingTicketCopy),
            style: OutlinedButton.styleFrom(
              foregroundColor: MiaojiColors.primary,
              side: BorderSide(color: MiaojiColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(MiaojiRadius.sm),
              ),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
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
        child: Text(
          context.l10n.onboardingNext,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// 协议文字（放在页面指示器上方）
  Widget _buildAgreementText() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          Text(
            context.l10n.onboardingAgreementPrefix,
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
              context.l10n.onboardingAgreementUserAgreement,
              style: TextStyle(
                fontSize: 12,
                color: MiaojiColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            context.l10n.onboardingAgreementAnd,
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
              context.l10n.onboardingAgreementPrivacyPolicy,
              style: TextStyle(
                fontSize: 12,
                color: MiaojiColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 同意并开始按钮（ticket 失败时禁用）
  Widget _buildStartButton() {
    final canProceed = _ticketId != null && !_ticketLoading;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: canProceed ? _completeOnboarding : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: MiaojiColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: MiaojiColors.primary.withValues(alpha: 0.4),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MiaojiRadius.md),
          ),
        ),
        child: Text(
          context.l10n.onboardingAgreeAndStart,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
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
