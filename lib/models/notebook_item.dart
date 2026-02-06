import 'package:flutter/material.dart';
import 'notebook.dart';

/// 首页笔记本列表项数据模型
class NotebookItem {
  final int? dbId; // 数据库 ID
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;

  const NotebookItem({
    this.dbId,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
  });

  /// 图标样式集
  static const _iconSets = [
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
  factory NotebookItem.fromNotebook(Notebook notebook) {
    final hash = notebook.name.hashCode.abs();
    final (icon, color, bg) = _iconSets[hash % _iconSets.length];

    final fieldCount = notebook.schema.length;
    final subtitle = notebook.description.isNotEmpty
        ? notebook.description
        : '$fieldCount 个字段';

    return NotebookItem(
      dbId: notebook.id,
      icon: icon,
      iconColor: color,
      iconBg: bg,
      title: notebook.name,
      subtitle: subtitle,
    );
  }
}
