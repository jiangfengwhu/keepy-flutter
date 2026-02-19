import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import '../l10n/l10n_ext.dart';
import '../models/data_record.dart';
import '../models/notebook.dart';
import '../models/notebook_item.dart';
import '../services/database_service.dart';
import '../services/grep_search_service.dart';
import '../theme/miaoji_theme.dart';
import 'notebook_detail_page.dart';

/// 全局搜索页面 — grep 风格正则搜索
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _db = DatabaseService();
  final _grep = GrepSearchService();

  Timer? _debounce;
  List<DataRecord> _results = [];
  RegExp? _highlightRegex;
  bool _hasSearched = false;
  bool _isSearching = false;
  int _searchGeneration = 0;

  final Map<String, Notebook> _notebookCache = {};

  @override
  void initState() {
    super.initState();
    _loadNotebooks();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadNotebooks() async {
    final notebooks = await _db.getAllNotebooks();
    for (final nb in notebooks) {
      _notebookCache[nb.name] = nb;
    }
  }

  void _onSearchChanged(String text) {
    _debounce?.cancel();
    if (text.trim().isEmpty) {
      setState(() {
        _results = [];
        _highlightRegex = null;
        _hasSearched = false;
        _isSearching = false;
      });
      return;
    }
    setState(() => _isSearching = true);
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final gen = ++_searchGeneration;
      final pattern = text.trim();
      final records = await _grep.grep(pattern: pattern, limit: 50);
      if (!mounted || gen != _searchGeneration) return;
      setState(() {
        _results = records;
        _highlightRegex = GrepSearchService.buildRegex(pattern);
        _hasSearched = true;
        _isSearching = false;
      });
    });
  }

  void _openNotebookDetail(DataRecord record) {
    final nb = _notebookCache[record.notebookName];
    if (nb == null) return;
    final item = NotebookItem.fromNotebook(nb, l10n: context.l10n);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NotebookDetailPage(notebookItem: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final safePadding = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: MiaojiColors.background,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(16, safePadding.top + 8, 16, 12),
            decoration: BoxDecoration(
              color: MiaojiColors.background,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: MiaojiColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: MiaojiColors.borderLight, width: 1),
                    ),
                    child: const Icon(Icons.arrow_back_rounded,
                        size: 18, color: MiaojiColors.textSecondary),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: MiaojiColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: MiaojiColors.borderLight, width: 1),
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      onChanged: _onSearchChanged,
                      style: const TextStyle(
                        fontSize: 15,
                        color: MiaojiColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: context.l10n.searchHint,
                        hintStyle: const TextStyle(
                          color: MiaojiColors.textHint,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(Icons.search_rounded,
                            size: 20, color: MiaojiColors.textHint),
                        suffixIcon: _controller.text.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  _controller.clear();
                                  _onSearchChanged('');
                                },
                                child: const Icon(Icons.close_rounded,
                                    size: 18, color: MiaojiColors.textHint),
                              )
                            : null,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 11),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isSearching
                ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: MiaojiColors.primary,
                    ),
                  )
                : !_hasSearched
                    ? _buildEmptyHint()
                    : _results.isEmpty
                        ? _buildNoResults()
                        : _buildResultList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHint() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_rounded,
              size: 48,
              color: MiaojiColors.textHint.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(
            context.l10n.searchEmptyHint,
            style: const TextStyle(
              fontSize: 14,
              color: MiaojiColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded,
              size: 48,
              color: MiaojiColors.textHint.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(
            context.l10n.searchNoResultsTitle,
            style: const TextStyle(
              fontSize: 14,
              color: MiaojiColors.textTertiary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.searchNoResultsHint,
            style: TextStyle(
              fontSize: 12,
              color: MiaojiColors.textHint.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  // ── 结果列表（按 notebook 分组）──

  Widget _buildResultList() {
    final grouped = <String, List<DataRecord>>{};
    for (final r in _results) {
      grouped.putIfAbsent(r.notebookName, () => []).add(r);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      physics: const BouncingScrollPhysics(),
      itemCount: grouped.length,
      itemBuilder: (context, groupIndex) {
        final notebookName = grouped.keys.elementAt(groupIndex);
        final records = grouped[notebookName]!;
        final nb = _notebookCache[notebookName];
        final nbItem =
            nb != null ? NotebookItem.fromNotebook(nb, l10n: context.l10n) : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (groupIndex > 0) const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                if (nbItem != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          NotebookDetailPage(notebookItem: nbItem),
                    ),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 4),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: (nbItem?.iconBg ?? MiaojiColors.surfaceVariant)
                            .withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _buildNotebookGroupIcon(nbItem),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      notebookName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: MiaojiColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      context.l10n.searchRecordCount(records.length),
                      style: const TextStyle(
                        fontSize: 11,
                        color: MiaojiColors.textHint,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right_rounded,
                        size: 18, color: MiaojiColors.textHint),
                  ],
                ),
              ),
            ),
            ...records.map((record) => _buildRecordCard(record, nbItem)),
          ],
        );
      },
    );
  }

  // ── 单条记录卡片 ──

  Widget _buildRecordCard(DataRecord record, NotebookItem? nbItem) {
    final entries = record.data.entries
        .where((e) => (e.value?.toString() ?? '').isNotEmpty)
        .toList();
    if (entries.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => _openNotebookDetail(record),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: MiaojiColors.card,
          borderRadius: BorderRadius.circular(MiaojiRadius.md),
          border: Border.all(color: MiaojiColors.borderLight, width: 1),
          boxShadow: MiaojiShadows.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...entries.take(3).map((entry) {
              final value = entry.value.toString();
              final hasMatch = _highlightRegex?.hasMatch(value) ?? false;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 12,
                          color: hasMatch
                              ? MiaojiColors.primary.withValues(alpha: 0.7)
                              : MiaojiColors.textHint,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: hasMatch
                          ? _buildHighlightText(value, _highlightRegex!)
                          : Text(
                              value,
                              style: const TextStyle(
                                fontSize: 13,
                                color: MiaojiColors.textSecondary,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                  ],
                ),
              );
            }),
            if (entries.length > 3)
              Text(
                context.l10n.searchMoreFields(entries.length - 3),
                style: const TextStyle(
                  fontSize: 11,
                  color: MiaojiColors.textHint,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              _formatTime(record.updatedAt),
              style: const TextStyle(
                fontSize: 10,
                color: MiaojiColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 用正则在文本中做高亮
  Widget _buildHighlightText(String text, RegExp regex) {
    final matches = regex.allMatches(text).where((m) => m.start != m.end).toList();
    if (matches.isEmpty) {
      return Text(
        text,
        style: const TextStyle(
            fontSize: 13, color: MiaojiColors.textSecondary, height: 1.3),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    final spans = <InlineSpan>[];
    var cursor = 0;

    for (final m in matches) {
      if (m.start > cursor) {
        spans.add(TextSpan(
          text: text.substring(cursor, m.start),
          style: const TextStyle(
              fontSize: 13, color: MiaojiColors.textSecondary, height: 1.3),
        ));
      }
      spans.add(TextSpan(
        text: text.substring(m.start, m.end),
        style: const TextStyle(
          fontSize: 13,
          color: MiaojiColors.primary,
          fontWeight: FontWeight.w700,
          height: 1.3,
        ),
      ));
      cursor = m.end;
    }

    if (cursor < text.length) {
      spans.add(TextSpan(
        text: text.substring(cursor),
        style: const TextStyle(
            fontSize: 13, color: MiaojiColors.textSecondary, height: 1.3),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) {
      return '今天 ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return '昨天 ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} 天前';
    }
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  Widget _buildNotebookGroupIcon(NotebookItem? item) {
    final notebookItem = item;
    final imagePath = notebookItem?.iconImagePath;
    if (imagePath != null && imagePath.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: Image.file(
          File(imagePath),
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) {
            return Icon(
              notebookItem!.icon,
              size: 14,
              color: notebookItem.iconColor,
            );
          },
        ),
      );
    }
    return Icon(
      item?.icon ?? Icons.menu_book_rounded,
      size: 14,
      color: item?.iconColor ?? MiaojiColors.textHint,
    );
  }
}
