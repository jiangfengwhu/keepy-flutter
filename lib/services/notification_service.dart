import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:keepy_flutter/l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/data_record.dart';
import 'database_service.dart';

/// Android Notification.FLAG_INSISTENT — 持续重复播放声音直到用户处理
const int _kFlagInsistent = 4;

/// 铃声选项
class AlarmSoundOption {
  final String id; // 存储用的标识
  final String name; // 显示名称
  final String? iosFile; // iOS 铃声文件名（null = 系统默认）
  final String description; // 简短描述

  const AlarmSoundOption({
    required this.id,
    required this.name,
    this.iosFile,
    required this.description,
  });
}

class _AlarmSoundMeta {
  final String id;
  final String? iosFile;
  const _AlarmSoundMeta({required this.id, this.iosFile});
}

const List<_AlarmSoundMeta> _alarmSoundMetas = [
  _AlarmSoundMeta(id: 'default', iosFile: null),
  _AlarmSoundMeta(id: 'classic', iosFile: 'alarm_sound.caf'),
  _AlarmSoundMeta(id: 'radar', iosFile: 'alarm_radar.caf'),
  _AlarmSoundMeta(id: 'beacon', iosFile: 'alarm_beacon.caf'),
  _AlarmSoundMeta(id: 'chime', iosFile: 'alarm_chime.caf'),
  _AlarmSoundMeta(id: 'pulse', iosFile: 'alarm_pulse.caf'),
];

List<AlarmSoundOption> alarmSoundOptions(AppLocalizations l10n) {
  return _alarmSoundMetas
      .map(
        (meta) => AlarmSoundOption(
          id: meta.id,
          name: _alarmSoundName(meta.id, l10n),
          iosFile: meta.iosFile,
          description: _alarmSoundDescription(meta.id, l10n),
        ),
      )
      .toList();
}

String _alarmSoundName(String id, AppLocalizations l10n) {
  switch (id) {
    case 'default':
      return l10n.alarmSoundDefaultName;
    case 'classic':
      return l10n.alarmSoundClassicName;
    case 'radar':
      return l10n.alarmSoundRadarName;
    case 'beacon':
      return l10n.alarmSoundBeaconName;
    case 'chime':
      return l10n.alarmSoundChimeName;
    case 'pulse':
      return l10n.alarmSoundPulseName;
    default:
      return l10n.alarmSoundClassicName;
  }
}

String _alarmSoundDescription(String id, AppLocalizations l10n) {
  switch (id) {
    case 'default':
      return l10n.alarmSoundDefaultDesc;
    case 'classic':
      return l10n.alarmSoundClassicDesc;
    case 'radar':
      return l10n.alarmSoundRadarDesc;
    case 'beacon':
      return l10n.alarmSoundBeaconDesc;
    case 'chime':
      return l10n.alarmSoundChimeDesc;
    case 'pulse':
      return l10n.alarmSoundPulseDesc;
    default:
      return l10n.alarmSoundClassicDesc;
  }
}

const String _kAlarmSoundKey = 'alarm_sound_id';

