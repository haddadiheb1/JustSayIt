import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationServiceImpl();
});

abstract class NotificationService {
  Future<void> init();
  Future<void> scheduleTaskReminders({
    required String taskId,
    required String taskTitle,
    required DateTime taskTime,
  });
  Future<void> cancelNotification(String taskId);
}

class NotificationServiceImpl implements NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  Future<void> init() async {
    debugPrint('🔔 Initializing notification service...');
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // Request notification permissions for Android 13+
    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      debugPrint('📱 Requesting notification permission...');
      final granted =
          await androidImplementation.requestNotificationsPermission();
      debugPrint('📱 Notification permission granted: $granted');
    }

    await _notificationsPlugin.initialize(initializationSettings);

    debugPrint('✅ Notification service initialized');
  }

  @override
  Future<void> scheduleTaskReminders({
    required String taskId,
    required String taskTitle,
    required DateTime taskTime,
  }) async {
    final now = DateTime.now();

    debugPrint('📅 Scheduling reminders for: $taskTitle');
    debugPrint('   Task time: $taskTime');
    debugPrint('   Current time: $now');

    // Schedule notification 10 minutes BEFORE task time
    final beforeTime = taskTime.subtract(const Duration(minutes: 10));
    if (beforeTime.isAfter(now)) {
      await _scheduleNotification(
        id: '${taskId}_before',
        title: '⏰ Task Starting Soon',
        body: '$taskTitle starts in 10 minutes',
        scheduledTime: beforeTime,
      );
      debugPrint('✅ Scheduled "before" reminder at: $beforeTime');
    } else {
      debugPrint('⚠️ Skipped "before" reminder (time is in the past)');
    }

    // Schedule notification 10 minutes AFTER task time (overdue reminder)
    final afterTime = taskTime.add(const Duration(minutes: 10));
    if (afterTime.isAfter(now)) {
      await _scheduleNotification(
        id: '${taskId}_after',
        title: '⚠️ Task Overdue',
        body: '$taskTitle is overdue. Check your tasks!',
        scheduledTime: afterTime,
      );
      debugPrint('✅ Scheduled "after" reminder at: $afterTime');
    } else {
      debugPrint('⚠️ Skipped "after" reminder (time is in the past)');
    }
  }

  Future<void> _scheduleNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    try {
      final notificationId = id.hashCode.abs();
      final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

      debugPrint('   Scheduling notification ID: $notificationId');
      debugPrint('   TZ Scheduled time: $tzScheduledTime');
      debugPrint(
          '   Time until notification: ${tzScheduledTime.difference(tz.TZDateTime.now(tz.local))}');

      await _notificationsPlugin.zonedSchedule(
        notificationId,
        title,
        body,
        tzScheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_reminders',
            'Task Reminders',
            channelDescription: 'Reminders for your tasks',
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint('   ✅ Notification scheduled successfully');
    } catch (e) {
      debugPrint('   ❌ Error scheduling notification: $e');
    }
  }

  @override
  Future<void> cancelNotification(String taskId) async {
    // Cancel both before and after notifications
    final beforeId = '${taskId}_before'.hashCode.abs();
    final afterId = '${taskId}_after'.hashCode.abs();

    await _notificationsPlugin.cancel(beforeId);
    await _notificationsPlugin.cancel(afterId);

    debugPrint('🔕 Cancelled notifications for task ID: $taskId');
  }
}
