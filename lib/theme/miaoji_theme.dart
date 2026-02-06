import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Miaoji 设计系统 - 颜色定义
class MiaojiColors {
  MiaojiColors._();

  // 主色调 - 温暖的靛蓝紫
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);

  // 强调色
  static const Color accent = Color(0xFFF472B6);
  static const Color accentLight = Color(0xFFFBCFE8);

  // 语义色
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // 中性色 - 背景与表面
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color card = Color(0xFFFFFFFF);

  // 文字色
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textHint = Color(0xFFCBD5E1);

  // 边框与分割线
  static const Color divider = Color(0xFFE2E8F0);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);

  // 兼容旧代码
  static const Color indigo = primary;

  // AI 按钮渐变色
  static const List<Color> aiGradient = [
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
    Color(0xFFA78BFA),
  ];

  // 卡片悬浮渐变
  static const List<Color> cardGradient = [
    Color(0xFFFFFFFF),
    Color(0xFFF8FAFC),
  ];
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

/// Miaoji 设计系统 - 圆角
class MiaojiRadius {
  MiaojiRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double full = 100;
}

/// Miaoji 设计系统 - 阴影
class MiaojiShadows {
  MiaojiShadows._();

  static List<BoxShadow> get sm => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get md => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.02),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get lg => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get glow => [
    BoxShadow(
      color: MiaojiColors.primary.withValues(alpha: 0.3),
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
      fontFamily: null, // 使用系统默认字体

      // 颜色方案
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

      // AppBar 主题
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

      // 卡片主题
      cardTheme: CardThemeData(
        elevation: 0,
        color: MiaojiColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MiaojiRadius.lg),
        ),
        margin: EdgeInsets.zero,
      ),

      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MiaojiColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
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
          borderSide: const BorderSide(
            color: MiaojiColors.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MiaojiRadius.md),
          borderSide: const BorderSide(
            color: MiaojiColors.error,
            width: 1.5,
          ),
        ),
        labelStyle: const TextStyle(
          color: MiaojiColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: const TextStyle(
          color: MiaojiColors.textHint,
          fontSize: 14,
        ),
        floatingLabelStyle: const TextStyle(
          color: MiaojiColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),

      // 按钮主题
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
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // 文字主题
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.0,
          color: MiaojiColors.textPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: MiaojiColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: MiaojiColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: MiaojiColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: MiaojiColors.textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: MiaojiColors.textSecondary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: MiaojiColors.textPrimary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: MiaojiColors.textSecondary,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: MiaojiColors.textTertiary,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          color: MiaojiColors.textPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: MiaojiColors.textSecondary,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: MiaojiColors.textTertiary,
        ),
      ),

      // 分割线主题
      dividerTheme: const DividerThemeData(
        color: MiaojiColors.divider,
        thickness: 1,
        space: 1,
      ),

      // SnackBar 主题
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

      // DropdownMenu 主题
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

      // FloatingActionButton 主题
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: MiaojiColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MiaojiRadius.lg),
        ),
      ),

      // BottomSheet 主题
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: MiaojiColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
      ),
    );
  }
}
