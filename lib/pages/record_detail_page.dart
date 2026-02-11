import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_markdown_plus_latex/flutter_markdown_plus_latex.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';

import '../models/data_record.dart';
import '../models/notebook.dart';
import '../l10n/l10n_ext.dart';
import '../theme/miaoji_theme.dart';

/// 记录阅读页 — 纯沉浸式 Markdown 阅读
class RecordDetailPage extends StatelessWidget {
  final DataRecord record;
  final List<SchemaField> schema;
  final Color accentColor;

  const RecordDetailPage({
    super.key,
    required this.record,
    required this.schema,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final safePadding = MediaQuery.of(context).padding;
    final data = record.data;

    final metaFields = schema.where((f) => f.type != 'string').toList();
    final textFields = schema.where((f) => f.type == 'string').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F2),
      body: Stack(
        children: [
          // 正文
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              28, safePadding.top + 48, 28, safePadding.bottom + 40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 元信息（数字/日期字段）
                if (metaFields.isNotEmpty) ...[
                  ...metaFields.map((field) {
                    final value = data[field.field];
                    final display = _formatValue(value, field.type);
                    if (display.isEmpty || display == '-') {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '${field.field}  $display',
                        style: TextStyle(
                          fontSize: 13,
                          color: MiaojiColors.textTertiary,
                          height: 1.6,
                          letterSpacing: 0.3,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                ],

                // 文本字段——连续渲染
                ...textFields.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final field = entry.value;
                  final value = data[field.field];
                  final isEmpty = value == null ||
                      (value is String && value.trim().isEmpty);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (textFields.length > 1 && idx > 0) ...[
                        const SizedBox(height: 28),
                        Text(
                          field.field,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: MiaojiColors.textHint,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (isEmpty)
                        Text(
                          context.l10n.recordEmptyContent,
                          style: TextStyle(
                            fontSize: 15,
                            color:
                                MiaojiColors.textHint.withValues(alpha: 0.4),
                            fontStyle: FontStyle.italic,
                            height: 1.8,
                          ),
                        )
                      else
                        MarkdownBody(
                          data: value.toString(),
                          selectable: true,
                          shrinkWrap: true,
                          softLineBreak: true,
                          builders: {
                            'latex': LatexElementBuilder(
                              textStyle: const TextStyle(
                                color: MiaojiColors.textPrimary,
                              ),
                            ),
                          },
                          extensionSet: md.ExtensionSet(
                            [LatexBlockSyntax()],
                            [LatexInlineSyntax()],
                          ),
                          onTapLink: (text, href, title) {
                            if (href != null) {
                              launchUrl(Uri.parse(href),
                                  mode: LaunchMode.externalApplication);
                            }
                          },
                          styleSheet: _markdownStyle(),
                        ),
                    ],
                  );
                }),

                // 底部时间
                const SizedBox(height: 48),
                Text(
                  _formatDateTime(record.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: MiaojiColors.textHint.withValues(alpha: 0.35),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // 顶部返回按钮
          Positioned(
            left: 20,
            top: safePadding.top + 8,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCF9F2).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 13,
                      color: MiaojiColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      context.l10n.backAction,
                      style: TextStyle(
                        fontSize: 13,
                        color: MiaojiColors.textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 工具方法 ──────────────────────────────

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatValue(dynamic value, String type) {
    if (value == null) return '-';
    if (type == 'date' && value is String && value.isNotEmpty) {
      final dt = DateTime.tryParse(value);
      if (dt != null) {
        return '${dt.year}-'
            '${dt.month.toString().padLeft(2, '0')}-'
            '${dt.day.toString().padLeft(2, '0')} '
            '${dt.hour.toString().padLeft(2, '0')}:'
            '${dt.minute.toString().padLeft(2, '0')}:'
            '${dt.second.toString().padLeft(2, '0')}';
      }
    }
    return value.toString();
  }

  MarkdownStyleSheet _markdownStyle() {
    const textColor = MiaojiColors.textPrimary;
    return MarkdownStyleSheet(
      p: const TextStyle(
        fontSize: 16,
        color: textColor,
        height: 1.9,
        letterSpacing: 0.2,
      ),
      h1: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textColor,
        height: 1.5,
      ),
      h2: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textColor,
        height: 1.5,
      ),
      h3: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.5,
      ),
      a: TextStyle(
        color: MiaojiColors.primary,
        decoration: TextDecoration.underline,
        decorationColor: MiaojiColors.primary.withValues(alpha: 0.5),
      ),
      strong: const TextStyle(fontWeight: FontWeight.w700, color: textColor),
      em: const TextStyle(fontStyle: FontStyle.italic, color: textColor),
      code: TextStyle(
        fontSize: 13,
        color: MiaojiColors.primaryDark,
        backgroundColor: MiaojiColors.surfaceVariant,
        fontFamily: 'monospace',
      ),
      codeblockDecoration: BoxDecoration(
        color: MiaojiColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: MiaojiColors.borderLight),
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: MiaojiColors.textHint.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
      ),
      blockquotePadding: const EdgeInsets.only(left: 16),
      listBullet:
          const TextStyle(fontSize: 16, color: textColor, height: 1.9),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: MiaojiColors.divider.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
    );
  }
}