/// 本地通知服务（单例）
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final DatabaseService _db = DatabaseService();
  bool _initialized = false;

  /// 当前选中的铃声 ID（缓存）
  String _selectedSoundId = 'classic';

  /// 初始化通知插件（需在 app 启动时调用）
  Future<void> init() async {
    if (_initialized) return;

    // 初始化时区数据
    tz.initializeTimeZones();
    final localTimeZone = tz.local;
    debugPrint('NotificationService: timezone = ${localTimeZone.name}');

    // 加载用户铃声偏好
    await _loadSoundPreference();

    // Android 设置
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS/macOS 设置
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
    debugPrint('NotificationService: initialized');

    // 请求权限（iOS/Android 13+）
    await _requestPermissions();

    // 恢复所有待发送的提醒
    await rescheduleAllReminders();
  }

  // ── 铃声配置 ────────────────────────────────

  /// 获取当前选中的铃声选项
  AlarmSoundOption get selectedSound {
    return _optionForId(_selectedSoundId, PlatformDispatcher.instance.locale);
  }

  /// 获取当前选中的铃声 ID
  String get selectedSoundId => _selectedSoundId;

  /// 设置铃声并持久化
  Future<void> setAlarmSound(String soundId) async {
    _selectedSoundId = soundId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAlarmSoundKey, soundId);
    debugPrint('NotificationService: alarm sound set to $soundId');
  }

  /// 从持久化存储加载偏好
  Future<void> _loadSoundPreference() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedSoundId = prefs.getString(_kAlarmSoundKey) ?? 'classic';
  }

  /// 发送即时测试通知（用于铃声预览）
  Future<void> previewSound(String soundId) async {
    if (!_initialized) return;

    // 先取消正在播放的预览，立即停止当前声音
    await _plugin.cancel(id: 99999);

    final l10n = _l10nForLocale(PlatformDispatcher.instance.locale);
    final option = alarmSoundOptions(l10n).firstWhere(
      (o) => o.id == soundId,
      orElse: () => alarmSoundOptions(l10n)[0],
    );

    final details = _buildNotificationDetails(option);

    await _plugin.show(
      id: 99999, // 固定 ID，避免累积
      title: l10n.notificationSoundPreviewTitle,
      body: option.name,
      notificationDetails: details,
    );
  }

  /// 检查通知权限是否已授权
  Future<bool> checkNotificationPermission() async {
    if (!_initialized) return false;

    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await androidImpl?.areNotificationsEnabled() ?? false;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosImpl = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final settings = await iosImpl?.checkPermissions();
      return settings?.isAlertEnabled ?? false;
    }
    return true;
  }

  /// 请求通知权限
  Future<void> _requestPermissions() async {
    // iOS
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    // Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  /// 通知被点击时回调
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint(
      'Notification tapped: id=${response.id}, payload=${response.payload}',
    );
    // 从 payload 提取 recordId 并标记提醒已发送
    final payload = response.payload;
    if (payload != null && payload.startsWith('record_')) {
      final recordId = int.tryParse(payload.substring('record_'.length));
      if (recordId != null) {
        _db.markReminderSent(recordId);
        debugPrint(
          'NotificationService: marked reminder sent for record $recordId (tapped)',
        );
      }
    }
  }

  // ── 构建通知详情 ────────────────────────────

  /// 根据铃声选项构建 NotificationDetails
  NotificationDetails _buildNotificationDetails(AlarmSoundOption option) {
    final l10n = _l10nForLocale(PlatformDispatcher.instance.locale);
    // ── Android: 闹钟式通知 ──
    final androidDetails = AndroidNotificationDetails(
      'miaoji_alarm_reminders',
      l10n.notificationChannelName,
      channelDescription: l10n.notificationChannelDescription,
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      additionalFlags: Int32List.fromList([_kFlagInsistent]),
      autoCancel: true,
      ongoing: false,
    );

    // ── iOS: 时间敏感通知 + 可配置铃声 ──
    final darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: option.iosFile, // null = 系统默认
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );
  }

  // ── 调度提醒 ────────────────────────────────

  /// 为一条记录调度本地通知提醒（闹钟式持续铃声）
  Future<void> scheduleReminder({
    required int recordId,
    required DateTime reminderAt,
    required String notebookName,
    required String title,
    String? body,
  }) async {
    if (!_initialized) {
      debugPrint('NotificationService: not initialized, skipping schedule');
      return;
    }

    // 如果提醒时间已过，直接标记已发送
    if (reminderAt.isBefore(DateTime.now())) {
      debugPrint(
        'NotificationService: reminder time already passed for record $recordId',
      );
      await _db.markReminderSent(recordId);
      return;
    }

    final scheduledDate = tz.TZDateTime.from(reminderAt, tz.local);
    final notificationDetails = _buildNotificationDetails(selectedSound);

    try {
      final l10n = _l10nForLocale(PlatformDispatcher.instance.locale);
      await _plugin.zonedSchedule(
        id: recordId,
        title: l10n.notificationReminderTitle(notebookName),
        body: title + (body != null ? '\n$body' : ''),
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'record_$recordId',
      );
      debugPrint(
        'NotificationService: scheduled alarm reminder for record $recordId at $reminderAt (sound: ${selectedSound.id})',
      );
    } catch (e) {
      debugPrint('NotificationService: failed to schedule: $e');
    }
  }

  /// 取消某条记录的提醒
  Future<void> cancelReminder(int recordId) async {
    if (!_initialized) return;
    await _plugin.cancel(id: recordId);
    debugPrint('NotificationService: cancelled reminder for record $recordId');
  }

  /// 检查并标记所有已到期的提醒为已发送
  /// 适用于 app 在前台时通知已触发但数据库未同步更新的场景
  Future<void> checkAndMarkOverdueReminders() async {
    try {
      final count = await _db.markOverdueRemindersAsSent();
      if (count > 0) {
        debugPrint(
          'NotificationService: marked $count overdue reminders as sent',
        );
      }
    } catch (e) {
      debugPrint('NotificationService: markOverdue error: $e');
    }
  }

  /// 从数据库恢复所有待发送的提醒（app 启动时调用）
  Future<void> rescheduleAllReminders() async {
    try {
      // 先将所有已到期的提醒标记为已发送
      await checkAndMarkOverdueReminders();

      final pendingRecords = await _db.getPendingReminders();
      debugPrint(
        'NotificationService: rescheduling ${pendingRecords.length} reminders',
      );

      for (final record in pendingRecords) {
        if (record.id == null || record.reminderAt == null) continue;

        final summary = _buildRecordSummary(record);

        await scheduleReminder(
          recordId: record.id!,
          reminderAt: record.reminderAt!,
          notebookName: record.notebookName,
          title: summary,
        );
      }
    } catch (e) {
      debugPrint('NotificationService: reschedule error: $e');
    }
  }

  /// 从记录数据中提取摘要文本
  String _buildRecordSummary(DataRecord record) {
    final data = record.data;
    for (final key in [
      'title',
      'name',
      '标题',
      '名称',
      '事项',
      '内容',
      'task',
      'content',
    ]) {
      if (data.containsKey(key) && data[key] != null) {
        return data[key].toString();
      }
    }
    if (data.isNotEmpty) {
      final first = data.values.first;
      if (first != null) return first.toString();
    }
    final l10n = _l10nForLocale(PlatformDispatcher.instance.locale);
    return l10n.notificationFallbackBody;
  }

  AppLocalizations _l10nForLocale(Locale locale) {
    return lookupAppLocalizations(locale);
  }

  AlarmSoundOption _optionForId(String id, Locale locale) {
    final l10n = _l10nForLocale(locale);
    final options = alarmSoundOptions(l10n);
    return options.firstWhere(
      (o) => o.id == id,
      orElse: () => options[1],
    );
  }
}
