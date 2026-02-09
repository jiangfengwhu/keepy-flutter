import 'package:flutter/material.dart';
import '../l10n/l10n_ext.dart';
import '../theme/miaoji_theme.dart';

/// 隐私政策页面
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.privacyPolicyTitle),
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
            _buildSectionTitle(context.l10n.privacyPolicyHeader),
            _buildParagraph(context.l10n.privacyPolicyUpdatedAt),
            _buildParagraph(context.l10n.privacyPolicyEffectiveAt),
            const SizedBox(height: 16),
            _buildParagraph(context.l10n.privacyPolicyIntro1),
            _buildParagraph(context.l10n.privacyPolicyIntro2),
            const SizedBox(height: 24),
            _buildSectionTitle(context.l10n.privacySection1Title),
            _buildSubTitle(context.l10n.privacySection1_1Title),
            _buildParagraph(context.l10n.privacySection1_1Content),
            _buildSubTitle(context.l10n.privacySection1_2Title),
            _buildParagraph(context.l10n.privacySection1_2Content),
            _buildSubTitle(context.l10n.privacySection1_3Title),
            _buildParagraph(context.l10n.privacySection1_3Content),
            const SizedBox(height: 24),
            _buildSectionTitle(context.l10n.privacySection2Title),
            _buildParagraph(context.l10n.privacySection2Content),
            const SizedBox(height: 24),
            _buildSectionTitle(context.l10n.privacySection3Title),
            _buildSubTitle(context.l10n.privacySection3_1Title),
            _buildParagraph(context.l10n.privacySection3_1Content),
            _buildSubTitle(context.l10n.privacySection3_2Title),
            _buildParagraph(context.l10n.privacySection3_2Content),
            _buildSubTitle(context.l10n.privacySection3_3Title),
            _buildParagraph(context.l10n.privacySection3_3Content),
            const SizedBox(height: 24),
            _buildSectionTitle(context.l10n.privacySection4Title),
            _buildParagraph(context.l10n.privacySection4Content),
            const SizedBox(height: 24),
            _buildSectionTitle(context.l10n.privacySection5Title),
            _buildParagraph(context.l10n.privacySection5Content),
            const SizedBox(height: 24),
            _buildSectionTitle(context.l10n.privacySection6Title),
            _buildParagraph(context.l10n.privacySection6Content),
            const SizedBox(height: 24),
            _buildSectionTitle(context.l10n.privacySection7Title),
            _buildParagraph(context.l10n.privacySection7Content),
            const SizedBox(height: 24),
            _buildSectionTitle(context.l10n.privacySection8Title),
            _buildParagraph(context.l10n.privacySection8Content),
            const SizedBox(height: 24),
            _buildSectionTitle(context.l10n.privacySection9Title),
            _buildParagraph(context.l10n.privacySection9Content),
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

  Widget _buildSubTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
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
