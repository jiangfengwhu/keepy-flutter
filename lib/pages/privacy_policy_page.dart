import 'package:flutter/material.dart';
import '../theme/miaoji_theme.dart';

/// 隐私政策页面
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('隐私政策'),
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
            _buildSectionTitle('妙记隐私政策'),
            _buildParagraph('更新日期：2026年2月9日'),
            _buildParagraph('生效日期：2026年2月9日'),
            const SizedBox(height: 16),
            _buildParagraph(
              '妙记（以下简称"我们"）深知个人信息对您的重要性，并会尽全力保护您的个人信息安全可靠。'
              '我们致力于维持您对我们的信任，恪守以下原则保护您的个人信息：权责一致原则、目的明确原则、'
              '选择同意原则、最少够用原则、确保安全原则、主体参与原则、公开透明原则等。',
            ),
            _buildParagraph(
              '本隐私政策旨在向您说明我们如何收集、使用、存储、共享和保护您的个人信息，'
              '以及您如何管理您的个人信息。请您在使用本应用前仔细阅读本隐私政策。',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('一、我们收集的信息'),
            _buildSubTitle('1.1 您主动提供的信息'),
            _buildParagraph(
              '(a) 笔记内容：您在应用中创建的笔记本、记录的文字内容、分类标签等信息。这些数据主要存储在您的本地设备中。\n\n'
              '(b) 语音数据：当您使用语音输入功能时，我们会临时采集您的语音信息用于语音识别转文字。'
              '语音数据仅在识别过程中使用，不会被永久存储。\n\n'
              '(c) 图片数据：当您使用图片相关功能时，我们会访问您的相机或相册以获取图片。'
              '图片数据存储在本地设备中。',
            ),
            _buildSubTitle('1.2 我们自动收集的信息'),
            _buildParagraph(
              '(a) 设备信息：包括设备型号、操作系统版本、设备标识符等，用于保障应用的正常运行和优化用户体验。\n\n'
              '(b) 应用使用信息：包括功能使用频率、错误日志等匿名数据，用于改善应用性能和服务质量。\n\n'
              '(c) 购买记录：当您进行应用内购买时，我们会记录购买状态以提供相应的付费功能服务。'
              '支付过程由 Apple App Store 或 Google Play 处理，我们不会收集您的支付账户信息。',
            ),
            _buildSubTitle('1.3 AI 功能相关信息'),
            _buildParagraph(
              '当您使用 AI 智能助手功能时，您主动发送给 AI 的笔记内容或对话信息可能会被传输至安全的云端服务器进行处理。'
              '我们仅在提供 AI 服务所必需的范围内使用这些数据，不会将其用于其他目的。',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('二、信息的使用'),
            _buildParagraph(
              '我们收集的信息将用于以下目的：\n\n'
              '(a) 提供核心服务：笔记创建与管理、语音输入转文字、提醒通知等基础功能。\n\n'
              '(b) AI 智能服务：基于您的笔记内容提供智能总结、分析和问答服务。\n\n'
              '(c) 服务优化：分析匿名使用数据以改善应用性能、修复问题和优化功能体验。\n\n'
              '(d) 安全保障：检测和防范安全风险，保护您的数据安全。\n\n'
              '(e) 通知服务：在您设置的时间发送提醒通知。',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('三、信息的存储'),
            _buildSubTitle('3.1 存储位置'),
            _buildParagraph(
              '您的笔记数据主要存储在您的本地设备中（使用 SQLite 数据库）。'
              '当您使用 AI 功能时，相关数据可能会临时传输至云端服务器处理，处理完成后不会在服务端永久保存。',
            ),
            _buildSubTitle('3.2 存储期限'),
            _buildParagraph(
              '我们仅在为实现目的所必需的时间内保留您的个人信息。当您删除笔记或卸载应用后，'
              '您的本地数据将被相应删除。云端临时处理的数据将在处理完成后及时清除。',
            ),
            _buildSubTitle('3.3 数据安全'),
            _buildParagraph(
              '我们采取以下措施保护您的信息安全：\n\n'
              '(a) 使用安全的本地存储方案（如 Flutter Secure Storage）保护敏感数据。\n\n'
              '(b) 与云端服务器的数据传输采用 HTTPS 加密协议。\n\n'
              '(c) 严格限制数据访问权限，仅在必要时访问您的数据。',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('四、信息的共享'),
            _buildParagraph(
              '我们承诺不会将您的个人信息出售给任何第三方。在以下情况下，我们可能会共享您的信息：\n\n'
              '(a) 经您明确同意后共享。\n\n'
              '(b) 为提供 AI 服务，将必要数据传输至 AI 服务提供商进行处理。'
              '我们要求 AI 服务提供商严格遵守数据保护协议。\n\n'
              '(c) 根据法律法规、法律程序或政府机关的强制性要求。\n\n'
              '(d) 为保护我们的用户、公众或我们的合法权益所合理必需。',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('五、您的权利'),
            _buildParagraph(
              '您对自己的个人信息享有以下权利：\n\n'
              '(a) 访问权：您可以随时查看和访问您在应用中的所有数据。\n\n'
              '(b) 更正权：您可以随时编辑和修改您的笔记内容。\n\n'
              '(c) 删除权：您可以随时删除您的笔记、笔记本或其他数据。卸载应用将删除所有本地数据。\n\n'
              '(d) 权限管理：您可以在设备设置中随时开启或关闭我们请求的权限'
              '（如麦克风、相机、相册、通知等）。关闭权限可能影响相关功能的使用。',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('六、设备权限说明'),
            _buildParagraph(
              '本应用可能请求以下设备权限：\n\n'
              '(a) 麦克风权限：用于语音输入功能，将您的语音转换为文字。\n\n'
              '(b) 相机/相册权限：用于拍照或选取图片功能。\n\n'
              '(c) 通知权限：用于发送您设置的提醒通知。\n\n'
              '以上权限均为可选权限，仅在您使用对应功能时才会请求，且您可以随时在系统设置中关闭。',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('七、未成年人保护'),
            _buildParagraph(
              '我们高度重视未成年人的个人信息保护。如果您是未满 14 周岁的未成年人，'
              '请在法定监护人的陪同和指导下阅读本隐私政策，并在取得监护人同意后使用本应用。',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('八、隐私政策的更新'),
            _buildParagraph(
              '我们可能会不时更新本隐私政策。更新后的政策将在应用内以适当方式通知您。'
              '若更新涉及重大变更（如收集信息范围扩大），我们将以弹窗或其他显著方式再次征求您的同意。',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('九、联系我们'),
            _buildParagraph(
              '如您对本隐私政策有任何疑问、意见或建议，或者您需要行使个人信息相关权利，请通过以下方式联系我们：\n\n'
              '应用名称：妙记\n'
              '邮箱：privacy@miaoji.app\n\n'
              '我们将在收到您的请求后 15 个工作日内予以回复。',
            ),
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
