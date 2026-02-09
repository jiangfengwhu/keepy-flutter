import 'package:flutter/material.dart';
import '../theme/miaoji_theme.dart';

/// 用户服务协议页面
class UserAgreementPage extends StatelessWidget {
  const UserAgreementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用户服务协议'),
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
            _buildSectionTitle('妙记用户服务协议'),
            _buildParagraph('更新日期：2026年2月9日'),
            _buildParagraph('生效日期：2026年2月9日'),
            const SizedBox(height: 16),
            _buildParagraph(
              '欢迎您使用"妙记"应用程序（以下简称"本应用"）。请您在使用本应用之前，仔细阅读并充分理解本协议的全部内容。'
              '如果您不同意本协议的任何条款，请勿使用本应用。您一旦开始使用本应用，即表示您已充分理解并同意本协议。',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('一、服务说明'),
            _buildParagraph(
              '1.1 本应用是一款智能笔记管理工具，为用户提供笔记本创建与管理、文字记录、语音输入、AI 智能助手、'
              '提醒通知等功能服务（以下简称"本服务"）。',
            ),
            _buildParagraph(
              '1.2 本应用提供的服务内容可能会随版本更新而发生变化。我们保留随时修改、中断或终止部分或全部服务的权利，'
              '并将尽合理努力提前通知用户。',
            ),
            _buildParagraph(
              '1.3 您理解并同意，本应用可能包含免费功能和付费功能。付费功能将通过应用内购买（In-App Purchase）方式提供，'
              '具体内容和价格以应用内展示为准。',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('二、账号与使用规范'),
            _buildParagraph(
              '2.1 您在使用本应用时应遵守中华人民共和国相关法律法规，不得利用本应用从事任何违法违规活动。',
            ),
            _buildParagraph(
              '2.2 您应妥善保管设备及应用数据。因您个人原因导致的数据丢失、泄露等后果，由您自行承担。',
            ),
            _buildParagraph(
              '2.3 您不得利用本应用进行以下行为：\n'
              '  (a) 发布、传播违法、有害、威胁、侮辱、诽谤、色情或其他不当内容；\n'
              '  (b) 侵犯他人知识产权、隐私权或其他合法权益；\n'
              '  (c) 对本应用进行反向工程、反编译、反汇编或以其他方式试图获取源代码；\n'
              '  (d) 干扰或破坏本应用的正常运行，包括但不限于传播病毒、恶意代码等；\n'
              '  (e) 其他违反法律法规或本协议的行为。',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('三、知识产权'),
            _buildParagraph(
              '3.1 本应用的所有内容，包括但不限于界面设计、程序代码、文字、图片、图标、音频等，'
              '均受中华人民共和国著作权法及国际著作权条约的保护，其知识产权归本应用开发者所有。',
            ),
            _buildParagraph(
              '3.2 您在本应用中创建的笔记内容、录入的数据等用户生成内容，其知识产权归您所有。'
              '但您授权本应用在提供服务所必需的范围内使用这些内容（例如 AI 助手分析您的笔记以提供智能建议）。',
            ),
            _buildParagraph(
              '3.3 未经本应用开发者书面许可，您不得以任何形式复制、传播、展示、镜像或以其他方式使用本应用的任何内容。',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('四、AI 服务条款'),
            _buildParagraph(
              '4.1 本应用提供 AI 智能助手功能，可协助您进行笔记总结、内容分析、智能问答等操作。'
              'AI 生成的内容仅供参考，不构成任何专业建议。',
            ),
            _buildParagraph(
              '4.2 您理解并同意，AI 功能的回答可能存在不准确、不完整或不及时的情况，'
              '您应自行判断和验证 AI 提供的信息。因使用 AI 生成内容而导致的任何损失，本应用不承担责任。',
            ),
            _buildParagraph(
              '4.3 为提供 AI 服务，本应用可能需要将您的部分笔记内容发送至安全的云端服务器进行处理。'
              '我们将采取严格的数据安全措施保护您的信息，详情请参阅《隐私政策》。',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('五、付费服务'),
            _buildParagraph(
              '5.1 本应用部分功能为付费功能，通过 Apple App Store 或 Google Play 的应用内购买机制提供。'
              '付费前请仔细确认购买内容和价格。',
            ),
            _buildParagraph(
              '5.2 付费成功后，相关功能将立即开通。除法律另有规定外，已完成的购买不支持退款。'
              '如需退款，请联系对应应用商店的客服。',
            ),
            _buildParagraph(
              '5.3 订阅类服务将按周期自动续费，您可在应用商店的订阅管理中随时取消自动续费。'
              '取消后，当前订阅周期内的服务不受影响。',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('六、免责声明'),
            _buildParagraph(
              '6.1 本应用按"现状"提供服务，不对服务的及时性、安全性、准确性作出任何明示或暗示的保证。',
            ),
            _buildParagraph(
              '6.2 因不可抗力、系统维护、网络故障、设备故障等原因导致服务中断或数据丢失的，本应用不承担责任，'
              '但将尽合理努力减少对您的影响。',
            ),
            _buildParagraph(
              '6.3 您的笔记数据存储在本地设备中。我们建议您定期备份重要数据。'
              '因设备损坏、系统重置等导致的数据丢失，本应用不承担责任。',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('七、协议变更'),
            _buildParagraph(
              '7.1 我们有权根据需要修改本协议的内容。协议变更后，我们将在应用内以适当方式通知您。',
            ),
            _buildParagraph(
              '7.2 如您不同意修改后的协议，您有权停止使用本服务。如您在协议修改后继续使用本服务，'
              '则视为您已接受修改后的协议。',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('八、法律适用与争议解决'),
            _buildParagraph(
              '8.1 本协议的解释、效力和执行均适用中华人民共和国法律（不包括冲突法规则）。',
            ),
            _buildParagraph(
              '8.2 因本协议引起的或与本协议有关的任何争议，双方应首先通过友好协商解决。'
              '协商不成的，任何一方均可向本应用开发者所在地有管辖权的人民法院提起诉讼。',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('九、联系我们'),
            _buildParagraph(
              '如您对本协议有任何疑问或建议，请通过以下方式联系我们：\n\n'
              '应用名称：妙记\n'
              '邮箱：support@miaoji.app\n\n'
              '感谢您选择妙记，祝您使用愉快！',
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
