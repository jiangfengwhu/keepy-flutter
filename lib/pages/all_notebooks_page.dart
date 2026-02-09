import 'package:flutter/material.dart';
import '../l10n/l10n_ext.dart';
import '../models/notebook_item.dart';
import '../theme/miaoji_theme.dart';
import '../widgets/notebook_tile.dart';
import 'notebook_detail_page.dart';

/// 全部妙记本页面
class AllNotebooksPage extends StatelessWidget {
  final List<NotebookItem> notebooks;

  const AllNotebooksPage({super.key, required this.notebooks});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MiaojiColors.background,
      appBar: AppBar(
        backgroundColor: MiaojiColors.background,
        title: Text(
          context.l10n.allNotebooksTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                context.l10n.notebookCount(notebooks.length),
                style: const TextStyle(
                  fontSize: 13,
                  color: MiaojiColors.textHint,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      body: notebooks.isEmpty
          ? Center(
              child: Text(
                context.l10n.emptyAllNotebooks,
                style: const TextStyle(
                    fontSize: 15, color: MiaojiColors.textTertiary),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              physics: const BouncingScrollPhysics(),
              itemCount: notebooks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final item = notebooks[index];
                return NotebookTile(
                  item: item,
                  onTap: () {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (_) =>
                                NotebookDetailPage(notebookItem: item),
                          ),
                        )
                        .then((_) => Navigator.of(context).pop());
                  },
                );
              },
            ),
    );
  }
}
