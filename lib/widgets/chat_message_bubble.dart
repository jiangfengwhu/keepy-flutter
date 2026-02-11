import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_markdown_plus_latex/flutter_markdown_plus_latex.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/l10n_ext.dart';
import '../models/chat_message.dart';
import '../models/data_record.dart';
import '../models/notebook.dart';
import '../services/tool_executor.dart';
import '../theme/miaoji_theme.dart';

/// 聊天消息气泡组件 — 纸质拟物风格
class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isSystem || message.isTool) return const SizedBox.shrink();

    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _buildAiAvatar(),
            const SizedBox(width: 10),
          ],
          // 用户消息左侧留白，与 AI 头像 + 间距对齐（32 + 10 = 42）
          if (isUser) const SizedBox(width: 42),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // 图片消息
                if (message.hasImages)
                  ...message.imageParts.map(
                    (part) => _buildImageBubble(part, isUser),
                  ),
                // 文本消息
                if (message.content.isNotEmpty || message.isStreaming)
                  _buildTextBubble(isUser),
                if (message.toolResults != null &&
                    message.toolResults!.isNotEmpty)
                  ...message.toolResults!
                      .map((result) => _buildToolResultCard(context, result)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 图片气泡
  Widget _buildImageBubble(ContentPart imagePart, bool isUser) {
    final Uint8List? bytes = imagePart.imageBytes;
    if (bytes == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isUser ? 18 : 4),
          topRight: Radius.circular(isUser ? 4 : 18),
          bottomLeft: const Radius.circular(18),
          bottomRight: const Radius.circular(18),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 220, maxHeight: 280),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withValues(alpha: isUser ? 0.15 : 0.06),
              width: 1,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isUser ? 18 : 4),
              topRight: Radius.circular(isUser ? 4 : 18),
              bottomLeft: const Radius.circular(18),
              bottomRight: const Radius.circular(18),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isUser ? 17 : 3),
              topRight: Radius.circular(isUser ? 3 : 17),
              bottomLeft: const Radius.circular(17),
              bottomRight: const Radius.circular(17),
            ),
            child: Image.memory(
              bytes,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (_, _, _) => Container(
                width: 120,
                height: 80,
                color: Colors.white.withValues(alpha: 0.08),
                child: Icon(
                  Icons.broken_image_outlined,
                  color: const Color(0xFFF5EFE0).withValues(alpha: 0.3),
                  size: 32,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// AI 头像
  Widget _buildAiAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFFD4A24C).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFD4A24C).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: const Icon(Icons.edit_note_rounded, color: Color(0xFFD4A24C), size: 16),
    );
  }

  /// 文本气泡 — 纸张/信纸风格
  Widget _buildTextBubble(bool isUser) {
    final showCursor = message.isStreaming && message.content.isNotEmpty;
    final textColor = isUser
        ? const Color(0xFFF5EFE0)
        : const Color(0xFFF5EFE0).withValues(alpha: 0.9);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isUser
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isUser ? 18 : 4),
          topRight: Radius.circular(isUser ? 4 : 18),
          bottomLeft: const Radius.circular(18),
          bottomRight: const Radius.circular(18),
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: isUser ? 0.15 : 0.06),
          width: 1,
        ),
      ),
      child: message.content.isEmpty && message.isStreaming
          ? _buildTypingIndicator()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                MarkdownBody(
                  data: message.displayContent ?? message.content,
                  selectable: true,
                  shrinkWrap: true,
                  softLineBreak: true,
                  builders: {
                    'latex': LatexElementBuilder(
                      textStyle: TextStyle(color: textColor),
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
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(fontSize: 14, color: textColor, height: 1.5),
                    h1: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                        height: 1.4),
                    h2: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                        height: 1.4),
                    h3: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        height: 1.4),
                    h4: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        height: 1.4),
                    a: const TextStyle(
                      color: Color(0xFFD4A24C),
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0x80D4A24C),
                    ),
                    strong:
                        TextStyle(fontWeight: FontWeight.w700, color: textColor),
                    em: TextStyle(fontStyle: FontStyle.italic, color: textColor),
                    code: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFFD4A24C),
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      fontFamily: 'monospace',
                    ),
                    codeblockDecoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.06),
                        width: 1,
                      ),
                    ),
                    codeblockPadding: const EdgeInsets.all(12),
                    blockquoteDecoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: const Color(0xFFD4A24C).withValues(alpha: 0.5),
                          width: 3,
                        ),
                      ),
                    ),
                    blockquotePadding:
                        const EdgeInsets.only(left: 12, top: 4, bottom: 4),
                    blockquote: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFFF5EFE0).withValues(alpha: 0.7),
                      height: 1.5,
                    ),
                    listBullet: TextStyle(fontSize: 14, color: textColor),
                    listIndent: 20,
                    horizontalRuleDecoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withValues(alpha: 0.12),
                          width: 1,
                        ),
                      ),
                    ),
                    tableBorder: TableBorder.all(
                      color: Colors.white.withValues(alpha: 0.12),
                      width: 1,
                    ),
                    tableHead: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: textColor),
                    tableBody: TextStyle(fontSize: 13, color: textColor),
                    tableCellsPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    pPadding: EdgeInsets.zero,
                    h1Padding: const EdgeInsets.only(bottom: 4),
                    h2Padding: const EdgeInsets.only(bottom: 4),
                    h3Padding: const EdgeInsets.only(bottom: 2),
                    blockSpacing: 8,
                  ),
                ),
                if (showCursor)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '●',
                      style: TextStyle(
                        color: const Color(0xFFD4A24C).withValues(alpha: 0.6),
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Dot(delay: 0),
        const SizedBox(width: 4),
        _Dot(delay: 1),
        const SizedBox(width: 4),
        _Dot(delay: 2),
      ],
    );
  }

  // ── Tool Result Card 分发 ─────────────────────

  Widget _buildToolResultCard(BuildContext context, ToolResult result) {
    final uiData = result.uiData;
    if (uiData == null) {
      return _GenericToolCard(result: result);
    }

    final action = uiData['action'] as String?;
    switch (action) {
      case 'create_schema':
        final nb = uiData['notebook'];
        if (nb is Notebook) return _NotebookCreatedCard(notebook: nb);
        return _GenericToolCard(result: result);

      case 'add_record':
        final record = uiData['record'];
        final type = uiData['type'] as String? ?? '';
        if (record is DataRecord) {
          return _RecordActionCard(
            title: context.l10n.recordAddedSuccess,
            icon: Icons.add_circle_outline_rounded,
            color: MiaojiColors.success,
            notebookName: type,
            record: record,
          );
        }
        return _GenericToolCard(result: result);

      case 'update_record':
        final record = uiData['record'];
        if (record is DataRecord) {
          return _RecordActionCard(
            title: context.l10n.recordUpdatedSuccess,
            icon: Icons.edit_outlined,
            color: MiaojiColors.info,
            notebookName: record.notebookName,
            record: record,
          );
        }
        return _GenericToolCard(result: result);

      case 'delete_record':
        final record = uiData['record'];
        final deletedId = uiData['deleted_id'];
        return _DeletedCard(
          recordId: deletedId is int ? deletedId : 0,
          record: record is DataRecord ? record : null,
        );

      case 'get_record':
        final records = uiData['records'];
        if (records is List<DataRecord>) {
          return _QueryResultsCard(
            records: records,
            query: uiData['query'] as String?,
            type: uiData['type'] as String?,
          );
        }
        return _GenericToolCard(result: result);

      case 'update_schema':
        final nb = uiData['notebook'];
        if (nb is Notebook) return _NotebookUpdatedCard(notebook: nb);
        return _GenericToolCard(result: result);

      case 'delete_schema':
        final name = uiData['name'] as String? ?? '';
        final nb = uiData['notebook'];
        return _SchemaDeletedCard(
          name: name,
          notebook: nb is Notebook ? nb : null,
        );

      default:
        return _GenericToolCard(result: result);
    }
  }
}

