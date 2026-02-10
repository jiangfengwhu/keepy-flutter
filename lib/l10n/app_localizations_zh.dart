// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => '妙记';

  @override
  String get navHome => '主页';

  @override
  String get navAssistant => '妙记';

  @override
  String get navProfile => '我的';

  @override
  String get onboardingTitle1 => '欢迎使用妙记';

  @override
  String get onboardingSubtitle1 => '你的智能笔记伙伴';

  @override
  String get onboardingDesc1 => '妙记帮你轻松管理生活中的每一条重要信息，\n让记录变得简单、有序、有温度。';

  @override
  String get onboardingTitle2 => 'AI 智能助手';

  @override
  String get onboardingSubtitle2 => '懂你所想，记你所需';

  @override
  String get onboardingDesc2 => '内置 AI 助手，支持语音输入、智能总结、\n内容分析，让你的笔记更加智能高效。';

  @override
  String get onboardingTitle3 => '贴心提醒';

  @override
  String get onboardingSubtitle3 => '重要的事，不再遗忘';

  @override
  String get onboardingDesc3 => '灵活的提醒功能，为每条笔记设定通知，\n确保你不会错过任何重要时刻。';

  @override
  String get onboardingSkip => '跳过';

  @override
  String get onboardingNext => '下一步';

  @override
  String get onboardingAgreementPrefix => '点击\"同意并开始\"即表示您已阅读并同意';

  @override
  String get onboardingAgreementUserAgreement => '《用户服务协议》';

  @override
  String get onboardingAgreementAnd => '和';

  @override
  String get onboardingAgreementPrivacyPolicy => '《隐私政策》';

  @override
  String get onboardingAgreeAndStart => '同意并开始';

  @override
  String get aboutTitle => '关于';

  @override
  String aboutVersionInfo(Object version, Object build) {
    return '版本 $version ($build)';
  }

  @override
  String get aboutVersionLoading => '加载中…';

  @override
  String get appTagline => '你的智能笔记伙伴';

  @override
  String get userAgreementTitle => '用户服务协议';

  @override
  String get privacyPolicyTitle => '隐私政策';

  @override
  String aboutCopyright(Object year) {
    return '妙记 © $year';
  }

  @override
  String get aboutIcp => 'ICP备案号：京ICP备XXXXXXXX号-X';

  @override
  String get aboutSupportEmail => '联系邮箱：support@miaoji.app';

  @override
  String get privacyPolicyHeader => '妙记隐私政策';

  @override
  String get privacyPolicyUpdatedAt => '更新日期：2026年2月9日';

  @override
  String get privacyPolicyEffectiveAt => '生效日期：2026年2月9日';

  @override
  String get privacyPolicyIntro1 =>
      '妙记（以下简称\"我们\"）深知个人信息对您的重要性，并会尽全力保护您的个人信息安全可靠。我们致力于维持您对我们的信任，恪守以下原则保护您的个人信息：权责一致原则、目的明确原则、选择同意原则、最少够用原则、确保安全原则、主体参与原则、公开透明原则等。';

  @override
  String get privacyPolicyIntro2 =>
      '本隐私政策旨在向您说明我们如何收集、使用、存储、共享和保护您的个人信息，以及您如何管理您的个人信息。请您在使用本应用前仔细阅读本隐私政策。';

  @override
  String get privacySection1Title => '一、我们收集的信息';

  @override
  String get privacySection1_1Title => '1.1 您主动提供的信息';

  @override
  String get privacySection1_1Content =>
      '(a) 笔记内容：您在应用中创建的笔记本、记录的文字内容、分类标签等信息。这些数据主要存储在您的本地设备中。\n\n(b) 语音数据：当您使用语音输入功能时，我们会临时采集您的语音信息用于语音识别转文字。语音数据仅在识别过程中使用，不会被永久存储。\n\n(c) 图片数据：当您使用图片相关功能时，我们会访问您的相机或相册以获取图片。图片数据存储在本地设备中。';

  @override
  String get privacySection1_2Title => '1.2 我们自动收集的信息';

  @override
  String get privacySection1_2Content =>
      '(a) 设备信息：包括设备型号、操作系统版本、设备标识符等，用于保障应用的正常运行和优化用户体验。\n\n(b) 应用使用信息：包括功能使用频率、错误日志等匿名数据，用于改善应用性能和服务质量。\n\n(c) 购买记录：当您进行应用内购买时，我们会记录购买状态以提供相应的付费功能服务。支付过程由 Apple App Store 或 Google Play 处理，我们不会收集您的支付账户信息。';

  @override
  String get privacySection1_3Title => '1.3 AI 功能相关信息';

  @override
  String get privacySection1_3Content =>
      '当您使用 AI 智能助手功能时，您主动发送给 AI 的笔记内容或对话信息可能会被传输至安全的云端服务器进行处理。我们仅在提供 AI 服务所必需的范围内使用这些数据，不会将其用于其他目的。';

  @override
  String get privacySection2Title => '二、信息的使用';

  @override
  String get privacySection2Content =>
      '我们收集的信息将用于以下目的：\n\n(a) 提供核心服务：笔记创建与管理、语音输入转文字、提醒通知等基础功能。\n\n(b) AI 智能服务：基于您的笔记内容提供智能总结、分析和问答服务。\n\n(c) 服务优化：分析匿名使用数据以改善应用性能、修复问题和优化功能体验。\n\n(d) 安全保障：检测和防范安全风险，保护您的数据安全。\n\n(e) 通知服务：在您设置的时间发送提醒通知。';

  @override
  String get privacySection3Title => '三、信息的存储';

  @override
  String get privacySection3_1Title => '3.1 存储位置';

  @override
  String get privacySection3_1Content =>
      '您的笔记数据主要存储在您的本地设备中（使用 SQLite 数据库）。当您使用 AI 功能时，相关数据可能会临时传输至云端服务器处理，处理完成后不会在服务端永久保存。';

  @override
  String get privacySection3_2Title => '3.2 存储期限';

  @override
  String get privacySection3_2Content =>
      '我们仅在为实现目的所必需的时间内保留您的个人信息。当您删除笔记或卸载应用后，您的本地数据将被相应删除。云端临时处理的数据将在处理完成后及时清除。';

  @override
  String get privacySection3_3Title => '3.3 数据安全';

  @override
  String get privacySection3_3Content =>
      '我们采取以下措施保护您的信息安全：\n\n(a) 使用安全的本地存储方案（如 Flutter Secure Storage）保护敏感数据。\n\n(b) 与云端服务器的数据传输采用 HTTPS 加密协议。\n\n(c) 严格限制数据访问权限，仅在必要时访问您的数据。';

  @override
  String get privacySection4Title => '四、信息的共享';

  @override
  String get privacySection4Content =>
      '我们承诺不会将您的个人信息出售给任何第三方。在以下情况下，我们可能会共享您的信息：\n\n(a) 经您明确同意后共享。\n\n(b) 为提供 AI 服务，将必要数据传输至 AI 服务提供商进行处理。我们要求 AI 服务提供商严格遵守数据保护协议。\n\n(c) 根据法律法规、法律程序或政府机关的强制性要求。\n\n(d) 为保护我们的用户、公众或我们的合法权益所合理必需。';

  @override
  String get privacySection5Title => '五、您的权利';

  @override
  String get privacySection5Content =>
      '您对自己的个人信息享有以下权利：\n\n(a) 访问权：您可以随时查看和访问您在应用中的所有数据。\n\n(b) 更正权：您可以随时编辑和修改您的笔记内容。\n\n(c) 删除权：您可以随时删除您的笔记、笔记本或其他数据。卸载应用将删除所有本地数据。\n\n(d) 权限管理：您可以在设备设置中随时开启或关闭我们请求的权限（如麦克风、相机、相册、通知等）。关闭权限可能影响相关功能的使用。';

  @override
  String get privacySection6Title => '六、设备权限说明';

  @override
  String get privacySection6Content =>
      '本应用可能请求以下设备权限：\n\n(a) 麦克风权限：用于语音输入功能，将您的语音转换为文字。\n\n(b) 相机/相册权限：用于拍照或选取图片功能。\n\n(c) 通知权限：用于发送您设置的提醒通知。\n\n以上权限均为可选权限，仅在您使用对应功能时才会请求，且您可以随时在系统设置中关闭。';

  @override
  String get privacySection7Title => '七、未成年人保护';

  @override
  String get privacySection7Content =>
      '我们高度重视未成年人的个人信息保护。如果您是未满 14 周岁的未成年人，请在法定监护人的陪同和指导下阅读本隐私政策，并在取得监护人同意后使用本应用。';

  @override
  String get privacySection8Title => '八、隐私政策的更新';

  @override
  String get privacySection8Content =>
      '我们可能会不时更新本隐私政策。更新后的政策将在应用内以适当方式通知您。若更新涉及重大变更（如收集信息范围扩大），我们将以弹窗或其他显著方式再次征求您的同意。';

  @override
  String get privacySection9Title => '九、联系我们';

  @override
  String get privacySection9Content =>
      '如您对本隐私政策有任何疑问、意见或建议，或者您需要行使个人信息相关权利，请通过以下方式联系我们：\n\n应用名称：妙记\n邮箱：privacy@miaoji.app\n\n我们将在收到您的请求后 15 个工作日内予以回复。';

  @override
  String get userAgreementHeader => '妙记用户服务协议';

  @override
  String get userAgreementUpdatedAt => '更新日期：2026年2月9日';

  @override
  String get userAgreementEffectiveAt => '生效日期：2026年2月9日';

  @override
  String get userAgreementIntro =>
      '欢迎您使用\"妙记\"应用程序（以下简称\"本应用\"）。请您在使用本应用之前，仔细阅读并充分理解本协议的全部内容。如果您不同意本协议的任何条款，请勿使用本应用。您一旦开始使用本应用，即表示您已充分理解并同意本协议。';

  @override
  String get userAgreementSection1Title => '一、服务说明';

  @override
  String get userAgreementSection1Content1 =>
      '1.1 本应用是一款智能笔记管理工具，为用户提供笔记本创建与管理、文字记录、语音输入、AI 智能助手、提醒通知等功能服务（以下简称\"本服务\"）。';

  @override
  String get userAgreementSection1Content2 =>
      '1.2 本应用提供的服务内容可能会随版本更新而发生变化。我们保留随时修改、中断或终止部分或全部服务的权利，并将尽合理努力提前通知用户。';

  @override
  String get userAgreementSection1Content3 =>
      '1.3 您理解并同意，本应用可能包含免费功能和付费功能。付费功能将通过应用内购买（In-App Purchase）方式提供，具体内容和价格以应用内展示为准。';

  @override
  String get userAgreementSection2Title => '二、账号与使用规范';

  @override
  String get userAgreementSection2Content1 =>
      '2.1 您在使用本应用时应遵守中华人民共和国相关法律法规，不得利用本应用从事任何违法违规活动。';

  @override
  String get userAgreementSection2Content2 =>
      '2.2 您应妥善保管设备及应用数据。因您个人原因导致的数据丢失、泄露等后果，由您自行承担。';

  @override
  String get userAgreementSection2Content3 =>
      '2.3 您不得利用本应用进行以下行为：\n  (a) 发布、传播违法、有害、威胁、侮辱、诽谤、色情或其他不当内容；\n  (b) 侵犯他人知识产权、隐私权或其他合法权益；\n  (c) 对本应用进行反向工程、反编译、反汇编或以其他方式试图获取源代码；\n  (d) 干扰或破坏本应用的正常运行，包括但不限于传播病毒、恶意代码等；\n  (e) 其他违反法律法规或本协议的行为。';

  @override
  String get userAgreementSection3Title => '三、知识产权';

  @override
  String get userAgreementSection3Content1 =>
      '3.1 本应用的所有内容，包括但不限于界面设计、程序代码、文字、图片、图标、音频等，均受中华人民共和国著作权法及国际著作权条约的保护，其知识产权归本应用开发者所有。';

  @override
  String get userAgreementSection3Content2 =>
      '3.2 您在本应用中创建的笔记内容、录入的数据等用户生成内容，其知识产权归您所有。但您授权本应用在提供服务所必需的范围内使用这些内容（例如 AI 助手分析您的笔记以提供智能建议）。';

  @override
  String get userAgreementSection3Content3 =>
      '3.3 未经本应用开发者书面许可，您不得以任何形式复制、传播、展示、镜像或以其他方式使用本应用的任何内容。';

  @override
  String get userAgreementSection4Title => '四、AI 服务条款';

  @override
  String get userAgreementSection4Content1 =>
      '4.1 本应用提供 AI 智能助手功能，可协助您进行笔记总结、内容分析、智能问答等操作。AI 生成的内容仅供参考，不构成任何专业建议。';

  @override
  String get userAgreementSection4Content2 =>
      '4.2 您理解并同意，AI 功能的回答可能存在不准确、不完整或不及时的情况，您应自行判断和验证 AI 提供的信息。因使用 AI 生成内容而导致的任何损失，本应用不承担责任。';

  @override
  String get userAgreementSection4Content3 =>
      '4.3 为提供 AI 服务，本应用可能需要将您的部分笔记内容发送至安全的云端服务器进行处理。我们将采取严格的数据安全措施保护您的信息，详情请参阅《隐私政策》。';

  @override
  String get userAgreementSection5Title => '五、付费服务';

  @override
  String get userAgreementSection5Content1 =>
      '5.1 本应用部分功能为付费功能，通过 Apple App Store 或 Google Play 的应用内购买机制提供。付费前请仔细确认购买内容和价格。';

  @override
  String get userAgreementSection5Content2 =>
      '5.2 付费成功后，相关功能将立即开通。除法律另有规定外，已完成的购买不支持退款。如需退款，请联系对应应用商店的客服。';

  @override
  String get userAgreementSection5Content3 =>
      '5.3 订阅类服务将按周期自动续费，您可在应用商店的订阅管理中随时取消自动续费。取消后，当前订阅周期内的服务不受影响。';

  @override
  String get userAgreementSection6Title => '六、免责声明';

  @override
  String get userAgreementSection6Content1 =>
      '6.1 本应用按\"现状\"提供服务，不对服务的及时性、安全性、准确性作出任何明示或暗示的保证。';

  @override
  String get userAgreementSection6Content2 =>
      '6.2 因不可抗力、系统维护、网络故障、设备故障等原因导致服务中断或数据丢失的，本应用不承担责任，但将尽合理努力减少对您的影响。';

  @override
  String get userAgreementSection6Content3 =>
      '6.3 您的笔记数据存储在本地设备中。我们建议您定期备份重要数据。因设备损坏、系统重置等导致的数据丢失，本应用不承担责任。';

  @override
  String get userAgreementSection7Title => '七、协议变更';

  @override
  String get userAgreementSection7Content1 =>
      '7.1 我们有权根据需要修改本协议的内容。协议变更后，我们将在应用内以适当方式通知您。';

  @override
  String get userAgreementSection7Content2 =>
      '7.2 如您不同意修改后的协议，您有权停止使用本服务。如您在协议修改后继续使用本服务，则视为您已接受修改后的协议。';

  @override
  String get userAgreementSection8Title => '八、法律适用与争议解决';

  @override
  String get userAgreementSection8Content1 =>
      '8.1 本协议的解释、效力和执行均适用中华人民共和国法律（不包括冲突法规则）。';

  @override
  String get userAgreementSection8Content2 =>
      '8.2 因本协议引起的或与本协议有关的任何争议，双方应首先通过友好协商解决。协商不成的，任何一方均可向本应用开发者所在地有管辖权的人民法院提起诉讼。';

  @override
  String get userAgreementSection9Title => '九、联系我们';

  @override
  String get userAgreementSection9Content =>
      '如您对本协议有任何疑问或建议，请通过以下方式联系我们：\n\n应用名称：妙记\n邮箱：support@miaoji.app\n\n感谢您选择妙记，祝您使用愉快！';

  @override
  String get homeTitle => '妙记';

  @override
  String get notebookSection => '妙记本';

  @override
  String notebookCount(num count) {
    return '$count 个';
  }

  @override
  String viewAllNotebooks(num count) {
    return '查看全部 $count 个妙记本';
  }

  @override
  String get aiWeeklyTitle => '每日一语';

  @override
  String get aiWeeklyCardLabel => '致亲爱的自己';

  @override
  String aiWeeklyBasedOnDays(num days) {
    return '基于近 $days 天数据';
  }

  @override
  String get aiWeeklyGenerating => '正在生成每日一语…';

  @override
  String get aiWeeklyEmpty => '暂无数据，记录更多数据后自动生成';

  @override
  String get aiWeeklyStreaming => '生成中…';

  @override
  String get upcomingRemindersTitle => '近期提醒';

  @override
  String get checkinTitle => '签到';

  @override
  String get checkinAction => '去签到';

  @override
  String get checkinDone => '今日已签到';

  @override
  String get checkinSuccessFallback => '签到成功';

  @override
  String get checkinFailedFallback => '签到失败，请稍后重试';

  @override
  String reminderCount(num count) {
    return '$count 项';
  }

  @override
  String moreReminders(num count) {
    return '还有 $count 项提醒…';
  }

  @override
  String reminderInDays(num count) {
    return '$count 天后';
  }

  @override
  String reminderInHours(num count) {
    return '$count 小时后';
  }

  @override
  String reminderInMinutes(num count) {
    return '$count 分钟后';
  }

  @override
  String get reminderSoon => '即将到来';

  @override
  String get featureAiCreateTitle => 'AI 智能创建';

  @override
  String get featureAiCreateDesc => '告诉 AI 你想记录什么，自动生成小本';

  @override
  String get featureReminderTitle => '智能提醒';

  @override
  String get featureReminderDesc => '为记录设置提醒，不再遗忘重要事项';

  @override
  String get featureAnalyticsTitle => '数据统计';

  @override
  String get featureAnalyticsDesc => '自动生成趋势图、饼图等可视化分析';

  @override
  String get featureGuideTitle => '欢迎使用妙记';

  @override
  String get featureGuideSubtitle => '点击底部「助理」标签，让 AI 帮你创建第一个小本吧';

  @override
  String get emptyNotebooksTitle => '还没有小本';

  @override
  String get emptyNotebooksHint => '试试和 AI 助手说「帮我创建一个读书记录小本」';

  @override
  String get allNotebooksTitle => '全部妙记本';

  @override
  String get emptyAllNotebooks => '还没有妙记本';

  @override
  String get searchHint => '搜索记录内容…';

  @override
  String get searchEmptyHint => '输入关键词搜索所有记录';

  @override
  String get searchNoResultsTitle => '没有找到相关记录';

  @override
  String get searchNoResultsHint => '换个关键词试试';

  @override
  String searchRecordCount(num count) {
    return '$count 条';
  }

  @override
  String searchMoreFields(num count) {
    return '还有 $count 个字段…';
  }

  @override
  String recordCount(num count) {
    return '$count 条';
  }

  @override
  String get alarmSoundTitle => '提醒铃声';

  @override
  String get alarmSoundDefaultName => '系统默认';

  @override
  String get alarmSoundDefaultDesc => '使用系统默认通知声音';

  @override
  String get alarmSoundClassicName => '经典闹钟';

  @override
  String get alarmSoundClassicDesc => '嘟-嘟…嘟-嘟… 经典双音闹钟';

  @override
  String get alarmSoundRadarName => '雷达';

  @override
  String get alarmSoundRadarDesc => '嘟嘟嘟…嘟嘟嘟… 快速脉冲';

  @override
  String get alarmSoundBeaconName => '灯塔';

  @override
  String get alarmSoundBeaconDesc => '低-高…低-高… 交替升调';

  @override
  String get alarmSoundChimeName => '钟琴';

  @override
  String get alarmSoundChimeDesc => '叮…叮…叮… 悠扬清脆';

  @override
  String get alarmSoundPulseName => '脉冲';

  @override
  String get alarmSoundPulseDesc => '嘟嘟-嗡…嘟嘟-嗡… 紧迫节奏';

  @override
  String get notificationSoundPreviewTitle => '🔔 铃声预览';

  @override
  String get notificationChannelName => '小本闹钟提醒';

  @override
  String get notificationChannelDescription => '小本记录的闹钟式定时提醒，会持续响铃直到处理';

  @override
  String notificationReminderTitle(Object notebookName) {
    return '📝 $notebookName';
  }

  @override
  String get notificationFallbackBody => '你有一条待办提醒';

  @override
  String get aiImageSourceCamera => '拍照';

  @override
  String get aiImageSourceGallery => '图库';

  @override
  String aiErrorMessage(Object message) {
    return '抱歉，出错了：$message';
  }

  @override
  String aiRequestFailed(Object error) {
    return '请求失败：$error';
  }

  @override
  String get aiAssistantTitle => 'AI 助手';

  @override
  String get aiAssistantWriting => '正在书写...';

  @override
  String get aiAssistantReady => '随时准备帮助你';

  @override
  String get aiEmptyTitle => '开始和 AI 对话吧';

  @override
  String get aiEmptyHint => '试试说「我要创建一个读书记录小本」';

  @override
  String get chatInputListeningHint => '正在聆听...';

  @override
  String get chatInputPlaceholder => '写点什么...';

  @override
  String get chatInputSpeechUnavailable => '语音输入不可用，请检查麦克风权限';

  @override
  String get recordAddedSuccess => '记录添加成功';

  @override
  String get recordUpdatedSuccess => '记录更新成功';

  @override
  String get notebookCreatedSuccess => '小本创建成功';

  @override
  String get notebookUpdatedSuccess => '小本更新成功';

  @override
  String notebookUpdatedFields(num count, Object fields) {
    return '更新后包含 $count 个字段：$fields';
  }

  @override
  String get notebookDeletedSuccess => '小本已删除';

  @override
  String notebookDeletedName(Object name) {
    return '已删除「$name」';
  }

  @override
  String get notebookDeletedDesc => '小本及其所有记录已被移除';

  @override
  String recordMoreFields(num count) {
    return '还有 $count 个字段...';
  }

  @override
  String recordReminderLabel(Object time) {
    return '提醒：$time';
  }

  @override
  String get reminderExpired => '已过期';

  @override
  String get recordDeletedSuccess => '记录已删除';

  @override
  String recordDeletedFromNotebook(Object name) {
    return '已删除「$name」记录';
  }

  @override
  String get recordDeleted => '已删除记录';

  @override
  String recordIdLabel(Object id) {
    return 'ID: $id';
  }

  @override
  String queryResultsCount(num count) {
    return '查询到 $count 条记录';
  }

  @override
  String get queryNoResults => '没有找到匹配的记录';

  @override
  String toolResultSuccess(Object tool) {
    return '$tool 执行成功';
  }

  @override
  String toolResultFailure(Object tool) {
    return '$tool 执行失败';
  }

  @override
  String get listSeparator => '、';

  @override
  String get aiAssistantCardTitle => '创建新的记录本';

  @override
  String get aiAssistantCardDesc => '描述你想记录的内容，让 AI 帮你自动构建数据结构';

  @override
  String aiServerError(Object status, Object details) {
    return '服务器错误（$status）：$details';
  }

  @override
  String aiConnectionError(Object message) {
    return '无法连接到服务器：$message';
  }

  @override
  String aiHttpError(Object message) {
    return 'HTTP 错误：$message';
  }

  @override
  String aiRequestFailedError(Object error) {
    return '请求失败：$error';
  }

  @override
  String get summaryPromptHeader => '以下是我近 1 天的记录数据：';

  @override
  String summaryNewNotebooks(Object count) {
    return '## 新建小本（$count 个）';
  }

  @override
  String summaryNotebookItem(Object name, Object fields) {
    return '- $name（$fields）';
  }

  @override
  String summaryNewRecords(Object count) {
    return '## 新增记录（共 $count 条）';
  }

  @override
  String summaryNotebookGroup(Object name, Object count) {
    return '### $name（$count 条）';
  }

  @override
  String summaryRecordItem(Object summary) {
    return '- $summary';
  }

  @override
  String summaryMoreRecords(Object count) {
    return '- …还有 $count 条';
  }

  @override
  String summaryAllNotebooks(Object count) {
    return '## 我的所有小本（$count 个）';
  }

  @override
  String summaryAllNotebookItem(Object name, Object description) {
    return '- $name：$description';
  }

  @override
  String get summaryNoDescription => '无描述';

  @override
  String get summaryItemSeparator => '，';

  @override
  String notebookFieldCount(num count) {
    return '$count 个字段';
  }

  @override
  String get refreshDrag => '下拉刷新';

  @override
  String get refreshArmed => '松手刷新';

  @override
  String get refreshReady => '松手刷新';

  @override
  String get refreshProcessing => '刷新中';

  @override
  String get refreshProcessed => '刷新完成';

  @override
  String get refreshFailed => '刷新失败';

  @override
  String get profileTitle => '我的';

  @override
  String get notificationDisabledTitle => '通知未开启';

  @override
  String get notificationDisabledDesc => '开启通知以接收重要提醒，不错过每一条待办';

  @override
  String get notificationDisabledAction => '去开启';

  @override
  String get balanceTitle => '剩余次数';

  @override
  String balanceCount(Object count) {
    return '$count 次';
  }

  @override
  String get purchaseRecharge => '充值';

  @override
  String get restorePurchasesTitle => '内购恢复';

  @override
  String get notificationSoundSetting => '通知铃声';

  @override
  String get assistantPersonaSetting => '助手性格';

  @override
  String get assistantPersonaDescription => '设置 AI 助手的人设风格';

  @override
  String get assistantPersonaTitle => '助手性格设置';

  @override
  String get assistantPersonaHint => '例如：你是一个温柔且简洁的记录助手，回答时先鼓励用户，再给出清晰步骤。';

  @override
  String get assistantPersonaSaved => '助手性格已保存';

  @override
  String purchaseFailed(Object message) {
    return '购买失败：$message';
  }

  @override
  String get unknownError => '未知错误';

  @override
  String rechargeSuccess(num amount) {
    return '充值成功！已到账 $amount 次';
  }

  @override
  String get rechargeVerifyFailed => '充值验证失败，请联系客服';

  @override
  String get ticketInitializing => 'Ticket 初始化中，请稍后再试';

  @override
  String get ticketImportSuccess => '导入成功！';

  @override
  String get ticketInvalid => '无效的 Ticket';

  @override
  String get ticketCopied => 'Ticket 已复制到剪贴板';

  @override
  String get restorePurchasesDesc => '更换设备时，可导出当前 Ticket 并在新设备导入来恢复购买的次数。';

  @override
  String get ticketExportTitle => '导出 Ticket';

  @override
  String get loadingShort => '加载中…';

  @override
  String get ticketImportTitle => '导入 Ticket';

  @override
  String get ticketPasteHint => '粘贴 Ticket ID';

  @override
  String get ticketImportAction => '导入';

  @override
  String get purchaseSheetTitle => '充值次卡';

  @override
  String get purchaseProcessing => '处理中…';

  @override
  String get purchaseTimesUnit => '次';

  @override
  String get purchaseRecommended => '推荐';

  @override
  String purchaseUnitPrice(Object price) {
    return '约 $price 元/次';
  }

  @override
  String get schemaAddAtLeastOneField => '请至少添加一个数据字段';

  @override
  String get fieldNameRequired => '字段名称不能为空';

  @override
  String get notebookSaved => '小本已保存';

  @override
  String saveFailed(Object error) {
    return '保存失败：$error';
  }

  @override
  String get notebookUpdated => '小本已更新';

  @override
  String updateFailed(Object error) {
    return '更新失败：$error';
  }

  @override
  String get editNotebookTitle => '编辑小本';

  @override
  String get createNotebookTitle => '新建小本';

  @override
  String get saveAction => '保存';

  @override
  String get doneAction => '完成';

  @override
  String get appearanceSectionTitle => '外观';

  @override
  String get colorLabel => '颜色';

  @override
  String get iconLabel => '图标';

  @override
  String get basicInfoSectionTitle => '基本信息';

  @override
  String get notebookNameLabel => '小本名称';

  @override
  String get notebookNameHint => '例如：日常账单';

  @override
  String get notebookNameRequired => '请输入名称';

  @override
  String get notebookDescLabel => '描述';

  @override
  String get notebookDescHint => '写点什么来描述这个小本...';

  @override
  String get schemaSectionTitle => '数据结构';

  @override
  String get addFieldAction => '添加字段';

  @override
  String get schemaEmptyTitle => '还没有定义数据结构';

  @override
  String get schemaEmptyHint => '点击上方\"添加字段\"开始设计';

  @override
  String get fieldNameLabel => '字段名称';

  @override
  String get fieldDescHint => '可选：字段描述';

  @override
  String get recordEmptyContent => '暂无内容';

  @override
  String get backAction => '返回';

  @override
  String get confirmDeleteTitle => '确认删除';

  @override
  String get confirmDeleteRecordContent => '删除后无法恢复，确定要删除这条记录吗？';

  @override
  String get cancelAction => '取消';

  @override
  String get deleteAction => '删除';

  @override
  String get recordListTitle => '记录列表';

  @override
  String get noRecordsTitle => '暂无记录';

  @override
  String noRecordsHint(Object notebook) {
    return '试试和 AI 助手说「帮我记一笔 $notebook」';
  }

  @override
  String get reminderSentLabel => '已提醒';

  @override
  String get reminderExpiredLabel => '已过期';

  @override
  String get reminderTimeLabel => '提醒时间';

  @override
  String get reminderEditAction => '修改提醒时间';

  @override
  String get reminderCancelAction => '取消提醒';

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String get timeJustNow => '刚刚';

  @override
  String timeMinutesAgo(num count) {
    return '$count 分钟前';
  }

  @override
  String timeHoursAgo(num count) {
    return '$count 小时前';
  }

  @override
  String timeDaysAgo(num count) {
    return '$count 天前';
  }

  @override
  String get fieldNumberHint => '输入数字...';

  @override
  String get fieldMarkdownHint => '支持 Markdown 语法...';

  @override
  String get statsTitle => '数据统计';

  @override
  String filteredRecordsCount(Object filtered, Object total) {
    return '$filtered / $total 条';
  }

  @override
  String get clearAction => '清除';

  @override
  String get allOption => '全部';

  @override
  String validValueCount(num count) {
    return '$count 个有效值';
  }

  @override
  String get metricSum => '总和';

  @override
  String get metricAverage => '平均值';

  @override
  String get metricMax => '最大值';

  @override
  String get metricMin => '最小值';

  @override
  String get trendLabel => '趋势';

  @override
  String get trendInsufficientForGranularity => '该粒度下数据不足';

  @override
  String get trendInsufficientData => '数据不足，至少需要 2 条记录才能生成趋势图';

  @override
  String get noData => '暂无数据';

  @override
  String get distributionLabel => '分布';

  @override
  String get noDistributionData => '暂无分布数据';

  @override
  String get granularityDay => '日';

  @override
  String get granularityWeek => '周';

  @override
  String get granularityMonth => '月';

  @override
  String get createdTimeLabel => '创建时间';

  @override
  String get axisLabel => '横轴';

  @override
  String get otherLabel => '其他';

  @override
  String get fieldTypeText => '文本';

  @override
  String get fieldTypeNumber => '数字';

  @override
  String get fieldTypeDate => '日期';

  @override
  String get unnamedNotebook => '未命名小本';
}
