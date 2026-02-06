import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Miaoji 设计系统 - 颜色定义（纸质拟物风格）
class MiaojiColors {
  MiaojiColors._();

  // 主色调 - 温暖的棕褐墨色
  static const Color primary = Color(0xFF8B6914);
  static const Color primaryLight = Color(0xFFB8941F);
  static const Color primaryDark = Color(0xFF6B4F0E);

  // 强调色 - 朱砂红
  static const Color accent = Color(0xFFBF4D28);
  static const Color accentLight = Color(0xFFE8A990);

  // 语义色 - 柔和版本
  static const Color success = Color(0xFF5B8C5A);
  static const Color warning = Color(0xFFD4A24C);
  static const Color error = Color(0xFFC1553B);
  static const Color info = Color(0xFF5B7FA5);

  // 中性色 - 纸张系
  static const Color background = Color(0xFFF5EFE0); // 老旧纸张底色
  static const Color surface = Color(0xFFFAF6ED); // 卡片纸面
  static const Color surfaceVariant = Color(0xFFF0E8D6); // 略深纸面
  static const Color card = Color(0xFFFCF9F2); // 干净纸面

  // 文字色 - 墨色系
  static const Color textPrimary = Color(0xFF2C2416); // 浓墨
  static const Color textSecondary = Color(0xFF5C4E3C); // 淡墨
  static const Color textTertiary = Color(0xFF9C8D78); // 浅墨
  static const Color textHint = Color(0xFFC4B8A4); // 痕迹

  // 边框与分割线 - 纸边缘
  static const Color divider = Color(0xFFDDD4C1);
  static const Color border = Color(0xFFDDD4C1);
  static const Color borderLight = Color(0xFFECE5D5);

  // 兼容旧代码
  static const Color indigo = primary;

  // AI 按钮渐变色 - 墨水渐变
  static const List<Color> aiGradient = [
    Color(0xFF4A3B2A),
    Color(0xFF6B4F0E),
    Color(0xFF8B6914),
  ];

  // 纸张微渐变
  static const List<Color> paperGradient = [
    Color(0xFFFCF9F2),
    Color(0xFFF8F2E4),
  ];

  // 书签色系
  static const Color bookmarkRed = Color(0xFFC1553B);
  static const Color bookmarkGreen = Color(0xFF5B8C5A);
  static const Color bookmarkBlue = Color(0xFF5B7FA5);
  static const Color bookmarkGold = Color(0xFFD4A24C);
}

/// Miaoji 设计系统 - 间距
class MiaojiSpacing {
  MiaojiSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

/// Miaoji 设计系统 - 圆角（拟物纸张：更小的圆角）
class MiaojiRadius {
  MiaojiRadius._();

  static const double sm = 6;
  static const double md = 10;
  static const double lg = 14;
  static const double xl = 18;
  static const double xxl = 22;
  static const double full = 100;
}

/// Miaoji 设计系统 - 阴影（纸张浮起感）
class MiaojiShadows {
  MiaojiShadows._();

  // 纸张轻浮
  static List<BoxShadow> get sm => [
        BoxShadow(
          color: const Color(0xFF8B6914).withValues(alpha: 0.06),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];

  // 纸张中浮
  static List<BoxShadow> get md => [
        BoxShadow(
          color: const Color(0xFF8B6914).withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  // 纸张高浮
  static List<BoxShadow> get lg => [
        BoxShadow(
          color: const Color(0xFF8B6914).withValues(alpha: 0.1),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  // 纸张边缘阴影（右下侧更重）
  static List<BoxShadow> get paper => [
        BoxShadow(
          color: const Color(0xFF8B6914).withValues(alpha: 0.07),
          blurRadius: 8,
          offset: const Offset(2, 3),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 3,
          offset: const Offset(1, 1),
        ),
      ];

  static List<BoxShadow> get glow => [
        BoxShadow(
          color: MiaojiColors.primary.withValues(alpha: 0.25),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ];
}

/// Miaoji 主题
class MiaojiTheme {
  MiaojiTheme._();

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: null,

      colorScheme: ColorScheme.fromSeed(
        seedColor: MiaojiColors.primary,
        brightness: Brightness.light,
        primary: MiaojiColors.primary,
        onPrimary: Colors.white,
        secondary: MiaojiColors.accent,
        surface: MiaojiColors.surface,
        onSurface: MiaojiColors.textPrimary,
        error: MiaojiColors.error,
      ),

      scaffoldBackgroundColor: MiaojiColors.background,

      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: MiaojiColors.background,
        foregroundColor: MiaojiColors.textPrimary,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: MiaojiColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: MiaojiColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MiaojiRadius.lg),
        ),
        margin: EdgeInsets.zero,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MiaojiColors.surfaceVariant,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MiaojiRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MiaojiRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MiaojiRadius.md),
          borderSide:
              const BorderSide(color: MiaojiColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MiaojiRadius.md),
          borderSide:
              const BorderSide(color: MiaojiColors.error, width: 1.5),
        ),
        labelStyle: const TextStyle(
          color: MiaojiColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: const TextStyle(color: MiaojiColors.textHint, fontSize: 14),
        floatingLabelStyle: const TextStyle(
          color: MiaojiColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: MiaojiColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MiaojiRadius.md),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: MiaojiColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MiaojiRadius.sm),
          ),
          textStyle:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.0,
            color: MiaojiColors.textPrimary),
        headlineLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: MiaojiColors.textPrimary),
        headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: MiaojiColors.textPrimary),
        titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
            color: MiaojiColors.textPrimary),
        titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: MiaojiColors.textPrimary),
        titleSmall: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: MiaojiColors.textSecondary),
        bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: MiaojiColors.textPrimary,
            height: 1.5),
        bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: MiaojiColors.textSecondary,
            height: 1.5),
        bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: MiaojiColors.textTertiary,
            height: 1.4),
        labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            color: MiaojiColors.textPrimary),
        labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: MiaojiColors.textSecondary),
        labelSmall: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            color: MiaojiColors.textTertiary),
      ),

      dividerTheme: const DividerThemeData(
        color: MiaojiColors.divider,
        thickness: 1,
        space: 1,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: MiaojiColors.textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MiaojiRadius.md),
        ),
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),

      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: MiaojiColors.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(MiaojiRadius.md),
            borderSide: BorderSide.none,
          ),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: MiaojiColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MiaojiRadius.lg),
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: MiaojiColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }
}
