import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:keepy_flutter/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/notification_service.dart';
import 'services/ticket_service.dart';
import 'theme/miaoji_theme.dart';
import 'pages/main_shell.dart';
import 'pages/onboarding_page.dart';
import 'l10n/l10n_ext.dart';
import 'widgets/confetti_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化本地通知服务
  await NotificationService().init();

  // 初始化 Ticket（后台执行，不阻塞启动）
  TicketService().getTicketId();

  // 检查是否已完成引导
  final prefs = await SharedPreferences.getInstance();
  final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

  runApp(MyApp(showOnboarding: !onboardingCompleted));
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;

  const MyApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: ConfettiOverlay.navigatorKey,
      onGenerateTitle: (context) => context.l10n.appName,
      debugShowCheckedModeBanner: false,
      theme: MiaojiTheme.theme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: showOnboarding ? const OnboardingPage() : const MainShell(),
    );
  }
}
