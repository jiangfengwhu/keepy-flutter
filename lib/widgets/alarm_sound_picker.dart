import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/notification_service.dart';
import '../theme/miaoji_theme.dart';

/// 显示铃声选择器 BottomSheet
Future<void> showAlarmSoundPicker(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: MiaojiColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const _AlarmSoundPickerContent(),
  );
}

class _AlarmSoundPickerContent extends StatefulWidget {
  const _AlarmSoundPickerContent();

  @override
  State<_AlarmSoundPickerContent> createState() =>
      _AlarmSoundPickerContentState();
}

class _AlarmSoundPickerContentState extends State<_AlarmSoundPickerContent> {
  final NotificationService _notifService = NotificationService();
  late String _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = _notifService.selectedSoundId;
  }

  Future<void> _selectSound(AlarmSoundOption option) async {
    HapticFeedback.selectionClick();
    setState(() => _selectedId = option.id);
    await _notifService.setAlarmSound(option.id);
  }

  Future<void> _previewSound(AlarmSoundOption option) async {
    HapticFeedback.lightImpact();
    await _notifService.previewSound(option.id);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20, 16, 20, MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: MiaojiColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.notifications_active_rounded,
                  size: 20, color: MiaojiColors.primary),
              const SizedBox(width: 8),
              const Text(
                '提醒铃声',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: MiaojiColors.textPrimary,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close_rounded,
                    size: 22, color: MiaojiColors.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // const Text(
          //   'iOS 铃声最长 30 秒，Android 会持续响铃直到处理',
          //   style: TextStyle(
          //     fontSize: 12,
          //     color: MiaojiColors.textTertiary,
          //   ),
          // ),
          const SizedBox(height: 16),
          // 铃声列表
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: alarmSoundOptions.map((option) => _buildSoundTile(option)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundTile(AlarmSoundOption option) {
    final isSelected = option.id == _selectedId;

    return GestureDetector(
      onTap: () => _selectSound(option),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? MiaojiColors.primary.withValues(alpha: 0.08)
              : MiaojiColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? MiaojiColors.primary.withValues(alpha: 0.3)
                : MiaojiColors.borderLight,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // 选中指示器
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected
                    ? MiaojiColors.primary
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? MiaojiColors.primary
                      : MiaojiColors.textHint,
                  width: isSelected ? 0 : 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            // 铃声信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected
                          ? MiaojiColors.primary
                          : MiaojiColors.textPrimary,
                    ),
                  ),
                  Text(
                    option.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: MiaojiColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            // 试听按钮
            GestureDetector(
              onTap: () => _previewSound(option),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: MiaojiColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: MiaojiColors.borderLight,
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 18,
                  color: MiaojiColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
