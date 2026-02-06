import 'package:flutter/material.dart';
import 'theme/miaoji_theme.dart';
import 'pages/main_shell.dart';

void main() {
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
      home: const MainShell(),
    );
  }
}
