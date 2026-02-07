import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/data_record.dart';
import 'database_service.dart';

/// 本地通知服务（单例）
class NotificationService {
  static final NotificationService _instance =
      NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final DatabaseService _db = DatabaseService();
  bool _initialized = false;

  /// 初始化通知插件（需在 app 启动时调用）
  Future<void> init() async {
    if (_initialized) return;

    // 初始化时区数据
    tz.initializeTimeZones();
    final localTimeZone = tz.local;
    debugPrint('NotificationService: timezone = ${localTimeZone.name}');

    // Android 设置
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

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

  /// 请求通知权限
  Future<void> _requestPermissions() async {
    // iOS
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    // Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// 通知被点击时回调
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint(
        'Notification tapped: id=${response.id}, payload=${response.payload}');
    // 后续可以根据 payload 跳转到对应记录详情
  }

  // ── 调度提醒 ────────────────────────────────

  /// 为一条记录调度本地通知提醒
  /// [recordId] 用作通知 ID（唯一标识）
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
          'NotificationService: reminder time already passed for record $recordId');
      await _db.markReminderSent(recordId);
      return;
    }

    final scheduledDate = tz.TZDateTime.from(reminderAt, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'miaoji_reminders',
      '小本提醒',
      channelDescription: '小本记录的定时提醒通知',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    try {
      await _plugin.zonedSchedule(
        id: recordId,
        title: '📝 $notebookName',
        body: title + (body != null ? '\n$body' : ''),
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: 'record_$recordId',
      );
      debugPrint(
          'NotificationService: scheduled reminder for record $recordId at $reminderAt');
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
          'NotificationService: rescheduling ${pendingRecords.length} reminders');

      for (final record in pendingRecords) {
        if (record.id == null || record.reminderAt == null) continue;

        // 从 data 里提取摘要作为通知内容
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
    // 尝试常见的标题字段
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
    // 取第一个字段的值
    if (data.isNotEmpty) {
      final first = data.values.first;
      if (first != null) return first.toString();
    }
    return '你有一条待办提醒';
  }
}
