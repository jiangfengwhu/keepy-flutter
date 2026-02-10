import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../l10n/l10n_ext.dart';
import '../models/notebook.dart';
import '../models/notebook_item.dart';
import '../services/database_service.dart';
import '../theme/miaoji_theme.dart';

/// 编辑结果，包含 schema 变更信息
class NotebookEditResult {
  final Notebook notebook;
  final Map<String, String> renamedFields; // oldName -> newName
  final List<String> removedFields;

  const NotebookEditResult({
    required this.notebook,
    this.renamedFields = const {},
    this.removedFields = const [],
  });
}

class NotebookEditPage extends StatefulWidget {
  /// 传入已有 Notebook 时为编辑模式，null 为新建模式
  final Notebook? existingNotebook;

  const NotebookEditPage({super.key, this.existingNotebook});

  bool get isEditMode => existingNotebook != null;

  @override
  State<NotebookEditPage> createState() => _NotebookEditPageState();
}

class _NotebookEditPageState extends State<NotebookEditPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  final List<DataFieldDefinition> _fields = [];

  /// 编辑模式下，已被删除的原有字段名
  final List<String> _removedFieldNames = [];

  /// 图标和颜色选择
  late int _selectedIconIndex;
  late int _selectedColorIndex;
  String? _iconImagePath;

  late AnimationController _enterController;

  bool get _isEditMode => widget.isEditMode;

  @override
  void initState() {
    super.initState();
    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _enterController.forward();

    // 编辑模式：预填充数据
    if (_isEditMode) {
      final nb = widget.existingNotebook!;
      _nameController.text = nb.name;
      _descController.text = nb.description;
      _fields.addAll(
        nb.schema.map((f) => DataFieldDefinition.fromSchemaField(f)),
      );

      // 恢复图标选择
      _selectedIconIndex = 0;
      if (nb.iconName != null) {
        for (var i = 0; i < NotebookItem.availableIcons.length; i++) {
          if (NotebookItem.availableIcons[i].icon.codePoint.toString() ==
              nb.iconName) {
            _selectedIconIndex = i;
            break;
          }
        }
      }

      // 恢复颜色选择
      _selectedColorIndex = 0;
      if (nb.colorValue != null) {
        for (var i = 0; i < NotebookItem.availableColors.length; i++) {
          if (NotebookItem.availableColors[i].value == nb.colorValue) {
            _selectedColorIndex = i;
            break;
          }
        }
      }
      _iconImagePath = nb.iconImagePath;
    } else {
      _selectedIconIndex = 0;
      _selectedColorIndex = 0;
      _iconImagePath = null;
    }
  }

  @override
  void dispose() {
    _enterController.dispose();
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _addField() {
    HapticFeedback.lightImpact();
    setState(() {
      _fields.add(DataFieldDefinition(name: '', type: DataFieldType.text));
    });
  }

  void _removeField(int index) {
    HapticFeedback.lightImpact();
    final field = _fields[index];

    // 编辑模式下记录被删除的原有字段名
    if (field.isExisting && field.originalName != null) {
      _removedFieldNames.add(field.originalName!);
    }

    setState(() {
      _fields.removeAt(index);
    });
  }

  Future<void> _saveNotebook() async {
    if (_formKey.currentState!.validate()) {
      if (_fields.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.schemaAddAtLeastOneField)),
        );
        return;
      }

      // 检查字段名是否有空的
      for (final f in _fields) {
        if (f.name.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.fieldNameRequired)),
          );
          return;
        }
      }

      if (_isEditMode) {
        await _updateNotebook();
      } else {
        await _createNotebook();
      }
    }
  }

  Future<void> _createNotebook() async {
    final selectedIcon = NotebookItem.availableIcons[_selectedIconIndex];
    final selectedColor = NotebookItem.availableColors[_selectedColorIndex];
    final hasCustomImage = _iconImagePath != null && _iconImagePath!.isNotEmpty;
    final iconNameForSave = hasCustomImage
        ? ''
        : selectedIcon.icon.codePoint.toString();

    final notebook = Notebook(
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      schema: _fields.map((f) => f.toSchemaField()).toList(),
      iconName: iconNameForSave,
      iconImagePath: hasCustomImage ? _iconImagePath : null,
      colorValue: selectedColor.value,
    );

    try {
      await DatabaseService().createNotebook(notebook);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.notebookSaved)),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.saveFailed(e.toString()))),
      );
    }
  }

  Future<void> _updateNotebook() async {
    final nb = widget.existingNotebook!;
    final newName = _nameController.text.trim();
    final newDesc = _descController.text.trim();
    final newSchema = _fields.map((f) => f.toSchemaField()).toList();

    // 计算重命名映射
    final renamedFields = <String, String>{};
    for (final field in _fields) {
      if (field.isExisting &&
          field.originalName != null &&
          field.originalName != field.name.trim()) {
        renamedFields[field.originalName!] = field.name.trim();
      }
    }

    final selectedIcon = NotebookItem.availableIcons[_selectedIconIndex];
    final selectedColor = NotebookItem.availableColors[_selectedColorIndex];
    final hasCustomImage = _iconImagePath != null && _iconImagePath!.isNotEmpty;
    final iconNameForSave = hasCustomImage
        ? ''
        : selectedIcon.icon.codePoint.toString();
    final oldIconName = nb.iconName ?? '';
    final normalizedImagePath = hasCustomImage ? _iconImagePath! : null;
    final newColorVal = selectedColor.value;

    try {
      final updated = await DatabaseService().updateNotebookFull(
        notebookId: nb.id!,
        oldName: nb.name,
        newName: newName != nb.name ? newName : null,
        newDescription: newDesc != nb.description ? newDesc : null,
        newSchema: newSchema,
        newIconName: iconNameForSave != oldIconName ? iconNameForSave : null,
        newIconImagePath: normalizedImagePath == nb.iconImagePath
            ? null
            : (normalizedImagePath ?? ''),
        newColorValue: newColorVal != nb.colorValue ? newColorVal : null,
        renamedFields: renamedFields,
        removedFields: _removedFieldNames,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.notebookUpdated)),
      );

      // 返回编辑结果给详情页
      Navigator.of(context).pop(NotebookEditResult(
        notebook: updated!,
        renamedFields: renamedFields,
        removedFields: _removedFieldNames,
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.updateFailed(e.toString()))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MiaojiColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppearanceSection(),
              const SizedBox(height: 28),
              _buildBasicInfoSection(),
              const SizedBox(height: 28),
              _buildStructureSection(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: MiaojiColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: MiaojiColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: MiaojiShadows.sm,
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: MiaojiColors.textSecondary,
          ),
        ),
      ),
      title: Text(
        _isEditMode
            ? context.l10n.editNotebookTitle
            : context.l10n.createNotebookTitle,
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: _saveNotebook,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5A4532), Color(0xFF8B6914)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(MiaojiRadius.full),
                boxShadow: [
                  BoxShadow(
                    color: MiaojiColors.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                _isEditMode
                    ? context.l10n.saveAction
                    : context.l10n.doneAction,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── 外观选择区域 ───────────────────────────

  Widget _buildAppearanceSection() {
    final selectedIcon = NotebookItem.availableIcons[_selectedIconIndex];
    final selectedColor = NotebookItem.availableColors[_selectedColorIndex];

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.15),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      )),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _enterController,
          curve: const Interval(0.0, 0.4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              context.l10n.appearanceSectionTitle,
              Icons.palette_outlined,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: MiaojiColors.surface,
                borderRadius: BorderRadius.circular(MiaojiRadius.xl),
                boxShadow: MiaojiShadows.md,
                border: Border.all(
                  color: MiaojiColors.borderLight,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // 预览
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: selectedColor.bgColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: selectedColor.color.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              selectedColor.color.withValues(alpha: 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _buildIconPreview(selectedIcon.icon, selectedColor),
                  ),
                  const SizedBox(height: 20),

                  // 颜色选择
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      context.l10n.colorLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: MiaojiColors.textTertiary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(
                      NotebookItem.availableColors.length,
                      (i) {
                        final opt = NotebookItem.availableColors[i];
                        final isSelected = i == _selectedColorIndex;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedColorIndex = i);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: opt.color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? MiaojiColors.textPrimary
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: opt.color
                                            .withValues(alpha: 0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 图标上传 + 选择
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      context.l10n.iconLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: MiaojiColors.textTertiary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickIconImage,
                          icon: const Icon(Icons.photo_library_outlined, size: 16),
                          label: const Text('上传图片'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: MiaojiColors.textSecondary,
                            side: const BorderSide(color: MiaojiColors.borderLight),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      if (_iconImagePath != null && _iconImagePath!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: '移除图片',
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            setState(() => _iconImagePath = null);
                          },
                          icon: const Icon(Icons.delete_outline_rounded, size: 18),
                          color: MiaojiColors.textTertiary,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemCount: NotebookItem.availableIcons.length,
                    itemBuilder: (context, i) {
                      final opt = NotebookItem.availableIcons[i];
                      final isSelected = i == _selectedIconIndex;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _selectedIconIndex = i;
                            _iconImagePath = null;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? selectedColor.color
                                    .withValues(alpha: 0.12)
                                : MiaojiColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? selectedColor.color
                                      .withValues(alpha: 0.4)
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            opt.icon,
                            size: 20,
                            color: isSelected
                                ? selectedColor.color
                                : MiaojiColors.textTertiary,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 基本信息区域 ───────────────────────────

  Widget _buildBasicInfoSection() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.15),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      )),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _enterController,
          curve: const Interval(0.0, 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              context.l10n.basicInfoSectionTitle,
              Icons.info_outline_rounded,
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: MiaojiColors.surface,
                borderRadius: BorderRadius.circular(MiaojiRadius.xl),
                boxShadow: MiaojiShadows.md,
                border: Border.all(
                  color: MiaojiColors.borderLight,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // 名称输入
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: context.l10n.notebookNameLabel,
                        hintText: context.l10n.notebookNameHint,
                        prefixIcon: Container(
                          margin: const EdgeInsets.only(right: 12),
                          child: const Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: MiaojiColors.primary,
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        filled: false,
                      ),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: MiaojiColors.textPrimary,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return context.l10n.notebookNameRequired;
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(
                      height: 1,
                      color: MiaojiColors.divider.withValues(alpha: 0.5),
                    ),
                  ),
                  // 描述输入
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: TextFormField(
                      controller: _descController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: context.l10n.notebookDescLabel,
                        hintText: context.l10n.notebookDescHint,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        filled: false,
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: MiaojiColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStructureSection() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.15),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      )),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _enterController,
          curve: const Interval(0.2, 0.7),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle(
                  context.l10n.schemaSectionTitle,
                  Icons.account_tree_outlined,
                ),
                GestureDetector(
                  onTap: _addField,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: MiaojiColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(MiaojiRadius.full),
                      border: Border.all(
                        color: MiaojiColors.primary.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded,
                            size: 16, color: MiaojiColors.primary),
                        SizedBox(width: 4),
                        Text(
                          context.l10n.addFieldAction,
                          style: const TextStyle(
                            color: MiaojiColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_fields.isEmpty)
              _buildEmptyState()
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _fields.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildFieldCard(index, Key(_fields[index].id));
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: MiaojiColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: MiaojiColors.primary),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: MiaojiColors.textSecondary,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: MiaojiColors.surface,
        borderRadius: BorderRadius.circular(MiaojiRadius.xl),
        border: Border.all(
          color: MiaojiColors.borderLight,
          width: 1.5,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
        boxShadow: MiaojiShadows.sm,
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  MiaojiColors.primary.withValues(alpha: 0.08),
                  MiaojiColors.accent.withValues(alpha: 0.06),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.table_chart_outlined,
              size: 26,
              color: MiaojiColors.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.schemaEmptyTitle,
            style: const TextStyle(
              color: MiaojiColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.schemaEmptyHint,
            style: TextStyle(
              color: MiaojiColors.textTertiary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldCard(int index, Key key) {
    final field = _fields[index];

    final typeColors = {
      DataFieldType.text: MiaojiColors.primary,
      DataFieldType.number: MiaojiColors.info,
      DataFieldType.date: MiaojiColors.warning,
    };
    final accentColor = typeColors[field.type] ?? MiaojiColors.primary;

    return AnimatedContainer(
      key: key,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: MiaojiColors.surface,
        borderRadius: BorderRadius.circular(MiaojiRadius.lg),
        boxShadow: MiaojiShadows.sm,
        border: Border.all(
          color: MiaojiColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // 顶部颜色指示条
          Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accentColor.withValues(alpha: 0.6),
                  accentColor.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    // 序号指示
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 字段名称
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        initialValue: field.name,
                        decoration: InputDecoration(
                          labelText: context.l10n.fieldNameLabel,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          filled: true,
                          fillColor: MiaojiColors.surfaceVariant,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: accentColor.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        onChanged: (value) => field.name = value,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // 类型选择（已有字段不可修改类型）
                    SizedBox(
                      width: 96,
                      child: field.isExisting
                          ? _buildLockedTypeChip(field, accentColor)
                          : _buildTypeDropdown(field, accentColor),
                    ),
                    // 删除按钮
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      color: MiaojiColors.textTertiary,
                      splashRadius: 18,
                      onPressed: () => _removeField(index),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // 描述字段
                TextFormField(
                  initialValue: field.description,
                  decoration: InputDecoration(
                    hintText: context.l10n.fieldDescHint,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.notes_rounded,
                        size: 14,
                        color: MiaojiColors.textHint,
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.only(left: 36),
                    isDense: true,
                    filled: false,
                  ),
                  style: const TextStyle(
                    fontSize: 13,
                    color: MiaojiColors.textTertiary,
                  ),
                  onChanged: (value) => field.description = value,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 已有字段的类型标签（不可修改，显示锁定图标）
  Widget _buildLockedTypeChip(
      DataFieldDefinition field, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              field.type.displayName(context.l10n),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: accentColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.lock_outline_rounded,
            size: 11,
            color: accentColor.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  /// 新字段的类型下拉选择
  Widget _buildTypeDropdown(
      DataFieldDefinition field, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: DropdownButtonFormField<DataFieldType>(
        initialValue: field.type,
        isExpanded: true,
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 8),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        icon: Icon(
          Icons.unfold_more_rounded,
          size: 14,
          color: accentColor,
        ),
        dropdownColor: MiaojiColors.surface,
        borderRadius: BorderRadius.circular(12),
        items: DataFieldType.values.map((type) {
          return DropdownMenuItem(
            value: type,
            child: Text(
              type.displayName(context.l10n),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: accentColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() => field.type = value);
          }
        },
      ),
    );
  }

  Widget _buildIconPreview(IconData selectedIcon, NotebookColorOption selectedColor) {
    if (_iconImagePath != null && _iconImagePath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.file(
          File(_iconImagePath!),
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) {
            return Icon(
              selectedIcon,
              color: selectedColor.color,
              size: 30,
            );
          },
        ),
      );
    }
    return Icon(
      selectedIcon,
      color: selectedColor.color,
      size: 30,
    );
  }

  Future<void> _pickIconImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;

      final dbPath = await getDatabasesPath();
      final iconDir = Directory(p.join(dbPath, 'notebook_icons'));
      if (!await iconDir.exists()) {
        await iconDir.create(recursive: true);
      }
      final ext = p.extension(picked.path).toLowerCase();
      final fileName =
          'icon_${DateTime.now().millisecondsSinceEpoch}${ext.isNotEmpty ? ext : '.jpg'}';
      final savedFile = await File(picked.path).copy(p.join(iconDir.path, fileName));

      HapticFeedback.selectionClick();
      setState(() => _iconImagePath = savedFile.path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.saveFailed(e.toString()))),
      );
    }
  }
}