// ═══════════════════════════════════════════════
//  小本创建成功卡片 — 新本子诞生
// ═══════════════════════════════════════════════

class _NotebookCreatedCard extends StatelessWidget {
  final Notebook notebook;
  const _NotebookCreatedCard({required this.notebook});

  static const _iconColors = [
    (Icons.auto_stories_rounded, Color(0xFFB896D6)),
    (Icons.fitness_center_rounded, Color(0xFFE07B63)),
    (Icons.restaurant_rounded, Color(0xFFE8BD6A)),
    (Icons.medication_rounded, Color(0xFF7DB87C)),
    (Icons.payments_rounded, Color(0xFF7FA5C8)),
    (Icons.school_rounded, Color(0xFFE07044)),
    (Icons.flight_rounded, Color(0xFF7FB8C8)),
  ];

  @override
  Widget build(BuildContext context) {
    final hash = notebook.name.hashCode.abs();
    final (icon, iconColor) = _iconColors[hash % _iconColors.length];

    return _ToolCardWrapper(
      statusColor: MiaojiColors.success,
      statusIcon: Icons.check_rounded,
      statusText: context.l10n.notebookCreatedSuccess,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: iconColor.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notebook.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF5EFE0),
                      ),
                    ),
                    if (notebook.description.isNotEmpty)
                      Text(
                        notebook.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFFF5EFE0).withValues(alpha: 0.5),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (notebook.schema.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children:
                  notebook.schema.take(6).map(_buildFieldTag).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFieldTag(SchemaField field) {
    final (iconData, color) = switch (field.type) {
      'string' => (Icons.text_fields_rounded, const Color(0xFF7FA5C8)),
      'number' => (Icons.tag_rounded, const Color(0xFFE8BD6A)),
      'date' => (Icons.calendar_today_rounded, const Color(0xFFB896D6)),
      _ => (Icons.data_object_rounded, const Color(0xFFB8A48A)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.08), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            field.field,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFF5EFE0).withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  小本更新成功卡片
// ═══════════════════════════════════════════════

class _NotebookUpdatedCard extends StatelessWidget {
  final Notebook notebook;
  const _NotebookUpdatedCard({required this.notebook});

  @override
  Widget build(BuildContext context) {
    return _ToolCardWrapper(
      statusColor: MiaojiColors.info,
      statusIcon: Icons.edit_outlined,
      statusText: context.l10n.notebookUpdatedSuccess,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: MiaojiColors.info.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: MiaojiColors.info.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Icon(Icons.book_rounded,
                    size: 18, color: const Color(0xFF7FA5C8)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notebook.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF5EFE0),
                      ),
                    ),
                    if (notebook.description.isNotEmpty)
                      Text(
                        notebook.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFFF5EFE0).withValues(alpha: 0.5),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (notebook.schema.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              context.l10n.notebookUpdatedFields(
                notebook.schema.length,
                notebook.schema.map((f) => f.field).join(
                      context.l10n.listSeparator,
                    ),
              ),
              style: TextStyle(
                fontSize: 12,
                color: const Color(0xFFF5EFE0).withValues(alpha: 0.7),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  小本删除卡片
// ═══════════════════════════════════════════════

class _SchemaDeletedCard extends StatelessWidget {
  final String name;
  final Notebook? notebook;

  const _SchemaDeletedCard({required this.name, this.notebook});

  @override
  Widget build(BuildContext context) {
    return _ToolCardWrapper(
      statusColor: MiaojiColors.error,
      statusIcon: Icons.delete_outline_rounded,
      statusText: context.l10n.notebookDeletedSuccess,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: MiaojiColors.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: MiaojiColors.error.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Icon(Icons.delete_rounded,
                size: 18, color: MiaojiColors.error),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.notebookDeletedName(name),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF5EFE0),
                  ),
                ),
                Text(
                  context.l10n.notebookDeletedDesc,
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFFF5EFE0).withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  记录操作卡片（添加/更新）
// ═══════════════════════════════════════════════

class _RecordActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String notebookName;
  final DataRecord record;

  const _RecordActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.notebookName,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    return _ToolCardWrapper(
      statusColor: color,
      statusIcon: icon,
      statusText: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.book_rounded, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                notebookName,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const Spacer(),
              Text(
                '#${record.id ?? ''}',
                style: TextStyle(
                  fontSize: 11,
                  color: const Color(0xFFF5EFE0).withValues(alpha: 0.35),
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...record.data.entries.take(5).map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(
                        e.key,
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFFF5EFE0).withValues(alpha: 0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${e.value}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFF5EFE0),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),
          if (record.data.length > 5)
            Text(
              context.l10n.recordMoreFields(record.data.length - 5),
              style: TextStyle(
                  fontSize: 11, color: const Color(0xFFF5EFE0).withValues(alpha: 0.35)),
            ),
          // 提醒标签
          if (record.reminderAt != null) ...[
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: MiaojiColors.info.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: MiaojiColors.info.withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_outlined,
                      size: 12, color: MiaojiColors.info),
                  const SizedBox(width: 4),
                  Text(
                    context.l10n.recordReminderLabel(
                      _formatReminderTime(context, record.reminderAt!),
                    ),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: MiaojiColors.info,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _formatReminderTime(BuildContext context, DateTime time) {
    final now = DateTime.now();
    final diff = time.difference(now);
    final l10n = context.l10n;
    if (diff.isNegative) return l10n.reminderExpired;
    if (diff.inMinutes < 60) return l10n.reminderInMinutes(diff.inMinutes);
    if (diff.inHours < 24) return l10n.reminderInHours(diff.inHours);
    if (diff.inDays < 7) return l10n.reminderInDays(diff.inDays);
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMd(locale).add_Hm().format(time);
  }
}

// ═══════════════════════════════════════════════
//  记录删除成功卡片
// ═══════════════════════════════════════════════

class _DeletedCard extends StatelessWidget {
  final int recordId;
  final DataRecord? record;

  const _DeletedCard({required this.recordId, this.record});

  @override
  Widget build(BuildContext context) {
    return _ToolCardWrapper(
      statusColor: MiaojiColors.error,
      statusIcon: Icons.delete_outline_rounded,
      statusText: context.l10n.recordDeletedSuccess,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: MiaojiColors.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: MiaojiColors.error.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.delete_rounded,
              size: 18,
              color: MiaojiColors.error,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record != null
                      ? context.l10n.recordDeletedFromNotebook(
                          record!.notebookName,
                        )
                      : context.l10n.recordDeleted,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF5EFE0),
                  ),
                ),
                Text(
                  context.l10n.recordIdLabel(recordId),
                  style: TextStyle(
                    fontSize: 11,
                    color: const Color(0xFFF5EFE0).withValues(alpha: 0.35),
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  查询结果卡片
// ═══════════════════════════════════════════════

class _QueryResultsCard extends StatelessWidget {
  final List<DataRecord> records;
  final String? query;
  final String? type;

  const _QueryResultsCard({
    required this.records,
    this.query,
    this.type,
  });

  @override
  Widget build(BuildContext context) {
    return _ToolCardWrapper(
      statusColor: MiaojiColors.primary,
      statusIcon: Icons.search_rounded,
      statusText: context.l10n.queryResultsCount(records.length),
      child: records.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  context.l10n.queryNoResults,
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFFF5EFE0).withValues(alpha: 0.5),
                  ),
                ),
              ),
            )
          : Column(
              children: records.take(3).map((record) {
                final entries = record.data.entries.take(3).toList();
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            record.notebookName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFE8BD6A),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '#${record.id}',
                            style: TextStyle(
                              fontSize: 10,
                              color: const Color(0xFFF5EFE0).withValues(alpha: 0.35),
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ...entries.map((e) => Text(
                            '${e.key}: ${e.value}',
                            style: TextStyle(
                              fontSize: 11,
                              color: const Color(0xFFF5EFE0).withValues(alpha: 0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}

// ═══════════════════════════════════════════════
//  通用 Tool 卡片（fallback）
// ═══════════════════════════════════════════════

class _GenericToolCard extends StatelessWidget {
  final ToolResult result;
  const _GenericToolCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return _ToolCardWrapper(
      statusColor: result.success ? MiaojiColors.success : MiaojiColors.error,
      statusIcon:
          result.success ? Icons.check_rounded : Icons.error_outline_rounded,
      statusText: result.success
          ? context.l10n.toolResultSuccess(result.toolName)
          : context.l10n.toolResultFailure(result.toolName),
      child: const SizedBox.shrink(),
    );
  }
}

// ═══════════════════════════════════════════════
//  Tool 卡片通用外壳 — 纸质便签风格
// ═══════════════════════════════════════════════

class _ToolCardWrapper extends StatelessWidget {
  final Color statusColor;
  final IconData statusIcon;
  final String statusText;
  final Widget child;

  const _ToolCardWrapper({
    required this.statusColor,
    required this.statusIcon,
    required this.statusText,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部状态条
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.06),
                    width: 1,
                  ),
                ),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(13)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.35),
                        width: 1,
                      ),
                    ),
                    child:
                        Icon(statusIcon, size: 12, color: statusColor),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),

            // 内容区
            if (child is! SizedBox)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: child,
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  打字指示器（墨水滴落动画）
// ═══════════════════════════════════════════════

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay * 200), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: MiaojiColors.primary.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
