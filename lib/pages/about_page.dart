import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../l10n/l10n_ext.dart';
import '../theme/miaoji_theme.dart';
import 'user_agreement_page.dart';
import 'privacy_policy_page.dart';

/// 关于页面
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _version = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadVersionInfo();
  }

  Future<void> _loadVersionInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _version = info.version;
      _buildNumber = info.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MiaojiColors.background,
      appBar: AppBar(
        title: Text(context.l10n.aboutTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 32),
            // App 图标
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                boxShadow: MiaojiShadows.md,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.asset(
                  'assets/images/app_icon.png',
                  width: 88,
                  height: 88,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // App 名称
            Text(
              context.l10n.appName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: MiaojiColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            // 版本号
            Text(
              _version.isNotEmpty
                  ? context.l10n.aboutVersionInfo(_version, _buildNumber)
                  : context.l10n.aboutVersionLoading,
              style: const TextStyle(
                fontSize: 14,
                color: MiaojiColors.textTertiary,
              ),
            ),
            const SizedBox(height: 8),
            // 一句话描述
            Text(
              context.l10n.appTagline,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: MiaojiColors.textSecondary,
              ),
            ),
            const SizedBox(height: 40),

            // 功能列表卡片
            _buildLinksCard(),

            const SizedBox(height: 24),

            // 备案信息
            _buildFooterInfo(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLinksCard() {
    final items = [
      _LinkItem(
        icon: Icons.description_outlined,
        label: context.l10n.userAgreementTitle,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UserAgreementPage()),
        ),
      ),
      _LinkItem(
        icon: Icons.shield_outlined,
        label: context.l10n.privacyPolicyTitle,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
        ),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: MiaojiColors.card,
        borderRadius: BorderRadius.circular(MiaojiRadius.xl),
        boxShadow: MiaojiShadows.paper,
        border: Border.all(color: MiaojiColors.borderLight, width: 1),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          return Column(
            children: [
              GestureDetector(
                onTap: item.onTap,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: MiaojiColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: MiaojiColors.primary.withValues(alpha: 0.15),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          item.icon,
                          color: MiaojiColors.primary,
                          size: 20,
                        ),
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

  Widget _buildFooterInfo() {
    return Column(
      children: [
        Text(
          context.l10n.aboutCopyright(DateTime.now().year),
          style: const TextStyle(fontSize: 12, color: MiaojiColors.textHint),
        ),
        const SizedBox(height: 6),
        // Text(
        //   context.l10n.aboutIcp,
        //   style: const TextStyle(fontSize: 12, color: MiaojiColors.textHint),
        // ),
        const SizedBox(height: 4),
        Text(
          context.l10n.aboutSupportEmail,
          style: const TextStyle(fontSize: 12, color: MiaojiColors.textHint),
        ),
      ],
    );
  }
}

class _LinkItem {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _LinkItem({required this.icon, required this.label, this.onTap});
}
