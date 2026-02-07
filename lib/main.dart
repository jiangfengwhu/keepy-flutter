import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/notification_service.dart';
import 'theme/miaoji_theme.dart';
import 'pages/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化本地通知服务
  await NotificationService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Miaoji',
      debugShowCheckedModeBanner: false,
      theme: MiaojiTheme.theme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
      ],
      home: const MainShell(),
    );
  }
}
