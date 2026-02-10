// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Miaoji';

  @override
  String get navHome => 'Home';

  @override
  String get navAssistant => 'Miaoji';

  @override
  String get navProfile => 'Me';

  @override
  String get onboardingTitle1 => 'Welcome to Miaoji';

  @override
  String get onboardingSubtitle1 => 'Your intelligent note companion';

  @override
  String get onboardingDesc1 =>
      'Miaoji helps you easily manage every important detail in life,\nso recording becomes simple, organized, and warm.';

  @override
  String get onboardingTitle2 => 'AI Assistant';

  @override
  String get onboardingSubtitle2 => 'Understands you, records what you need';

  @override
  String get onboardingDesc2 =>
      'Built-in AI assistant supports voice input, smart summaries,\ncontent analysis, making your notes smarter and more efficient.';

  @override
  String get onboardingTitle3 => 'Thoughtful Reminders';

  @override
  String get onboardingSubtitle3 => 'Never forget what matters';

  @override
  String get onboardingDesc3 =>
      'Flexible reminders for each note,\nso you never miss an important moment.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingAgreementPrefix =>
      'By tapping \"Agree and Start\", you have read and agree to';

  @override
  String get onboardingAgreementUserAgreement => 'User Service Agreement';

  @override
  String get onboardingAgreementAnd => 'and';

  @override
  String get onboardingAgreementPrivacyPolicy => 'Privacy Policy';

  @override
  String get onboardingAgreeAndStart => 'Agree and Start';

  @override
  String get aboutTitle => 'About';

  @override
  String aboutVersionInfo(Object version, Object build) {
    return 'Version $version ($build)';
  }

  @override
  String get aboutVersionLoading => 'Loading...';

  @override
  String get appTagline => 'Your intelligent note companion';

  @override
  String get userAgreementTitle => 'User Service Agreement';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String aboutCopyright(Object year) {
    return 'Miaoji © $year';
  }

  @override
  String get aboutIcp => 'ICP Filing No.: Jing ICP XXXXXXXX-X';

  @override
  String get aboutSupportEmail => 'Support Email: support@miaoji.app';

  @override
  String get privacyPolicyHeader => 'Miaoji Privacy Policy';

  @override
  String get privacyPolicyUpdatedAt => 'Updated: Feb 9, 2026';

  @override
  String get privacyPolicyEffectiveAt => 'Effective: Feb 9, 2026';

  @override
  String get privacyPolicyIntro1 =>
      'Miaoji (\"we\") understands the importance of your personal information and will do our best to keep it secure and reliable. We are committed to maintaining your trust and follow these principles: accountability, purpose limitation, consent, data minimization, security, participation, and transparency.';

  @override
  String get privacyPolicyIntro2 =>
      'This Privacy Policy explains how we collect, use, store, share, and protect your personal information, and how you can manage it. Please read it carefully before using this app.';

  @override
  String get privacySection1Title => '1. Information We Collect';

  @override
  String get privacySection1_1Title => '1.1 Information You Provide';

  @override
  String get privacySection1_1Content =>
      '(a) Note content: notebooks you create, text records, category tags, etc. These data are mainly stored on your device.\n\n(b) Voice data: when you use voice input, we temporarily capture your voice for speech-to-text. Voice data is used only during recognition and is not stored permanently.\n\n(c) Image data: when you use image-related features, we access your camera or photo library to obtain images. Images are stored on your device.';

  @override
  String get privacySection1_2Title =>
      '1.2 Information We Collect Automatically';

  @override
  String get privacySection1_2Content =>
      '(a) Device info: device model, OS version, device identifiers, etc., to ensure normal operation and improve experience.\n\n(b) App usage info: feature usage frequency, error logs, and other anonymous data, used to improve performance and service quality.\n\n(c) Purchase records: when you make in-app purchases, we record purchase status to provide paid features. Payments are processed by Apple App Store or Google Play; we do not collect your payment account information.';

  @override
  String get privacySection1_3Title => '1.3 AI-Related Information';

  @override
  String get privacySection1_3Content =>
      'When you use the AI assistant, notes or conversation content you send to AI may be transmitted to secure cloud servers for processing. We use this data only as necessary to provide AI services and do not use it for other purposes.';

  @override
  String get privacySection2Title => '2. How We Use Information';

  @override
  String get privacySection2Content =>
      'We use the collected information for:\n\n(a) Core services: note creation and management, speech-to-text, reminders, etc.\n\n(b) AI services: summaries, analysis, and Q&A based on your notes.\n\n(c) Service improvement: analyze anonymous usage data to improve performance, fix issues, and optimize experience.\n\n(d) Security: detect and prevent security risks to protect your data.\n\n(e) Notifications: send reminders at the times you set.';

  @override
  String get privacySection3Title => '3. Storage of Information';

  @override
  String get privacySection3_1Title => '3.1 Storage Location';

  @override
  String get privacySection3_1Content =>
      'Your note data is mainly stored on your device (SQLite). When you use AI features, related data may be temporarily transmitted to cloud servers for processing and will not be permanently stored on the server after processing.';

  @override
  String get privacySection3_2Title => '3.2 Retention Period';

  @override
  String get privacySection3_2Content =>
      'We retain your personal information only as long as necessary. When you delete notes or uninstall the app, local data is deleted. Temporarily processed cloud data is cleared promptly after processing.';

  @override
  String get privacySection3_3Title => '3.3 Data Security';

  @override
  String get privacySection3_3Content =>
      'We take the following measures to protect your information:\n\n(a) Use secure local storage (e.g., Flutter Secure Storage) for sensitive data.\n\n(b) Use HTTPS encryption for data transmission to cloud servers.\n\n(c) Strictly limit data access and only access your data when necessary.';

  @override
  String get privacySection4Title => '4. Information Sharing';

  @override
  String get privacySection4Content =>
      'We will not sell your personal information to any third party. We may share your information in the following cases:\n\n(a) With your explicit consent.\n\n(b) To provide AI services, necessary data may be sent to AI service providers for processing. We require them to comply with data protection agreements.\n\n(c) As required by laws, legal processes, or government requests.\n\n(d) As reasonably necessary to protect our users, the public, or our legitimate rights and interests.';

  @override
  String get privacySection5Title => '5. Your Rights';

  @override
  String get privacySection5Content =>
      'You have the following rights regarding your personal information:\n\n(a) Access: view and access all your data in the app at any time.\n\n(b) Correction: edit and modify your notes at any time.\n\n(c) Deletion: delete your notes, notebooks, or other data at any time. Uninstalling the app will delete all local data.\n\n(d) Permission management: enable or disable permissions we request in device settings (e.g., microphone, camera, photo library, notifications). Disabling permissions may affect related features.';

  @override
  String get privacySection6Title => '6. Device Permissions';

  @override
  String get privacySection6Content =>
      'This app may request the following device permissions:\n\n(a) Microphone: for voice input and speech-to-text.\n\n(b) Camera/Photo Library: for taking or selecting images.\n\n(c) Notifications: to send the reminders you set.\n\nAll permissions are optional, requested only when you use the relevant feature, and can be turned off anytime in system settings.';

  @override
  String get privacySection7Title => '7. Protection of Minors';

  @override
  String get privacySection7Content =>
      'We place high importance on protecting minors\' personal information. If you are under 14, please read this policy with a guardian and use the app only with their consent.';

  @override
  String get privacySection8Title => '8. Updates to This Policy';

  @override
  String get privacySection8Content =>
      'We may update this policy from time to time. Updated policies will be announced in the app in an appropriate manner. If there are significant changes (e.g., expanded data collection scope), we will request your consent again via pop-up or other prominent methods.';

  @override
  String get privacySection9Title => '9. Contact Us';

  @override
  String get privacySection9Content =>
      'If you have any questions, comments, or suggestions about this policy, or need to exercise your rights, contact us:\n\nApp name: Miaoji\nEmail: privacy@miaoji.app\n\nWe will respond within 15 business days.';

  @override
  String get userAgreementHeader => 'Miaoji User Service Agreement';

  @override
  String get userAgreementUpdatedAt => 'Updated: Feb 9, 2026';

  @override
  String get userAgreementEffectiveAt => 'Effective: Feb 9, 2026';

  @override
  String get userAgreementIntro =>
      'Welcome to the \"Miaoji\" app (the \"App\"). Please read and fully understand this Agreement before using it. If you do not agree to any terms, do not use the App. Once you start using the App, you indicate that you have understood and agreed to this Agreement.';

  @override
  String get userAgreementSection1Title => '1. Service Description';

  @override
  String get userAgreementSection1Content1 =>
      '1.1 This App is an intelligent note management tool that provides notebook creation and management, text records, voice input, AI assistant, reminders, and other services (the \"Services\").';

  @override
  String get userAgreementSection1Content2 =>
      '1.2 The Services may change with version updates. We reserve the right to modify, suspend, or terminate some or all Services at any time, and will make reasonable efforts to notify users in advance.';

  @override
  String get userAgreementSection1Content3 =>
      '1.3 You understand and agree that the App may include free and paid features. Paid features are provided via in-app purchases; specific content and prices are as shown in the app.';

  @override
  String get userAgreementSection2Title => '2. Account and Usage Rules';

  @override
  String get userAgreementSection2Content1 =>
      '2.1 When using the App, you must comply with the laws and regulations of the People\'s Republic of China and must not use the App for any illegal activities.';

  @override
  String get userAgreementSection2Content2 =>
      '2.2 You should properly keep your device and app data. Any loss or leakage caused by your own reasons shall be borne by you.';

  @override
  String get userAgreementSection2Content3 =>
      '2.3 You must not use the App to:\n  (a) publish or spread illegal, harmful, threatening, insulting, defamatory, pornographic, or other improper content;\n  (b) infringe intellectual property, privacy, or other lawful rights of others;\n  (c) reverse engineer, decompile, disassemble, or otherwise attempt to obtain source code;\n  (d) interfere with or disrupt normal operation, including spreading viruses or malicious code;\n  (e) other acts that violate laws or this Agreement.';

  @override
  String get userAgreementSection3Title => '3. Intellectual Property';

  @override
  String get userAgreementSection3Content1 =>
      '3.1 All content of the App, including interface design, code, text, images, icons, audio, etc., is protected by copyright laws and treaties, and the IP belongs to the developer.';

  @override
  String get userAgreementSection3Content2 =>
      '3.2 You own the IP of user-generated content such as notes and data you create. However, you authorize the App to use such content as necessary to provide services (e.g., AI assistant analyzing notes to provide suggestions).';

  @override
  String get userAgreementSection3Content3 =>
      '3.3 Without written permission from the developer, you may not copy, distribute, display, mirror, or otherwise use any content of the App.';

  @override
  String get userAgreementSection4Title => '4. AI Service Terms';

  @override
  String get userAgreementSection4Content1 =>
      '4.1 The App provides an AI assistant to help with summaries, content analysis, and Q&A. AI-generated content is for reference only and does not constitute professional advice.';

  @override
  String get userAgreementSection4Content2 =>
      '4.2 You understand that AI responses may be inaccurate, incomplete, or untimely; you should judge and verify information yourself. The App is not liable for losses arising from AI content.';

  @override
  String get userAgreementSection4Content3 =>
      '4.3 To provide AI services, the App may send some of your note content to secure cloud servers for processing. We will take strict security measures; see the Privacy Policy for details.';

  @override
  String get userAgreementSection5Title => '5. Paid Services';

  @override
  String get userAgreementSection5Content1 =>
      '5.1 Some features are paid and provided through in-app purchases via Apple App Store or Google Play. Please confirm content and price before purchase.';

  @override
  String get userAgreementSection5Content2 =>
      '5.2 After successful payment, features are enabled immediately. Except as required by law, completed purchases are non-refundable. For refunds, contact the relevant app store support.';

  @override
  String get userAgreementSection5Content3 =>
      '5.3 Subscription services auto-renew. You can cancel auto-renewal in the app store\'s subscription management. After cancellation, the service remains available for the current subscription period.';

  @override
  String get userAgreementSection6Title => '6. Disclaimer';

  @override
  String get userAgreementSection6Content1 =>
      '6.1 The App provides services \"as is\" and makes no express or implied warranties regarding timeliness, security, or accuracy.';

  @override
  String get userAgreementSection6Content2 =>
      '6.2 The App is not liable for interruptions or data loss caused by force majeure, system maintenance, network failures, device failures, etc., but will make reasonable efforts to minimize impact.';

  @override
  String get userAgreementSection6Content3 =>
      '6.3 Your note data is stored on your device. We recommend regular backups. The App is not liable for data loss due to device damage or system reset.';

  @override
  String get userAgreementSection7Title => '7. Changes to the Agreement';

  @override
  String get userAgreementSection7Content1 =>
      '7.1 We may modify this Agreement as needed and will notify you appropriately in the app.';

  @override
  String get userAgreementSection7Content2 =>
      '7.2 If you disagree with the modified Agreement, you may stop using the Services. Continued use after changes indicates acceptance.';

  @override
  String get userAgreementSection8Title =>
      '8. Governing Law and Dispute Resolution';

  @override
  String get userAgreementSection8Content1 =>
      '8.1 Interpretation, validity, and enforcement of this Agreement are governed by the laws of the People\'s Republic of China (excluding conflict of laws).';

  @override
  String get userAgreementSection8Content2 =>
      '8.2 Any dispute arising from or related to this Agreement shall first be resolved through friendly negotiation. If negotiation fails, either party may file a lawsuit in a court with jurisdiction where the developer is located.';

  @override
  String get userAgreementSection9Title => '9. Contact Us';

  @override
  String get userAgreementSection9Content =>
      'If you have any questions or suggestions about this Agreement, please contact us:\n\nApp name: Miaoji\nEmail: support@miaoji.app\n\nThank you for choosing Miaoji. Enjoy!';

  @override
  String get homeTitle => 'Miaoji Pocket';

  @override
  String get notebookSection => 'Notebooks';

  @override
  String notebookCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notebooks',
      one: '1 notebook',
      zero: '0 notebooks',
    );
    return '$_temp0';
  }

  @override
  String viewAllNotebooks(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notebooks',
      one: '1 notebook',
      zero: '0 notebooks',
    );
    return 'View all $_temp0';
  }

  @override
  String get aiWeeklyTitle => 'Daily Quote';

  @override
  String get aiWeeklyCardLabel => 'Dear Myself';

  @override
  String aiWeeklyBasedOnDays(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Based on last $days days of data',
      one: 'Based on last 1 day of data',
    );
    return '$_temp0';
  }

  @override
  String get aiWeeklyGenerating => 'Generating daily quote...';

  @override
  String get aiWeeklyEmpty =>
      'No data yet. Record more data to generate automatically.';

  @override
  String get aiWeeklyStreaming => 'Generating...';

  @override
  String get upcomingRemindersTitle => 'Upcoming Reminders';

  @override
  String get checkinTitle => 'Daily Check-in';

  @override
  String get checkinAction => 'Check in';

  @override
  String get checkinDone => 'Checked in today';

  @override
  String get checkinSuccessFallback => 'Check-in successful';

  @override
  String get checkinFailedFallback =>
      'Check-in failed. Please try again later.';

  @override
  String reminderCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reminders',
      one: '1 reminder',
      zero: '0 reminders',
    );
    return '$_temp0';
  }

  @override
  String moreReminders(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more reminders',
      one: '1 more reminder',
      zero: '0 more reminders',
    );
    return 'and $_temp0...';
  }

  @override
  String reminderInDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'in $count days',
      one: 'in 1 day',
    );
    return '$_temp0';
  }

  @override
  String reminderInHours(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'in $count hours',
      one: 'in 1 hour',
    );
    return '$_temp0';
  }

  @override
  String reminderInMinutes(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'in $count minutes',
      one: 'in 1 minute',
    );
    return '$_temp0';
  }

  @override
  String get reminderSoon => 'Coming soon';

  @override
  String get featureAiCreateTitle => 'AI Smart Create';

  @override
  String get featureAiCreateDesc =>
      'Tell AI what you want to record and it will create a notebook';

  @override
  String get featureReminderTitle => 'Smart Reminders';

  @override
  String get featureReminderDesc =>
      'Set reminders for records and never forget important things';

  @override
  String get featureAnalyticsTitle => 'Data Insights';

  @override
  String get featureAnalyticsDesc =>
      'Automatically generate trends, pie charts, and visual analysis';

  @override
  String get featureGuideTitle => 'Welcome to Miaoji Pocket';

  @override
  String get featureGuideSubtitle =>
      'Tap the \"Assistant\" tab below and let AI create your first notebook';

  @override
  String get emptyNotebooksTitle => 'No notebooks yet';

  @override
  String get emptyNotebooksHint =>
      'Try telling the AI assistant \"Create a reading log notebook\"';

  @override
  String get allNotebooksTitle => 'All Notebooks';

  @override
  String get emptyAllNotebooks => 'No notebooks yet';

  @override
  String get searchHint => 'Search records...';

  @override
  String get searchEmptyHint => 'Type keywords to search all records';

  @override
  String get searchNoResultsTitle => 'No matching records';

  @override
  String get searchNoResultsHint => 'Try a different keyword';

  @override
  String searchRecordCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count records',
      one: '1 record',
      zero: '0 records',
    );
    return '$_temp0';
  }

  @override
  String searchMoreFields(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more fields',
      one: '1 more field',
      zero: '0 more fields',
    );
    return 'and $_temp0...';
  }

  @override
  String recordCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count records',
      one: '1 record',
      zero: '0 records',
    );
    return '$_temp0';
  }

  @override
  String get alarmSoundTitle => 'Reminder Sound';

  @override
  String get alarmSoundDefaultName => 'System Default';

  @override
  String get alarmSoundDefaultDesc =>
      'Use the system default notification sound';

  @override
  String get alarmSoundClassicName => 'Classic Alarm';

  @override
  String get alarmSoundClassicDesc => 'Beep-beep... classic dual-tone alarm';

  @override
  String get alarmSoundRadarName => 'Radar';

  @override
  String get alarmSoundRadarDesc => 'Beep-beep-beep... fast pulses';

  @override
  String get alarmSoundBeaconName => 'Beacon';

  @override
  String get alarmSoundBeaconDesc => 'Low-high... alternating rising tones';

  @override
  String get alarmSoundChimeName => 'Chime';

  @override
  String get alarmSoundChimeDesc => 'Ding... ding... crisp chimes';

  @override
  String get alarmSoundPulseName => 'Pulse';

  @override
  String get alarmSoundPulseDesc => 'Beep-buzz... urgent rhythm';

  @override
  String get notificationSoundPreviewTitle => '🔔 Sound Preview';

  @override
  String get notificationChannelName => 'Notebook Alarm Reminder';

  @override
  String get notificationChannelDescription =>
      'Alarm-style reminders for notebook records that keep ringing until handled';

  @override
  String notificationReminderTitle(Object notebookName) {
    return '📝 $notebookName';
  }

  @override
  String get notificationFallbackBody => 'You have a pending reminder';

  @override
  String get aiImageSourceCamera => 'Camera';

  @override
  String get aiImageSourceGallery => 'Gallery';

  @override
  String aiErrorMessage(Object message) {
    return 'Sorry, an error occurred: $message';
  }

  @override
  String aiRequestFailed(Object error) {
    return 'Request failed: $error';
  }

  @override
  String get aiAssistantTitle => 'AI Assistant';

  @override
  String get aiAssistantWriting => 'Writing...';

  @override
  String get aiAssistantReady => 'Ready to help anytime';

  @override
  String get aiEmptyTitle => 'Start chatting with AI';

  @override
  String get aiEmptyHint => 'Try saying \"Create a reading log notebook\"';

  @override
  String get chatInputListeningHint => 'Listening...';

  @override
  String get chatInputPlaceholder => 'Write something...';

  @override
  String get chatInputSpeechUnavailable =>
      'Voice input is unavailable. Please check microphone permission.';

  @override
  String get recordAddedSuccess => 'Record added successfully';

  @override
  String get recordUpdatedSuccess => 'Record updated successfully';

  @override
  String get notebookCreatedSuccess => 'Notebook created successfully';

  @override
  String get notebookUpdatedSuccess => 'Notebook updated successfully';

  @override
  String notebookUpdatedFields(num count, Object fields) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fields',
      one: '1 field',
      zero: '0 fields',
    );
    return 'After update: $_temp0: $fields';
  }

  @override
  String get notebookDeletedSuccess => 'Notebook deleted';

  @override
  String notebookDeletedName(Object name) {
    return 'Deleted \"$name\"';
  }

  @override
  String get notebookDeletedDesc =>
      'The notebook and all its records have been removed';

  @override
  String recordMoreFields(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more fields',
      one: '1 more field',
      zero: '0 more fields',
    );
    return 'and $_temp0...';
  }

  @override
  String recordReminderLabel(Object time) {
    return 'Reminder: $time';
  }

  @override
  String get reminderExpired => 'Expired';

  @override
  String get recordDeletedSuccess => 'Record deleted';

  @override
  String recordDeletedFromNotebook(Object name) {
    return 'Deleted record from \"$name\"';
  }

  @override
  String get recordDeleted => 'Record deleted';

  @override
  String recordIdLabel(Object id) {
    return 'ID: $id';
  }

  @override
  String queryResultsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Found $count records',
      one: 'Found 1 record',
      zero: 'No records found',
    );
    return '$_temp0';
  }

  @override
  String get queryNoResults => 'No matching records';

  @override
  String toolResultSuccess(Object tool) {
    return '$tool executed successfully';
  }

  @override
  String toolResultFailure(Object tool) {
    return '$tool failed to execute';
  }

  @override
  String get listSeparator => ', ';

  @override
  String get aiAssistantCardTitle => 'Create a new notebook';

  @override
  String get aiAssistantCardDesc =>
      'Describe what you want to record and let AI build the data structure';

  @override
  String aiServerError(Object status, Object details) {
    return 'Server error ($status): $details';
  }

  @override
  String aiConnectionError(Object message) {
    return 'Unable to connect to server: $message';
  }

  @override
  String aiHttpError(Object message) {
    return 'HTTP error: $message';
  }

  @override
  String aiRequestFailedError(Object error) {
    return 'Request failed: $error';
  }

  @override
  String get summaryPromptHeader =>
      'Below is my record data from the past 1 day. Please start with \'Dear myself\' and write a warm, healing, and empowering daily quote to encourage me to keep going:';

  @override
  String summaryNewNotebooks(Object count) {
    return '## New notebooks ($count)';
  }

  @override
  String summaryNotebookItem(Object name, Object fields) {
    return '- $name ($fields)';
  }

  @override
  String summaryNewRecords(Object count) {
    return '## New records (total $count)';
  }

  @override
  String summaryNotebookGroup(Object name, Object count) {
    return '### $name ($count)';
  }

  @override
  String summaryRecordItem(Object summary) {
    return '- $summary';
  }

  @override
  String summaryMoreRecords(Object count) {
    return '- ...and $count more';
  }

  @override
  String summaryAllNotebooks(Object count) {
    return '## All my notebooks ($count)';
  }

  @override
  String summaryAllNotebookItem(Object name, Object description) {
    return '- $name: $description';
  }

  @override
  String get summaryNoDescription => 'No description';

  @override
  String get summaryItemSeparator => ', ';

  @override
  String notebookFieldCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fields',
      one: '1 field',
      zero: '0 fields',
    );
    return '$_temp0';
  }

  @override
  String get refreshDrag => 'Pull to refresh';

  @override
  String get refreshArmed => 'Release to refresh';

  @override
  String get refreshReady => 'Release to refresh';

  @override
  String get refreshProcessing => 'Refreshing...';

  @override
  String get refreshProcessed => 'Refresh complete';

  @override
  String get refreshFailed => 'Refresh failed';

  @override
  String get profileTitle => 'Me';

  @override
  String get notificationDisabledTitle => 'Notifications off';

  @override
  String get notificationDisabledDesc =>
      'Enable notifications to receive important reminders';

  @override
  String get notificationDisabledAction => 'Enable';

  @override
  String get balanceTitle => 'Remaining';

  @override
  String balanceCount(Object count) {
    return '$count';
  }

  @override
  String get purchaseRecharge => 'Recharge';

  @override
  String get restorePurchasesTitle => 'Restore Purchases';

  @override
  String get notificationSoundSetting => 'Notification Sound';

  @override
  String get assistantPersonaSetting => 'Assistant Persona';

  @override
  String get assistantPersonaDescription => 'Set the AI assistant style';

  @override
  String get assistantPersonaTitle => 'Assistant Persona';

  @override
  String get assistantPersonaHint =>
      'Example: You are a warm and concise note assistant. Encourage first, then provide clear steps.';

  @override
  String get assistantPersonaSaved => 'Assistant persona saved';

  @override
  String purchaseFailed(Object message) {
    return 'Purchase failed: $message';
  }

  @override
  String get unknownError => 'Unknown error';

  @override
  String rechargeSuccess(num amount) {
    String _temp0 = intl.Intl.pluralLogic(
      amount,
      locale: localeName,
      other: '$amount times',
      one: '1 time',
      zero: '0 times',
    );
    return 'Recharge successful! $_temp0 added';
  }

  @override
  String get rechargeVerifyFailed =>
      'Recharge verification failed. Please contact support.';

  @override
  String get ticketInitializing =>
      'Ticket is initializing. Please try again later.';

  @override
  String get ticketImportSuccess => 'Import successful!';

  @override
  String get ticketInvalid => 'Invalid ticket';

  @override
  String get ticketCopied => 'Ticket copied to clipboard';

  @override
  String get restorePurchasesDesc =>
      'When switching devices, export your Ticket and import it on the new device to restore purchased times.';

  @override
  String get ticketExportTitle => 'Export Ticket';

  @override
  String get loadingShort => 'Loading...';

  @override
  String get ticketImportTitle => 'Import Ticket';

  @override
  String get ticketPasteHint => 'Paste Ticket ID';

  @override
  String get ticketImportAction => 'Import';

  @override
  String get purchaseSheetTitle => 'Recharge Packs';

  @override
  String get purchaseProcessing => 'Processing...';

  @override
  String get purchaseTimesUnit => 'times';

  @override
  String get purchaseRecommended => 'Recommended';

  @override
  String purchaseUnitPrice(Object price) {
    return 'About $price per time';
  }

  @override
  String get schemaAddAtLeastOneField => 'Please add at least one data field';

  @override
  String get fieldNameRequired => 'Field name cannot be empty';

  @override
  String get notebookSaved => 'Notebook saved';

  @override
  String saveFailed(Object error) {
    return 'Save failed: $error';
  }

  @override
  String get notebookUpdated => 'Notebook updated';

  @override
  String updateFailed(Object error) {
    return 'Update failed: $error';
  }

  @override
  String get editNotebookTitle => 'Edit Notebook';

  @override
  String get createNotebookTitle => 'Create Notebook';

  @override
  String get saveAction => 'Save';

  @override
  String get doneAction => 'Done';

  @override
  String get appearanceSectionTitle => 'Appearance';

  @override
  String get colorLabel => 'Color';

  @override
  String get iconLabel => 'Icon';

  @override
  String get basicInfoSectionTitle => 'Basic Info';

  @override
  String get notebookNameLabel => 'Notebook Name';

  @override
  String get notebookNameHint => 'e.g., Daily Expenses';

  @override
  String get notebookNameRequired => 'Please enter a name';

  @override
  String get notebookDescLabel => 'Description';

  @override
  String get notebookDescHint => 'Describe this notebook...';

  @override
  String get schemaSectionTitle => 'Data Schema';

  @override
  String get addFieldAction => 'Add Field';

  @override
  String get schemaEmptyTitle => 'No schema defined yet';

  @override
  String get schemaEmptyHint => 'Tap \"Add Field\" above to start';

  @override
  String get fieldNameLabel => 'Field Name';

  @override
  String get fieldDescHint => 'Optional: field description';

  @override
  String get recordEmptyContent => 'No content';

  @override
  String get backAction => 'Back';

  @override
  String get confirmDeleteTitle => 'Confirm Delete';

  @override
  String get confirmDeleteRecordContent =>
      'This cannot be undone. Delete this record?';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get deleteAction => 'Delete';

  @override
  String get recordListTitle => 'Records';

  @override
  String get noRecordsTitle => 'No records yet';

  @override
  String noRecordsHint(Object notebook) {
    return 'Try telling the AI assistant \"Add a $notebook record\"';
  }

  @override
  String get reminderSentLabel => 'Reminded';

  @override
  String get reminderExpiredLabel => 'Expired';

  @override
  String get reminderTimeLabel => 'Reminder time';

  @override
  String get reminderEditAction => 'Edit reminder time';

  @override
  String get reminderCancelAction => 'Cancel reminder';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get timeJustNow => 'Just now';

  @override
  String timeMinutesAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes ago',
      one: '1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String timeHoursAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String timeDaysAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get fieldNumberHint => 'Enter a number...';

  @override
  String get fieldMarkdownHint => 'Markdown supported...';

  @override
  String get statsTitle => 'Statistics';

  @override
  String filteredRecordsCount(Object filtered, Object total) {
    return '$filtered / $total records';
  }

  @override
  String get clearAction => 'Clear';

  @override
  String get allOption => 'All';

  @override
  String validValueCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count valid values',
      one: '1 valid value',
      zero: '0 valid values',
    );
    return '$_temp0';
  }

  @override
  String get metricSum => 'Sum';

  @override
  String get metricAverage => 'Average';

  @override
  String get metricMax => 'Max';

  @override
  String get metricMin => 'Min';

  @override
  String get trendLabel => 'Trend';

  @override
  String get trendInsufficientForGranularity =>
      'Not enough data for this granularity';

  @override
  String get trendInsufficientData =>
      'Not enough data. At least 2 records are required to generate a trend chart.';

  @override
  String get noData => 'No data';

  @override
  String get distributionLabel => 'Distribution';

  @override
  String get noDistributionData => 'No distribution data';

  @override
  String get granularityDay => 'Day';

  @override
  String get granularityWeek => 'Week';

  @override
  String get granularityMonth => 'Month';

  @override
  String get createdTimeLabel => 'Created time';

  @override
  String get axisLabel => 'Axis';

  @override
  String get otherLabel => 'Other';

  @override
  String get fieldTypeText => 'Text';

  @override
  String get fieldTypeNumber => 'Number';

  @override
  String get fieldTypeDate => 'Date';

  @override
  String get unnamedNotebook => 'Untitled Notebook';
}
