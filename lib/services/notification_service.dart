import 'package:flutter/foundation.dart';
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

/// 所有可用铃声选项
const List<AlarmSoundOption> alarmSoundOptions = [
  AlarmSoundOption(
    id: 'default',
    name: '系统默认',
    iosFile: null,
    description: '使用系统默认通知声音',
  ),
  AlarmSoundOption(
    id: 'classic',
    name: '经典闹钟',
    iosFile: 'alarm_sound.caf',
    description: '嘟-嘟…嘟-嘟… 经典双音闹钟',
  ),
  AlarmSoundOption(
    id: 'radar',
    name: '雷达',
    iosFile: 'alarm_radar.caf',
    description: '嘟嘟嘟…嘟嘟嘟… 快速脉冲',
  ),
  AlarmSoundOption(
    id: 'beacon',
    name: '灯塔',
    iosFile: 'alarm_beacon.caf',
    description: '低-高…低-高… 交替升调',
  ),
  AlarmSoundOption(
    id: 'chime',
    name: '钟琴',
    iosFile: 'alarm_chime.caf',
    description: '叮…叮…叮… 悠扬清脆',
  ),
  AlarmSoundOption(
    id: 'pulse',
    name: '脉冲',
    iosFile: 'alarm_pulse.caf',
    description: '嘟嘟-嗡…嘟嘟-嗡… 紧迫节奏',
  ),
];

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
    return alarmSoundOptions.firstWhere(
      (o) => o.id == _selectedSoundId,
      orElse: () => alarmSoundOptions[1], // fallback to 'classic'
    );
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

    final option = alarmSoundOptions.firstWhere(
      (o) => o.id == soundId,
      orElse: () => alarmSoundOptions[0],
    );

    final details = _buildNotificationDetails(option);

    await _plugin.show(
      id: 99999, // 固定 ID，避免累积
      title: '🔔 铃声预览',
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
  }

  // ── 构建通知详情 ────────────────────────────

  /// 根据铃声选项构建 NotificationDetails
  NotificationDetails _buildNotificationDetails(AlarmSoundOption option) {
    // ── Android: 闹钟式通知 ──
    final androidDetails = AndroidNotificationDetails(
      'miaoji_alarm_reminders',
      '小本闹钟提醒',
      channelDescription: '小本记录的闹钟式定时提醒，会持续响铃直到处理',
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
      await _plugin.zonedSchedule(
        id: recordId,
        title: '📝 $notebookName',
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

  /// 从数据库恢复所有待发送的提醒（app 启动时调用）
  Future<void> rescheduleAllReminders() async {
    try {
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
    return '你有一条待办提醒';
  }
}
