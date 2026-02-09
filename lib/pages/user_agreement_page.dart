import 'package:flutter/material.dart';
import '../l10n/l10n_ext.dart';
import '../theme/miaoji_theme.dart';

/// 用户服务协议页面
class UserAgreementPage extends StatelessWidget {
  const UserAgreementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.userAgreementTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context.l10n.userAgreementHeader),
            _buildParagraph(context.l10n.userAgreementUpdatedAt),
            _buildParagraph(context.l10n.userAgreementEffectiveAt),
            const SizedBox(height: 16),
            _buildParagraph(context.l10n.userAgreementIntro),
            const SizedBox(height: 24),
            _buildSectionTitle(context.l10n.userAgreementSection1Title),
            _buildParagraph(context.l10n.userAgreementSection1Content1),
            _buildParagraph(context.l10n.userAgreementSection1Content2),
            _buildParagraph(context.l10n.userAgreementSection1Content3),
            const SizedBox(height: 24),
            _buildSectionTitle(context.l10n.userAgreementSection2Title),
            _buildParagraph(context.l10n.userAgreementSection2Content1),
            _buildParagraph(context.l10n.userAgreementSection2Content2),
            _buildParagraph(context.l10n.userAgreementSection2Content3),
            const SizedBox(height: 24),
            _buildSectionTitle(context.l10n.userAgreementSection3Title),
            _buildParagraph(context.l10n.userAgreementSection3Content1),
            _buildParagraph(context.l10n.userAgreementSection3Content2),
            _buildParagraph(context.l10n.userAgreementSection3Content3),
            const SizedBox(height: 24),
            _buildSectionTitle(context.l10n.userAgreementSection4Title),
            _buildParagraph(context.l10n.userAgreementSection4Content1),
            _buildParagraph(context.l10n.userAgreementSection4Content2),
            _buildParagraph(context.l10n.userAgreementSection4Content3),
            const SizedBox(height: 24),
            _buildSectionTitle(context.l10n.userAgreementSection5Title),
            _buildParagraph(context.l10n.userAgreementSection5Content1),
            _buildParagraph(context.l10n.userAgreementSection5Content2),
            _buildParagraph(context.l10n.userAgreementSection5Content3),
            const SizedBox(height: 24),
            _buildSectionTitle(context.l10n.userAgreementSection6Title),
            _buildParagraph(context.l10n.userAgreementSection6Content1),
            _buildParagraph(context.l10n.userAgreementSection6Content2),
            _buildParagraph(context.l10n.userAgreementSection6Content3),
            const SizedBox(height: 24),
            _buildSectionTitle(context.l10n.userAgreementSection7Title),
            _buildParagraph(context.l10n.userAgreementSection7Content1),
            _buildParagraph(context.l10n.userAgreementSection7Content2),
            const SizedBox(height: 24),
            _buildSectionTitle(context.l10n.userAgreementSection8Title),
            _buildParagraph(context.l10n.userAgreementSection8Content1),
            _buildParagraph(context.l10n.userAgreementSection8Content2),
            const SizedBox(height: 24),
            _buildSectionTitle(context.l10n.userAgreementSection9Title),
            _buildParagraph(context.l10n.userAgreementSection9Content),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: MiaojiColors.textPrimary,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: MiaojiColors.textSecondary,
          height: 1.8,
        ),
      ),
    );
  }
}
