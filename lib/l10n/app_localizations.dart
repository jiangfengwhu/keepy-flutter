import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Miaoji'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navAssistant.
  ///
  /// In en, this message translates to:
  /// **'Miaoji'**
  String get navAssistant;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get navProfile;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Miaoji'**
  String get onboardingTitle1;

  /// No description provided for @onboardingSubtitle1.
  ///
  /// In en, this message translates to:
  /// **'Your intelligent note companion'**
  String get onboardingSubtitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'Miaoji helps you easily manage every important detail in life,\nso recording becomes simple, organized, and warm.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get onboardingTitle2;

  /// No description provided for @onboardingSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'Understands you, records what you need'**
  String get onboardingSubtitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'Built-in AI assistant supports voice input, smart summaries,\ncontent analysis, making your notes smarter and more efficient.'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Thoughtful Reminders'**
  String get onboardingTitle3;

  /// No description provided for @onboardingSubtitle3.
  ///
  /// In en, this message translates to:
  /// **'Never forget what matters'**
  String get onboardingSubtitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'Flexible reminders for each note,\nso you never miss an important moment.'**
  String get onboardingDesc3;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingAgreementPrefix.
  ///
  /// In en, this message translates to:
  /// **'By tapping \"Agree and Start\", you have read and agree to'**
  String get onboardingAgreementPrefix;

  /// No description provided for @onboardingAgreementUserAgreement.
  ///
  /// In en, this message translates to:
  /// **'User Service Agreement'**
  String get onboardingAgreementUserAgreement;

  /// No description provided for @onboardingAgreementAnd.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get onboardingAgreementAnd;

  /// No description provided for @onboardingAgreementPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get onboardingAgreementPrivacyPolicy;

  /// No description provided for @onboardingAgreeAndStart.
  ///
  /// In en, this message translates to:
  /// **'Agree and Start'**
  String get onboardingAgreeAndStart;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutVersionInfo.
  ///
  /// In en, this message translates to:
  /// **'Version {version} ({build})'**
  String aboutVersionInfo(Object version, Object build);

  /// No description provided for @aboutVersionLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get aboutVersionLoading;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Your intelligent note companion'**
  String get appTagline;

  /// No description provided for @userAgreementTitle.
  ///
  /// In en, this message translates to:
  /// **'User Service Agreement'**
  String get userAgreementTitle;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @aboutCopyright.
  ///
  /// In en, this message translates to:
  /// **'Miaoji © {year}'**
  String aboutCopyright(Object year);

  /// No description provided for @aboutIcp.
  ///
  /// In en, this message translates to:
  /// **'ICP Filing No.: Jing ICP XXXXXXXX-X'**
  String get aboutIcp;

  /// No description provided for @aboutSupportEmail.
  ///
  /// In en, this message translates to:
  /// **'Support Email: support@miaoji.app'**
  String get aboutSupportEmail;

  /// No description provided for @privacyPolicyHeader.
  ///
  /// In en, this message translates to:
  /// **'Miaoji Privacy Policy'**
  String get privacyPolicyHeader;

  /// No description provided for @privacyPolicyUpdatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated: Feb 9, 2026'**
  String get privacyPolicyUpdatedAt;

  /// No description provided for @privacyPolicyEffectiveAt.
  ///
  /// In en, this message translates to:
  /// **'Effective: Feb 9, 2026'**
  String get privacyPolicyEffectiveAt;

  /// No description provided for @privacyPolicyIntro1.
  ///
  /// In en, this message translates to:
  /// **'Miaoji (\"we\") understands the importance of your personal information and will do our best to keep it secure and reliable. We are committed to maintaining your trust and follow these principles: accountability, purpose limitation, consent, data minimization, security, participation, and transparency.'**
  String get privacyPolicyIntro1;

  /// No description provided for @privacyPolicyIntro2.
  ///
  /// In en, this message translates to:
  /// **'This Privacy Policy explains how we collect, use, store, share, and protect your personal information, and how you can manage it. Please read it carefully before using this app.'**
  String get privacyPolicyIntro2;

  /// No description provided for @privacySection1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Information We Collect'**
  String get privacySection1Title;

  /// No description provided for @privacySection1_1Title.
  ///
  /// In en, this message translates to:
  /// **'1.1 Information You Provide'**
  String get privacySection1_1Title;

  /// No description provided for @privacySection1_1Content.
  ///
  /// In en, this message translates to:
  /// **'(a) Note content: notebooks you create, text records, category tags, etc. These data are mainly stored on your device.\n\n(b) Voice data: when you use voice input, we temporarily capture your voice for speech-to-text. Voice data is used only during recognition and is not stored permanently.\n\n(c) Image data: when you use image-related features, we access your camera or photo library to obtain images. Images are stored on your device.'**
  String get privacySection1_1Content;

  /// No description provided for @privacySection1_2Title.
  ///
  /// In en, this message translates to:
  /// **'1.2 Information We Collect Automatically'**
  String get privacySection1_2Title;

  /// No description provided for @privacySection1_2Content.
  ///
  /// In en, this message translates to:
  /// **'(a) Device info: device model, OS version, device identifiers, etc., to ensure normal operation and improve experience.\n\n(b) App usage info: feature usage frequency, error logs, and other anonymous data, used to improve performance and service quality.\n\n(c) Purchase records: when you make in-app purchases, we record purchase status to provide paid features. Payments are processed by Apple App Store or Google Play; we do not collect your payment account information.'**
  String get privacySection1_2Content;

  /// No description provided for @privacySection1_3Title.
  ///
  /// In en, this message translates to:
  /// **'1.3 AI-Related Information'**
  String get privacySection1_3Title;

  /// No description provided for @privacySection1_3Content.
  ///
  /// In en, this message translates to:
  /// **'When you use the AI assistant, notes or conversation content you send to AI may be transmitted to secure cloud servers for processing. We use this data only as necessary to provide AI services and do not use it for other purposes.'**
  String get privacySection1_3Content;

  /// No description provided for @privacySection2Title.
  ///
  /// In en, this message translates to:
  /// **'2. How We Use Information'**
  String get privacySection2Title;

  /// No description provided for @privacySection2Content.
  ///
  /// In en, this message translates to:
  /// **'We use the collected information for:\n\n(a) Core services: note creation and management, speech-to-text, reminders, etc.\n\n(b) AI services: summaries, analysis, and Q&A based on your notes.\n\n(c) Service improvement: analyze anonymous usage data to improve performance, fix issues, and optimize experience.\n\n(d) Security: detect and prevent security risks to protect your data.\n\n(e) Notifications: send reminders at the times you set.'**
  String get privacySection2Content;

  /// No description provided for @privacySection3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Storage of Information'**
  String get privacySection3Title;

  /// No description provided for @privacySection3_1Title.
  ///
  /// In en, this message translates to:
  /// **'3.1 Storage Location'**
  String get privacySection3_1Title;

  /// No description provided for @privacySection3_1Content.
  ///
  /// In en, this message translates to:
  /// **'Your note data is mainly stored on your device (SQLite). When you use AI features, related data may be temporarily transmitted to cloud servers for processing and will not be permanently stored on the server after processing.'**
  String get privacySection3_1Content;

  /// No description provided for @privacySection3_2Title.
  ///
  /// In en, this message translates to:
  /// **'3.2 Retention Period'**
  String get privacySection3_2Title;

  /// No description provided for @privacySection3_2Content.
  ///
  /// In en, this message translates to:
  /// **'We retain your personal information only as long as necessary. When you delete notes or uninstall the app, local data is deleted. Temporarily processed cloud data is cleared promptly after processing.'**
  String get privacySection3_2Content;

  /// No description provided for @privacySection3_3Title.
  ///
  /// In en, this message translates to:
  /// **'3.3 Data Security'**
  String get privacySection3_3Title;

  /// No description provided for @privacySection3_3Content.
  ///
  /// In en, this message translates to:
  /// **'We take the following measures to protect your information:\n\n(a) Use secure local storage (e.g., Flutter Secure Storage) for sensitive data.\n\n(b) Use HTTPS encryption for data transmission to cloud servers.\n\n(c) Strictly limit data access and only access your data when necessary.'**
  String get privacySection3_3Content;

  /// No description provided for @privacySection4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Information Sharing'**
  String get privacySection4Title;

  /// No description provided for @privacySection4Content.
  ///
  /// In en, this message translates to:
  /// **'We will not sell your personal information to any third party. We may share your information in the following cases:\n\n(a) With your explicit consent.\n\n(b) To provide AI services, necessary data may be sent to AI service providers for processing. We require them to comply with data protection agreements.\n\n(c) As required by laws, legal processes, or government requests.\n\n(d) As reasonably necessary to protect our users, the public, or our legitimate rights and interests.'**
  String get privacySection4Content;

  /// No description provided for @privacySection5Title.
  ///
  /// In en, this message translates to:
  /// **'5. Your Rights'**
  String get privacySection5Title;

  /// No description provided for @privacySection5Content.
  ///
  /// In en, this message translates to:
  /// **'You have the following rights regarding your personal information:\n\n(a) Access: view and access all your data in the app at any time.\n\n(b) Correction: edit and modify your notes at any time.\n\n(c) Deletion: delete your notes, notebooks, or other data at any time. Uninstalling the app will delete all local data.\n\n(d) Permission management: enable or disable permissions we request in device settings (e.g., microphone, camera, photo library, notifications). Disabling permissions may affect related features.'**
  String get privacySection5Content;

  /// No description provided for @privacySection6Title.
  ///
  /// In en, this message translates to:
  /// **'6. Device Permissions'**
  String get privacySection6Title;

  /// No description provided for @privacySection6Content.
  ///
  /// In en, this message translates to:
  /// **'This app may request the following device permissions:\n\n(a) Microphone: for voice input and speech-to-text.\n\n(b) Camera/Photo Library: for taking or selecting images.\n\n(c) Notifications: to send the reminders you set.\n\nAll permissions are optional, requested only when you use the relevant feature, and can be turned off anytime in system settings.'**
  String get privacySection6Content;

  /// No description provided for @privacySection7Title.
  ///
  /// In en, this message translates to:
  /// **'7. Protection of Minors'**
  String get privacySection7Title;

  /// No description provided for @privacySection7Content.
  ///
  /// In en, this message translates to:
  /// **'We place high importance on protecting minors\' personal information. If you are under 14, please read this policy with a guardian and use the app only with their consent.'**
  String get privacySection7Content;

  /// No description provided for @privacySection8Title.
  ///
  /// In en, this message translates to:
  /// **'8. Updates to This Policy'**
  String get privacySection8Title;

  /// No description provided for @privacySection8Content.
  ///
  /// In en, this message translates to:
  /// **'We may update this policy from time to time. Updated policies will be announced in the app in an appropriate manner. If there are significant changes (e.g., expanded data collection scope), we will request your consent again via pop-up or other prominent methods.'**
  String get privacySection8Content;

  /// No description provided for @privacySection9Title.
  ///
  /// In en, this message translates to:
  /// **'9. Contact Us'**
  String get privacySection9Title;

  /// No description provided for @privacySection9Content.
  ///
  /// In en, this message translates to:
  /// **'If you have any questions, comments, or suggestions about this policy, or need to exercise your rights, contact us:\n\nApp name: Miaoji\nEmail: privacy@miaoji.app\n\nWe will respond within 15 business days.'**
  String get privacySection9Content;

  /// No description provided for @userAgreementHeader.
  ///
  /// In en, this message translates to:
  /// **'Miaoji User Service Agreement'**
  String get userAgreementHeader;

  /// No description provided for @userAgreementUpdatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated: Feb 9, 2026'**
  String get userAgreementUpdatedAt;

  /// No description provided for @userAgreementEffectiveAt.
  ///
  /// In en, this message translates to:
  /// **'Effective: Feb 9, 2026'**
  String get userAgreementEffectiveAt;

  /// No description provided for @userAgreementIntro.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the \"Miaoji\" app (the \"App\"). Please read and fully understand this Agreement before using it. If you do not agree to any terms, do not use the App. Once you start using the App, you indicate that you have understood and agreed to this Agreement.'**
  String get userAgreementIntro;

  /// No description provided for @userAgreementSection1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Service Description'**
  String get userAgreementSection1Title;

  /// No description provided for @userAgreementSection1Content1.
  ///
  /// In en, this message translates to:
  /// **'1.1 This App is an intelligent note management tool that provides notebook creation and management, text records, voice input, AI assistant, reminders, and other services (the \"Services\").'**
  String get userAgreementSection1Content1;

  /// No description provided for @userAgreementSection1Content2.
  ///
  /// In en, this message translates to:
  /// **'1.2 The Services may change with version updates. We reserve the right to modify, suspend, or terminate some or all Services at any time, and will make reasonable efforts to notify users in advance.'**
  String get userAgreementSection1Content2;

  /// No description provided for @userAgreementSection1Content3.
  ///
  /// In en, this message translates to:
  /// **'1.3 You understand and agree that the App may include free and paid features. Paid features are provided via in-app purchases; specific content and prices are as shown in the app.'**
  String get userAgreementSection1Content3;

  /// No description provided for @userAgreementSection2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Account and Usage Rules'**
  String get userAgreementSection2Title;

  /// No description provided for @userAgreementSection2Content1.
  ///
  /// In en, this message translates to:
  /// **'2.1 When using the App, you must comply with the laws and regulations of the People\'s Republic of China and must not use the App for any illegal activities.'**
  String get userAgreementSection2Content1;

  /// No description provided for @userAgreementSection2Content2.
  ///
  /// In en, this message translates to:
  /// **'2.2 You should properly keep your device and app data. Any loss or leakage caused by your own reasons shall be borne by you.'**
  String get userAgreementSection2Content2;

  /// No description provided for @userAgreementSection2Content3.
  ///
  /// In en, this message translates to:
  /// **'2.3 You must not use the App to:\n  (a) publish or spread illegal, harmful, threatening, insulting, defamatory, pornographic, or other improper content;\n  (b) infringe intellectual property, privacy, or other lawful rights of others;\n  (c) reverse engineer, decompile, disassemble, or otherwise attempt to obtain source code;\n  (d) interfere with or disrupt normal operation, including spreading viruses or malicious code;\n  (e) other acts that violate laws or this Agreement.'**
  String get userAgreementSection2Content3;

  /// No description provided for @userAgreementSection3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Intellectual Property'**
  String get userAgreementSection3Title;

  /// No description provided for @userAgreementSection3Content1.
  ///
  /// In en, this message translates to:
  /// **'3.1 All content of the App, including interface design, code, text, images, icons, audio, etc., is protected by copyright laws and treaties, and the IP belongs to the developer.'**
  String get userAgreementSection3Content1;

  /// No description provided for @userAgreementSection3Content2.
  ///
  /// In en, this message translates to:
  /// **'3.2 You own the IP of user-generated content such as notes and data you create. However, you authorize the App to use such content as necessary to provide services (e.g., AI assistant analyzing notes to provide suggestions).'**
  String get userAgreementSection3Content2;

  /// No description provided for @userAgreementSection3Content3.
  ///
  /// In en, this message translates to:
  /// **'3.3 Without written permission from the developer, you may not copy, distribute, display, mirror, or otherwise use any content of the App.'**
  String get userAgreementSection3Content3;

  /// No description provided for @userAgreementSection4Title.
  ///
  /// In en, this message translates to:
  /// **'4. AI Service Terms'**
  String get userAgreementSection4Title;

  /// No description provided for @userAgreementSection4Content1.
  ///
  /// In en, this message translates to:
  /// **'4.1 The App provides an AI assistant to help with summaries, content analysis, and Q&A. AI-generated content is for reference only and does not constitute professional advice.'**
  String get userAgreementSection4Content1;

  /// No description provided for @userAgreementSection4Content2.
  ///
  /// In en, this message translates to:
  /// **'4.2 You understand that AI responses may be inaccurate, incomplete, or untimely; you should judge and verify information yourself. The App is not liable for losses arising from AI content.'**
  String get userAgreementSection4Content2;

  /// No description provided for @userAgreementSection4Content3.
  ///
  /// In en, this message translates to:
  /// **'4.3 To provide AI services, the App may send some of your note content to secure cloud servers for processing. We will take strict security measures; see the Privacy Policy for details.'**
  String get userAgreementSection4Content3;

  /// No description provided for @userAgreementSection5Title.
  ///
  /// In en, this message translates to:
  /// **'5. Paid Services'**
  String get userAgreementSection5Title;

  /// No description provided for @userAgreementSection5Content1.
  ///
  /// In en, this message translates to:
  /// **'5.1 Some features are paid and provided through in-app purchases via Apple App Store or Google Play. Please confirm content and price before purchase.'**
  String get userAgreementSection5Content1;

  /// No description provided for @userAgreementSection5Content2.
  ///
  /// In en, this message translates to:
  /// **'5.2 After successful payment, features are enabled immediately. Except as required by law, completed purchases are non-refundable. For refunds, contact the relevant app store support.'**
  String get userAgreementSection5Content2;

  /// No description provided for @userAgreementSection5Content3.
  ///
  /// In en, this message translates to:
  /// **'5.3 Subscription services auto-renew. You can cancel auto-renewal in the app store\'s subscription management. After cancellation, the service remains available for the current subscription period.'**
  String get userAgreementSection5Content3;

  /// No description provided for @userAgreementSection6Title.
  ///
  /// In en, this message translates to:
  /// **'6. Disclaimer'**
  String get userAgreementSection6Title;

  /// No description provided for @userAgreementSection6Content1.
  ///
  /// In en, this message translates to:
  /// **'6.1 The App provides services \"as is\" and makes no express or implied warranties regarding timeliness, security, or accuracy.'**
  String get userAgreementSection6Content1;

  /// No description provided for @userAgreementSection6Content2.
  ///
  /// In en, this message translates to:
  /// **'6.2 The App is not liable for interruptions or data loss caused by force majeure, system maintenance, network failures, device failures, etc., but will make reasonable efforts to minimize impact.'**
  String get userAgreementSection6Content2;

  /// No description provided for @userAgreementSection6Content3.
  ///
  /// In en, this message translates to:
  /// **'6.3 Your note data is stored on your device. We recommend regular backups. The App is not liable for data loss due to device damage or system reset.'**
  String get userAgreementSection6Content3;

  /// No description provided for @userAgreementSection7Title.
  ///
  /// In en, this message translates to:
  /// **'7. Changes to the Agreement'**
  String get userAgreementSection7Title;

  /// No description provided for @userAgreementSection7Content1.
  ///
  /// In en, this message translates to:
  /// **'7.1 We may modify this Agreement as needed and will notify you appropriately in the app.'**
  String get userAgreementSection7Content1;

  /// No description provided for @userAgreementSection7Content2.
  ///
  /// In en, this message translates to:
  /// **'7.2 If you disagree with the modified Agreement, you may stop using the Services. Continued use after changes indicates acceptance.'**
  String get userAgreementSection7Content2;

  /// No description provided for @userAgreementSection8Title.
  ///
  /// In en, this message translates to:
  /// **'8. Governing Law and Dispute Resolution'**
  String get userAgreementSection8Title;

  /// No description provided for @userAgreementSection8Content1.
  ///
  /// In en, this message translates to:
  /// **'8.1 Interpretation, validity, and enforcement of this Agreement are governed by the laws of the People\'s Republic of China (excluding conflict of laws).'**
  String get userAgreementSection8Content1;

  /// No description provided for @userAgreementSection8Content2.
  ///
  /// In en, this message translates to:
  /// **'8.2 Any dispute arising from or related to this Agreement shall first be resolved through friendly negotiation. If negotiation fails, either party may file a lawsuit in a court with jurisdiction where the developer is located.'**
  String get userAgreementSection8Content2;

  /// No description provided for @userAgreementSection9Title.
  ///
  /// In en, this message translates to:
  /// **'9. Contact Us'**
  String get userAgreementSection9Title;

  /// No description provided for @userAgreementSection9Content.
  ///
  /// In en, this message translates to:
  /// **'If you have any questions or suggestions about this Agreement, please contact us:\n\nApp name: Miaoji\nEmail: support@miaoji.app\n\nThank you for choosing Miaoji. Enjoy!'**
  String get userAgreementSection9Content;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Miaoji Pocket'**
  String get homeTitle;

  /// No description provided for @notebookSection.
  ///
  /// In en, this message translates to:
  /// **'Notebooks'**
  String get notebookSection;

  /// No description provided for @notebookCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 notebooks} =1{1 notebook} other{{count} notebooks}}'**
  String notebookCount(num count);

  /// No description provided for @viewAllNotebooks.
  ///
  /// In en, this message translates to:
  /// **'View all {count, plural, =0{0 notebooks} =1{1 notebook} other{{count} notebooks}}'**
  String viewAllNotebooks(num count);

  /// No description provided for @aiWeeklyTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Quote'**
  String get aiWeeklyTitle;

  /// No description provided for @aiWeeklyCardLabel.
  ///
  /// In en, this message translates to:
  /// **'Dear Myself'**
  String get aiWeeklyCardLabel;

  /// No description provided for @aiWeeklyBasedOnDays.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{Based on last 1 day of data} other{Based on last {days} days of data}}'**
  String aiWeeklyBasedOnDays(num days);

  /// No description provided for @aiWeeklyGenerating.
  ///
  /// In en, this message translates to:
  /// **'Generating daily quote...'**
  String get aiWeeklyGenerating;

  /// No description provided for @aiWeeklyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No data yet. Record more data to generate automatically.'**
  String get aiWeeklyEmpty;

  /// No description provided for @aiWeeklyStreaming.
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get aiWeeklyStreaming;

  /// No description provided for @upcomingRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Reminders'**
  String get upcomingRemindersTitle;

  /// No description provided for @checkinTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Check-in'**
  String get checkinTitle;

  /// No description provided for @checkinAction.
  ///
  /// In en, this message translates to:
  /// **'Check in'**
  String get checkinAction;

  /// No description provided for @checkinDone.
  ///
  /// In en, this message translates to:
  /// **'Checked in today'**
  String get checkinDone;

  /// No description provided for @checkinSuccessFallback.
  ///
  /// In en, this message translates to:
  /// **'Check-in successful'**
  String get checkinSuccessFallback;

  /// No description provided for @checkinFailedFallback.
  ///
  /// In en, this message translates to:
  /// **'Check-in failed. Please try again later.'**
  String get checkinFailedFallback;

  /// No description provided for @reminderCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 reminders} =1{1 reminder} other{{count} reminders}}'**
  String reminderCount(num count);

  /// No description provided for @moreReminders.
  ///
  /// In en, this message translates to:
  /// **'and {count, plural, =0{0 more reminders} =1{1 more reminder} other{{count} more reminders}}...'**
  String moreReminders(num count);

  /// No description provided for @reminderInDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{in 1 day} other{in {count} days}}'**
  String reminderInDays(num count);

  /// No description provided for @reminderInHours.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{in 1 hour} other{in {count} hours}}'**
  String reminderInHours(num count);

  /// No description provided for @reminderInMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{in 1 minute} other{in {count} minutes}}'**
  String reminderInMinutes(num count);

  /// No description provided for @reminderSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get reminderSoon;

  /// No description provided for @featureAiCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Smart Create'**
  String get featureAiCreateTitle;

  /// No description provided for @featureAiCreateDesc.
  ///
  /// In en, this message translates to:
  /// **'Tell AI what you want to record and it will create a notebook'**
  String get featureAiCreateDesc;

  /// No description provided for @featureReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Reminders'**
  String get featureReminderTitle;

  /// No description provided for @featureReminderDesc.
  ///
  /// In en, this message translates to:
  /// **'Set reminders for records and never forget important things'**
  String get featureReminderDesc;

  /// No description provided for @featureAnalyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Data Insights'**
  String get featureAnalyticsTitle;

  /// No description provided for @featureAnalyticsDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically generate trends, pie charts, and visual analysis'**
  String get featureAnalyticsDesc;

  /// No description provided for @featureGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Miaoji Pocket'**
  String get featureGuideTitle;

  /// No description provided for @featureGuideSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the \"Assistant\" tab below and let AI create your first notebook'**
  String get featureGuideSubtitle;

  /// No description provided for @emptyNotebooksTitle.
  ///
  /// In en, this message translates to:
  /// **'No notebooks yet'**
  String get emptyNotebooksTitle;

  /// No description provided for @emptyNotebooksHint.
  ///
  /// In en, this message translates to:
  /// **'Try telling the AI assistant \"Create a reading log notebook\"'**
  String get emptyNotebooksHint;

  /// No description provided for @allNotebooksTitle.
  ///
  /// In en, this message translates to:
  /// **'All Notebooks'**
  String get allNotebooksTitle;

  /// No description provided for @emptyAllNotebooks.
  ///
  /// In en, this message translates to:
  /// **'No notebooks yet'**
  String get emptyAllNotebooks;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search records...'**
  String get searchHint;

  /// No description provided for @searchEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Type keywords to search all records'**
  String get searchEmptyHint;

  /// No description provided for @searchNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No matching records'**
  String get searchNoResultsTitle;

  /// No description provided for @searchNoResultsHint.
  ///
  /// In en, this message translates to:
  /// **'Try a different keyword'**
  String get searchNoResultsHint;

  /// No description provided for @searchRecordCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 records} =1{1 record} other{{count} records}}'**
  String searchRecordCount(num count);

  /// No description provided for @searchMoreFields.
  ///
  /// In en, this message translates to:
  /// **'and {count, plural, =0{0 more fields} =1{1 more field} other{{count} more fields}}...'**
  String searchMoreFields(num count);

  /// No description provided for @recordCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 records} =1{1 record} other{{count} records}}'**
  String recordCount(num count);

  /// No description provided for @alarmSoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder Sound'**
  String get alarmSoundTitle;

  /// No description provided for @alarmSoundDefaultName.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get alarmSoundDefaultName;

  /// No description provided for @alarmSoundDefaultDesc.
  ///
  /// In en, this message translates to:
  /// **'Use the system default notification sound'**
  String get alarmSoundDefaultDesc;

  /// No description provided for @alarmSoundClassicName.
  ///
  /// In en, this message translates to:
  /// **'Classic Alarm'**
  String get alarmSoundClassicName;

  /// No description provided for @alarmSoundClassicDesc.
  ///
  /// In en, this message translates to:
  /// **'Beep-beep... classic dual-tone alarm'**
  String get alarmSoundClassicDesc;

  /// No description provided for @alarmSoundRadarName.
  ///
  /// In en, this message translates to:
  /// **'Radar'**
  String get alarmSoundRadarName;

  /// No description provided for @alarmSoundRadarDesc.
  ///
  /// In en, this message translates to:
  /// **'Beep-beep-beep... fast pulses'**
  String get alarmSoundRadarDesc;

  /// No description provided for @alarmSoundBeaconName.
  ///
  /// In en, this message translates to:
  /// **'Beacon'**
  String get alarmSoundBeaconName;

  /// No description provided for @alarmSoundBeaconDesc.
  ///
  /// In en, this message translates to:
  /// **'Low-high... alternating rising tones'**
  String get alarmSoundBeaconDesc;

  /// No description provided for @alarmSoundChimeName.
  ///
  /// In en, this message translates to:
  /// **'Chime'**
  String get alarmSoundChimeName;

  /// No description provided for @alarmSoundChimeDesc.
  ///
  /// In en, this message translates to:
  /// **'Ding... ding... crisp chimes'**
  String get alarmSoundChimeDesc;

  /// No description provided for @alarmSoundPulseName.
  ///
  /// In en, this message translates to:
  /// **'Pulse'**
  String get alarmSoundPulseName;

  /// No description provided for @alarmSoundPulseDesc.
  ///
  /// In en, this message translates to:
  /// **'Beep-buzz... urgent rhythm'**
  String get alarmSoundPulseDesc;

  /// No description provided for @notificationSoundPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'🔔 Sound Preview'**
  String get notificationSoundPreviewTitle;

  /// No description provided for @notificationChannelName.
  ///
  /// In en, this message translates to:
  /// **'Notebook Alarm Reminder'**
  String get notificationChannelName;

  /// No description provided for @notificationChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Alarm-style reminders for notebook records that keep ringing until handled'**
  String get notificationChannelDescription;

  /// No description provided for @notificationReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'📝 {notebookName}'**
  String notificationReminderTitle(Object notebookName);

  /// No description provided for @notificationFallbackBody.
  ///
  /// In en, this message translates to:
  /// **'You have a pending reminder'**
  String get notificationFallbackBody;

  /// No description provided for @aiImageSourceCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get aiImageSourceCamera;

  /// No description provided for @aiImageSourceGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get aiImageSourceGallery;

  /// No description provided for @aiErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Sorry, an error occurred: {message}'**
  String aiErrorMessage(Object message);

  /// No description provided for @aiRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Request failed: {error}'**
  String aiRequestFailed(Object error);

  /// No description provided for @aiAssistantTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiAssistantTitle;

  /// No description provided for @aiAssistantWriting.
  ///
  /// In en, this message translates to:
  /// **'Writing...'**
  String get aiAssistantWriting;

  /// No description provided for @aiAssistantReady.
  ///
  /// In en, this message translates to:
  /// **'Ready to help anytime'**
  String get aiAssistantReady;

  /// No description provided for @aiEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Start chatting with AI'**
  String get aiEmptyTitle;

  /// No description provided for @aiEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Try saying \"Create a reading log notebook\"'**
  String get aiEmptyHint;

  /// No description provided for @chatInputListeningHint.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get chatInputListeningHint;

  /// No description provided for @chatInputPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Write something...'**
  String get chatInputPlaceholder;

  /// No description provided for @chatInputSpeechUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Voice input is unavailable. Please check microphone permission.'**
  String get chatInputSpeechUnavailable;

  /// No description provided for @recordAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Record added successfully'**
  String get recordAddedSuccess;

  /// No description provided for @recordUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Record updated successfully'**
  String get recordUpdatedSuccess;

  /// No description provided for @notebookCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Notebook created successfully'**
  String get notebookCreatedSuccess;

  /// No description provided for @notebookUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Notebook updated successfully'**
  String get notebookUpdatedSuccess;

  /// No description provided for @notebookUpdatedFields.
  ///
  /// In en, this message translates to:
  /// **'After update: {count, plural, =0{0 fields} =1{1 field} other{{count} fields}}: {fields}'**
  String notebookUpdatedFields(num count, Object fields);

  /// No description provided for @notebookDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Notebook deleted'**
  String get notebookDeletedSuccess;

  /// No description provided for @notebookDeletedName.
  ///
  /// In en, this message translates to:
  /// **'Deleted \"{name}\"'**
  String notebookDeletedName(Object name);

  /// No description provided for @notebookDeletedDesc.
  ///
  /// In en, this message translates to:
  /// **'The notebook and all its records have been removed'**
  String get notebookDeletedDesc;

  /// No description provided for @recordMoreFields.
  ///
  /// In en, this message translates to:
  /// **'and {count, plural, =0{0 more fields} =1{1 more field} other{{count} more fields}}...'**
  String recordMoreFields(num count);

  /// No description provided for @recordReminderLabel.
  ///
  /// In en, this message translates to:
  /// **'Reminder: {time}'**
  String recordReminderLabel(Object time);

  /// No description provided for @reminderExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get reminderExpired;

  /// No description provided for @recordDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Record deleted'**
  String get recordDeletedSuccess;

  /// No description provided for @recordDeletedFromNotebook.
  ///
  /// In en, this message translates to:
  /// **'Deleted record from \"{name}\"'**
  String recordDeletedFromNotebook(Object name);

  /// No description provided for @recordDeleted.
  ///
  /// In en, this message translates to:
  /// **'Record deleted'**
  String get recordDeleted;

  /// No description provided for @recordIdLabel.
  ///
  /// In en, this message translates to:
  /// **'ID: {id}'**
  String recordIdLabel(Object id);

  /// No description provided for @queryResultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No records found} =1{Found 1 record} other{Found {count} records}}'**
  String queryResultsCount(num count);

  /// No description provided for @queryNoResults.
  ///
  /// In en, this message translates to:
  /// **'No matching records'**
  String get queryNoResults;

  /// No description provided for @toolResultSuccess.
  ///
  /// In en, this message translates to:
  /// **'{tool} executed successfully'**
  String toolResultSuccess(Object tool);

  /// No description provided for @toolResultFailure.
  ///
  /// In en, this message translates to:
  /// **'{tool} failed to execute'**
  String toolResultFailure(Object tool);

  /// No description provided for @listSeparator.
  ///
  /// In en, this message translates to:
  /// **', '**
  String get listSeparator;

  /// No description provided for @aiAssistantCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a new notebook'**
  String get aiAssistantCardTitle;

  /// No description provided for @aiAssistantCardDesc.
  ///
  /// In en, this message translates to:
  /// **'Describe what you want to record and let AI build the data structure'**
  String get aiAssistantCardDesc;

  /// No description provided for @aiServerError.
  ///
  /// In en, this message translates to:
  /// **'Server error ({status}): {details}'**
  String aiServerError(Object status, Object details);

  /// No description provided for @aiConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect to server: {message}'**
  String aiConnectionError(Object message);

  /// No description provided for @aiHttpError.
  ///
  /// In en, this message translates to:
  /// **'HTTP error: {message}'**
  String aiHttpError(Object message);

  /// No description provided for @aiRequestFailedError.
  ///
  /// In en, this message translates to:
  /// **'Request failed: {error}'**
  String aiRequestFailedError(Object error);

  /// No description provided for @summaryPromptHeader.
  ///
  /// In en, this message translates to:
  /// **'Below is my record data from the past 1 day. Please start with \'Dear myself\' and write a warm, healing, and empowering daily quote to encourage me to keep going:'**
  String get summaryPromptHeader;

  /// No description provided for @summaryNewNotebooks.
  ///
  /// In en, this message translates to:
  /// **'## New notebooks ({count})'**
  String summaryNewNotebooks(Object count);

  /// No description provided for @summaryNotebookItem.
  ///
  /// In en, this message translates to:
  /// **'- {name} ({fields})'**
  String summaryNotebookItem(Object name, Object fields);

  /// No description provided for @summaryNewRecords.
  ///
  /// In en, this message translates to:
  /// **'## New records (total {count})'**
  String summaryNewRecords(Object count);

  /// No description provided for @summaryNotebookGroup.
  ///
  /// In en, this message translates to:
  /// **'### {name} ({count})'**
  String summaryNotebookGroup(Object name, Object count);

  /// No description provided for @summaryRecordItem.
  ///
  /// In en, this message translates to:
  /// **'- {summary}'**
  String summaryRecordItem(Object summary);

  /// No description provided for @summaryMoreRecords.
  ///
  /// In en, this message translates to:
  /// **'- ...and {count} more'**
  String summaryMoreRecords(Object count);

  /// No description provided for @summaryAllNotebooks.
  ///
  /// In en, this message translates to:
  /// **'## All my notebooks ({count})'**
  String summaryAllNotebooks(Object count);

  /// No description provided for @summaryAllNotebookItem.
  ///
  /// In en, this message translates to:
  /// **'- {name}: {description}'**
  String summaryAllNotebookItem(Object name, Object description);

  /// No description provided for @summaryNoDescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get summaryNoDescription;

  /// No description provided for @summaryItemSeparator.
  ///
  /// In en, this message translates to:
  /// **', '**
  String get summaryItemSeparator;

  /// No description provided for @notebookFieldCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 fields} =1{1 field} other{{count} fields}}'**
  String notebookFieldCount(num count);

  /// No description provided for @refreshDrag.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh'**
  String get refreshDrag;

  /// No description provided for @refreshArmed.
  ///
  /// In en, this message translates to:
  /// **'Release to refresh'**
  String get refreshArmed;

  /// No description provided for @refreshReady.
  ///
  /// In en, this message translates to:
  /// **'Release to refresh'**
  String get refreshReady;

  /// No description provided for @refreshProcessing.
  ///
  /// In en, this message translates to:
  /// **'Refreshing...'**
  String get refreshProcessing;

  /// No description provided for @refreshProcessed.
  ///
  /// In en, this message translates to:
  /// **'Refresh complete'**
  String get refreshProcessed;

  /// No description provided for @refreshFailed.
  ///
  /// In en, this message translates to:
  /// **'Refresh failed'**
  String get refreshFailed;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get profileTitle;

  /// No description provided for @notificationDisabledTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications off'**
  String get notificationDisabledTitle;

  /// No description provided for @notificationDisabledDesc.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications to receive important reminders'**
  String get notificationDisabledDesc;

  /// No description provided for @notificationDisabledAction.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get notificationDisabledAction;

  /// No description provided for @balanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get balanceTitle;

  /// No description provided for @balanceCount.
  ///
  /// In en, this message translates to:
  /// **'{count}'**
  String balanceCount(Object count);

  /// No description provided for @purchaseRecharge.
  ///
  /// In en, this message translates to:
  /// **'Recharge'**
  String get purchaseRecharge;

  /// No description provided for @restorePurchasesTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchasesTitle;

  /// No description provided for @notificationSoundSetting.
  ///
  /// In en, this message translates to:
  /// **'Notification Sound'**
  String get notificationSoundSetting;

  /// No description provided for @assistantPersonaSetting.
  ///
  /// In en, this message translates to:
  /// **'Assistant Persona'**
  String get assistantPersonaSetting;

  /// No description provided for @assistantPersonaDescription.
  ///
  /// In en, this message translates to:
  /// **'Set the AI assistant style'**
  String get assistantPersonaDescription;

  /// No description provided for @assistantPersonaTitle.
  ///
  /// In en, this message translates to:
  /// **'Assistant Persona'**
  String get assistantPersonaTitle;

  /// No description provided for @assistantPersonaHint.
  ///
  /// In en, this message translates to:
  /// **'Example: You are a warm and concise note assistant. Encourage first, then provide clear steps.'**
  String get assistantPersonaHint;

  /// No description provided for @assistantPersonaSaved.
  ///
  /// In en, this message translates to:
  /// **'Assistant persona saved'**
  String get assistantPersonaSaved;

  /// No description provided for @assistantPersonaPresetLabel.
  ///
  /// In en, this message translates to:
  /// **'Choose a preset style'**
  String get assistantPersonaPresetLabel;

  /// No description provided for @assistantPersonaCustomLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get assistantPersonaCustomLabel;

  /// No description provided for @assistantPersonaCustomPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter a custom assistant persona description…'**
  String get assistantPersonaCustomPlaceholder;

  /// No description provided for @assistantPersonaPresetWarm.
  ///
  /// In en, this message translates to:
  /// **'Warm & Caring'**
  String get assistantPersonaPresetWarm;

  /// No description provided for @assistantPersonaPresetWarmDesc.
  ///
  /// In en, this message translates to:
  /// **'Gentle, encouraging & positive'**
  String get assistantPersonaPresetWarmDesc;

  /// No description provided for @assistantPersonaPresetWarmPrompt.
  ///
  /// In en, this message translates to:
  /// **'You are a warm and caring companion. Always acknowledge the user\'s efforts and progress first, give advice in a gentle tone, find the beauty in everyday life, and fill every interaction with positive energy.'**
  String get assistantPersonaPresetWarmPrompt;

  /// No description provided for @assistantPersonaPresetConcise.
  ///
  /// In en, this message translates to:
  /// **'Concise & Efficient'**
  String get assistantPersonaPresetConcise;

  /// No description provided for @assistantPersonaPresetConciseDesc.
  ///
  /// In en, this message translates to:
  /// **'Direct, to-the-point, no fluff'**
  String get assistantPersonaPresetConciseDesc;

  /// No description provided for @assistantPersonaPresetConcisePrompt.
  ///
  /// In en, this message translates to:
  /// **'You are a sharp and efficient assistant. Keep responses brief and to-the-point. Use bullet points and lists to organize information. Help the user think clearly and act fast.'**
  String get assistantPersonaPresetConcisePrompt;

  /// No description provided for @assistantPersonaPresetHumorous.
  ///
  /// In en, this message translates to:
  /// **'Humorous & Fun'**
  String get assistantPersonaPresetHumorous;

  /// No description provided for @assistantPersonaPresetHumorousDesc.
  ///
  /// In en, this message translates to:
  /// **'Witty, playful & lighthearted'**
  String get assistantPersonaPresetHumorousDesc;

  /// No description provided for @assistantPersonaPresetHumorousPrompt.
  ///
  /// In en, this message translates to:
  /// **'You are a humorous and witty chat buddy. Respond in a lighthearted way, sprinkle in jokes and fun metaphors, and make the whole experience enjoyable while still being helpful.'**
  String get assistantPersonaPresetHumorousPrompt;

  /// No description provided for @purchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed: {message}'**
  String purchaseFailed(Object message);

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// No description provided for @rechargeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Recharge successful! {amount, plural, =0{0 times} =1{1 time} other{{amount} times}} added'**
  String rechargeSuccess(num amount);

  /// No description provided for @rechargeVerifyFailed.
  ///
  /// In en, this message translates to:
  /// **'Recharge verification failed. Please contact support.'**
  String get rechargeVerifyFailed;

  /// No description provided for @ticketInitializing.
  ///
  /// In en, this message translates to:
  /// **'Ticket is initializing. Please try again later.'**
  String get ticketInitializing;

  /// No description provided for @ticketImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Import successful!'**
  String get ticketImportSuccess;

  /// No description provided for @ticketInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid ticket'**
  String get ticketInvalid;

  /// No description provided for @ticketCopied.
  ///
  /// In en, this message translates to:
  /// **'Ticket copied to clipboard'**
  String get ticketCopied;

  /// No description provided for @restorePurchasesDesc.
  ///
  /// In en, this message translates to:
  /// **'When switching devices, export your Ticket and import it on the new device to restore purchased times.'**
  String get restorePurchasesDesc;

  /// No description provided for @ticketExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export Ticket'**
  String get ticketExportTitle;

  /// No description provided for @loadingShort.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingShort;

  /// No description provided for @ticketImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Ticket'**
  String get ticketImportTitle;

  /// No description provided for @ticketPasteHint.
  ///
  /// In en, this message translates to:
  /// **'Paste Ticket ID'**
  String get ticketPasteHint;

  /// No description provided for @ticketImportAction.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get ticketImportAction;

  /// No description provided for @purchaseSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Recharge Packs'**
  String get purchaseSheetTitle;

  /// No description provided for @purchaseProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get purchaseProcessing;

  /// No description provided for @purchaseTimesUnit.
  ///
  /// In en, this message translates to:
  /// **'times'**
  String get purchaseTimesUnit;

  /// No description provided for @purchaseRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get purchaseRecommended;

  /// No description provided for @purchaseUnitPrice.
  ///
  /// In en, this message translates to:
  /// **'About {price} per time'**
  String purchaseUnitPrice(Object price);

  /// No description provided for @schemaAddAtLeastOneField.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one data field'**
  String get schemaAddAtLeastOneField;

  /// No description provided for @fieldNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Field name cannot be empty'**
  String get fieldNameRequired;

  /// No description provided for @notebookSaved.
  ///
  /// In en, this message translates to:
  /// **'Notebook saved'**
  String get notebookSaved;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save failed: {error}'**
  String saveFailed(Object error);

  /// No description provided for @notebookUpdated.
  ///
  /// In en, this message translates to:
  /// **'Notebook updated'**
  String get notebookUpdated;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed: {error}'**
  String updateFailed(Object error);

  /// No description provided for @editNotebookTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Notebook'**
  String get editNotebookTitle;

  /// No description provided for @createNotebookTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Notebook'**
  String get createNotebookTitle;

  /// No description provided for @saveAction.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveAction;

  /// No description provided for @doneAction.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneAction;

  /// No description provided for @appearanceSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceSectionTitle;

  /// No description provided for @colorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get colorLabel;

  /// No description provided for @iconLabel.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get iconLabel;

  /// No description provided for @basicInfoSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Basic Info'**
  String get basicInfoSectionTitle;

  /// No description provided for @notebookNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Notebook Name'**
  String get notebookNameLabel;

  /// No description provided for @notebookNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Daily Expenses'**
  String get notebookNameHint;

  /// No description provided for @notebookNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get notebookNameRequired;

  /// No description provided for @notebookDescLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get notebookDescLabel;

  /// No description provided for @notebookDescHint.
  ///
  /// In en, this message translates to:
  /// **'Describe this notebook...'**
  String get notebookDescHint;

  /// No description provided for @schemaSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Data Schema'**
  String get schemaSectionTitle;

  /// No description provided for @addFieldAction.
  ///
  /// In en, this message translates to:
  /// **'Add Field'**
  String get addFieldAction;

  /// No description provided for @schemaEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No schema defined yet'**
  String get schemaEmptyTitle;

  /// No description provided for @schemaEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Add Field\" above to start'**
  String get schemaEmptyHint;

  /// No description provided for @fieldNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Field Name'**
  String get fieldNameLabel;

  /// No description provided for @fieldDescHint.
  ///
  /// In en, this message translates to:
  /// **'Optional: field description'**
  String get fieldDescHint;

  /// No description provided for @recordEmptyContent.
  ///
  /// In en, this message translates to:
  /// **'No content'**
  String get recordEmptyContent;

  /// No description provided for @backAction.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backAction;

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDeleteTitle;

  /// No description provided for @confirmDeleteRecordContent.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone. Delete this record?'**
  String get confirmDeleteRecordContent;

  /// No description provided for @cancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// No description provided for @deleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// No description provided for @recordListTitle.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get recordListTitle;

  /// No description provided for @noRecordsTitle.
  ///
  /// In en, this message translates to:
  /// **'No records yet'**
  String get noRecordsTitle;

  /// No description provided for @noRecordsHint.
  ///
  /// In en, this message translates to:
  /// **'Try telling the AI assistant \"Add a {notebook} record\"'**
  String noRecordsHint(Object notebook);

  /// No description provided for @reminderSentLabel.
  ///
  /// In en, this message translates to:
  /// **'Reminded'**
  String get reminderSentLabel;

  /// No description provided for @reminderExpiredLabel.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get reminderExpiredLabel;

  /// No description provided for @reminderTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get reminderTimeLabel;

  /// No description provided for @reminderEditAction.
  ///
  /// In en, this message translates to:
  /// **'Edit reminder time'**
  String get reminderEditAction;

  /// No description provided for @reminderCancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel reminder'**
  String get reminderCancelAction;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @timeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get timeJustNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute ago} other{{count} minutes ago}}'**
  String timeMinutesAgo(num count);

  /// No description provided for @timeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour ago} other{{count} hours ago}}'**
  String timeHoursAgo(num count);

  /// No description provided for @timeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day ago} other{{count} days ago}}'**
  String timeDaysAgo(num count);

  /// No description provided for @fieldNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a number...'**
  String get fieldNumberHint;

  /// No description provided for @fieldMarkdownHint.
  ///
  /// In en, this message translates to:
  /// **'Markdown supported...'**
  String get fieldMarkdownHint;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statsTitle;

  /// No description provided for @filteredRecordsCount.
  ///
  /// In en, this message translates to:
  /// **'{filtered} / {total} records'**
  String filteredRecordsCount(Object filtered, Object total);

  /// No description provided for @clearAction.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearAction;

  /// No description provided for @allOption.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allOption;

  /// No description provided for @validValueCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 valid values} =1{1 valid value} other{{count} valid values}}'**
  String validValueCount(num count);

  /// No description provided for @metricSum.
  ///
  /// In en, this message translates to:
  /// **'Sum'**
  String get metricSum;

  /// No description provided for @metricAverage.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get metricAverage;

  /// No description provided for @metricMax.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get metricMax;

  /// No description provided for @metricMin.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get metricMin;

  /// No description provided for @trendLabel.
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get trendLabel;

  /// No description provided for @trendInsufficientForGranularity.
  ///
  /// In en, this message translates to:
  /// **'Not enough data for this granularity'**
  String get trendInsufficientForGranularity;

  /// No description provided for @trendInsufficientData.
  ///
  /// In en, this message translates to:
  /// **'Not enough data. At least 2 records are required to generate a trend chart.'**
  String get trendInsufficientData;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @distributionLabel.
  ///
  /// In en, this message translates to:
  /// **'Distribution'**
  String get distributionLabel;

  /// No description provided for @noDistributionData.
  ///
  /// In en, this message translates to:
  /// **'No distribution data'**
  String get noDistributionData;

  /// No description provided for @granularityDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get granularityDay;

  /// No description provided for @granularityWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get granularityWeek;

  /// No description provided for @granularityMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get granularityMonth;

  /// No description provided for @createdTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Created time'**
  String get createdTimeLabel;

  /// No description provided for @axisLabel.
  ///
  /// In en, this message translates to:
  /// **'Axis'**
  String get axisLabel;

  /// No description provided for @otherLabel.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherLabel;

  /// No description provided for @fieldTypeText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get fieldTypeText;

  /// No description provided for @fieldTypeNumber.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get fieldTypeNumber;

  /// No description provided for @fieldTypeDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get fieldTypeDate;

  /// No description provided for @unnamedNotebook.
  ///
  /// In en, this message translates to:
  /// **'Untitled Notebook'**
  String get unnamedNotebook;

  /// No description provided for @onboardingTicketTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Unique Credential'**
  String get onboardingTicketTitle;

  /// No description provided for @onboardingTicketDesc.
  ///
  /// In en, this message translates to:
  /// **'Please save the ID below. It is the only way to restore your purchases. We recommend taking a screenshot or copying it.'**
  String get onboardingTicketDesc;

  /// No description provided for @onboardingTicketCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy ID'**
  String get onboardingTicketCopy;

  /// No description provided for @onboardingTicketCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get onboardingTicketCopied;

  /// No description provided for @onboardingTicketFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to get credential'**
  String get onboardingTicketFailed;

  /// No description provided for @onboardingTicketFailedDesc.
  ///
  /// In en, this message translates to:
  /// **'Unable to get your ID. Please check your network and try again.'**
  String get onboardingTicketFailedDesc;

  /// No description provided for @onboardingTicketRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get onboardingTicketRetry;

  /// No description provided for @onboardingTicketLoading.
  ///
  /// In en, this message translates to:
  /// **'Getting your credential...'**
  String get onboardingTicketLoading;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
