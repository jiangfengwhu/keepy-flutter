import 'package:flutter/material.dart';
import 'package:keepy_flutter/l10n/app_localizations.dart';
import 'notebook.dart';

/// 首页笔记本列表项数据模型
class NotebookItem {
  final int? dbId; // 数据库 ID
  final IconData icon;
  final String? iconImagePath;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final int recordCount; // 记录数

  const NotebookItem({
    this.dbId,
    required this.icon,
    this.iconImagePath,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    this.recordCount = 0,
  });

  /// 可选图标集合（icon codePoint -> 显示名称）
  static const List<NotebookIconOption> availableIcons = [
    NotebookIconOption(Icons.auto_stories_rounded, '书本'),
    NotebookIconOption(Icons.fitness_center_rounded, '健身'),
    NotebookIconOption(Icons.restaurant_rounded, '美食'),
    NotebookIconOption(Icons.medication_rounded, '健康'),
    NotebookIconOption(Icons.payments_rounded, '账单'),
    NotebookIconOption(Icons.school_rounded, '学习'),
    NotebookIconOption(Icons.flight_rounded, '旅行'),
    NotebookIconOption(Icons.work_rounded, '工作'),
    NotebookIconOption(Icons.shopping_bag_rounded, '购物'),
    NotebookIconOption(Icons.pets_rounded, '宠物'),
    NotebookIconOption(Icons.directions_car_rounded, '出行'),
    NotebookIconOption(Icons.home_rounded, '居家'),
    NotebookIconOption(Icons.movie_rounded, '影视'),
    NotebookIconOption(Icons.music_note_rounded, '音乐'),
    NotebookIconOption(Icons.sports_esports_rounded, '游戏'),
    NotebookIconOption(Icons.favorite_rounded, '心愿'),
  ];

  /// 可选颜色集合
  static const List<NotebookColorOption> availableColors = [
    NotebookColorOption(0xFF8B5CF6, '紫色', Color(0xFFEDE9FE)),
    NotebookColorOption(0xFFEF4444, '红色', Color(0xFFFEE2E2)),
    NotebookColorOption(0xFFF59E0B, '橙色', Color(0xFFFEF3C7)),
    NotebookColorOption(0xFF10B981, '绿色', Color(0xFFD1FAE5)),
    NotebookColorOption(0xFF3B82F6, '蓝色', Color(0xFFDBEAFE)),
    NotebookColorOption(0xFFEC4899, '粉色', Color(0xFFFCE7F3)),
    NotebookColorOption(0xFF06B6D4, '青色', Color(0xFFCFFAFE)),
    NotebookColorOption(0xFF6366F1, '靛色', Color(0xFFE0E7FF)),
  ];

  /// 旧的随机分配方案（兜底用）
  static const _defaultIconSets = [
    (Icons.auto_stories_rounded, Color(0xFF8B5CF6), Color(0xFFEDE9FE)),
    (Icons.fitness_center_rounded, Color(0xFFEF4444), Color(0xFFFEE2E2)),
    (Icons.restaurant_rounded, Color(0xFFF59E0B), Color(0xFFFEF3C7)),
    (Icons.medication_rounded, Color(0xFF10B981), Color(0xFFD1FAE5)),
    (Icons.payments_rounded, Color(0xFF3B82F6), Color(0xFFDBEAFE)),
    (Icons.school_rounded, Color(0xFFEC4899), Color(0xFFFCE7F3)),
    (Icons.flight_rounded, Color(0xFF06B6D4), Color(0xFFCFFAFE)),
    (Icons.work_rounded, Color(0xFF6366F1), Color(0xFFE0E7FF)),
  ];

  /// 从数据库 Notebook 模型转换
  factory NotebookItem.fromNotebook(
    Notebook notebook, {
    AppLocalizations? l10n,
  }) {
    // 图标和颜色独立解析：任一缺失时仅对缺失项走兜底
    final hash = notebook.name.hashCode.abs();
    final set = _defaultIconSets[hash % _defaultIconSets.length];

    final icon = notebook.iconName != null
        ? resolveIcon(notebook.iconName!)
        : set.$1;

    final Color color;
    final Color bg;
    if (notebook.colorValue != null) {
      final colorOpt = availableColors
          .where((c) => c.value == notebook.colorValue)
          .firstOrNull;
      color = Color(notebook.colorValue!);
      bg = colorOpt?.bgColor ?? color.withValues(alpha: 0.12);
    } else {
      color = set.$2;
      bg = set.$3;
    }

    final fieldCount = notebook.schema.length;
    final subtitle = notebook.description.isNotEmpty
        ? notebook.description
        : (l10n?.notebookFieldCount(fieldCount) ??
            '$fieldCount fields');

    return NotebookItem(
      dbId: notebook.id,
      icon: icon,
      iconImagePath: notebook.iconImagePath,
      iconColor: color,
      iconBg: bg,
      title: notebook.name,
      subtitle: subtitle,
    );
  }

  /// 复制并替换 recordCount
  NotebookItem withRecordCount(int count) => NotebookItem(
        dbId: dbId,
        icon: icon,
        iconImagePath: iconImagePath,
        iconColor: iconColor,
        iconBg: iconBg,
        title: title,
        subtitle: subtitle,
        recordCount: count,
      );

  /// 根据图标名称解析 IconData
  static IconData resolveIcon(String name) {
    for (final opt in availableIcons) {
      if (opt.icon.codePoint.toString() == name) {
        return opt.icon;
      }
    }
    return Icons.auto_stories_rounded; // 默认
  }
}

/// 图标选项
class NotebookIconOption {
  final IconData icon;
  final String label;

  const NotebookIconOption(this.icon, this.label);
}

/// 颜色选项
class NotebookColorOption {
  final int value;       // 存入数据库的 int 值
  final String label;
  final Color bgColor;   // 浅色背景

  const NotebookColorOption(this.value, this.label, this.bgColor);

  Color get color => Color(value);
}
