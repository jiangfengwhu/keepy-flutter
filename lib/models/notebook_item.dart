import 'package:flutter/material.dart';

/// 首页笔记本列表项数据模型
class NotebookItem {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;

  const NotebookItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
  });
}
