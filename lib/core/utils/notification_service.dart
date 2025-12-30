import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationServiceImpl();
});

abstract class NotificationService {
  Future<void> init();
  Future<void> scheduleTask({
    required String taskId,
    required String taskTitle,
    required DateTime taskTime,
  });
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  });
  Future<void> cancelNotification(String taskId);
}

class NotificationServiceImpl implements NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  Future<void> init() async {
    debugPrint('🔔 Initializing simple notification service...');

    // 1. Initialize Timezones
    tz.initializeTimeZones();
    try {
      final dynamic localTimezone = await FlutterTimezone.getLocalTimezone();
      final String timeZoneName = localTimezone.toString();

      debugPrint('🌍 Raw timezone from system: $timeZoneName');

      // Try to use the timezone directly
      try {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
        debugPrint('✅ Successfully set timezone: $timeZoneName');
      } catch (e) {
        // If it fails, try to extract a valid IANA timezone
        // For Tunisia/Central European Time, use Africa/Tunis
        String fallbackZone = 'Africa/Tunis'; // Default for Tunisia (UTC+1)

        if (timeZoneName.contains('Tunis') ||
            timeZoneName.contains('Central European')) {
          fallbackZone = 'Africa/Tunis';
        } else if (timeZoneName.contains('Eastern European')) {
          fallbackZone = 'Africa/Cairo';
        } else if (timeZoneName.contains('Western European')) {
          fallbackZone = 'Europe/Lisbon';
        }

        debugPrint(
            '⚠️ Could not use system timezone, falling back to: $fallbackZone');
        tz.setLocalLocation(tz.getLocation(fallbackZone));
      }
    } catch (e) {
      debugPrint('❌ Timezone initialization failed: $e');
      debugPrint('⚠️ Using UTC as last resort');
    }
    debugPrint('🕒 Timezone initialized: ${tz.local.name}');
    debugPrint('🕒 Current Time (Local): ${tz.TZDateTime.now(tz.local)}');

    // 2. Setup Android Settings
    // Ensure you have 'app_icon' or '@mipmap/ic_launcher' in res/drawable
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 3. Initialize Plugin
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // Request permission (Android 13+)
    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
      await androidImplementation.requestExactAlarmsPermission();
    }

    // Explicitly create the channel to force high importance
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'task_reminders', // id
      'Task Reminders', // title
      description: 'Simple reminders for your tasks', // description
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _notificationsPlugin.initialize(initializationSettings);
    debugPrint('✅ Notification service ready');
  }

  @override
  Future<void> scheduleTask({
    required String taskId,
    required String taskTitle,
    required DateTime taskTime,
  }) async {
    final now = DateTime.now();

    debugPrint('═══════════════════════════════════════════════════');
    debugPrint('📋 SCHEDULE REQUEST for "$taskTitle"');
    debugPrint('   Input DateTime: $taskTime');
    debugPrint('   Current DateTime: $now');
    debugPrint('   Timezone: ${tz.local.name}');

    if (taskTime.isBefore(now)) {
      debugPrint('   ⚠️ SKIPPED: Task is in the past');
      debugPrint('═══════════════════════════════════════════════════');
      return;
    }

    final notificationId = taskId.hashCode.abs();
    final scheduledDate = tz.TZDateTime.from(taskTime, tz.local);
    final tzNow = tz.TZDateTime.now(tz.local);

    debugPrint('   Scheduled TZ DateTime: $scheduledDate');
    debugPrint('   Current TZ DateTime: $tzNow');
    debugPrint(
        '   Time until notification: ${scheduledDate.difference(tzNow)}');
    debugPrint('   Notification ID: $notificationId');

    await _notificationsPlugin.zonedSchedule(
      notificationId,
      '📝 Task Reminder',
      taskTitle,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders',
          'Task Reminders',
          channelDescription: 'Simple reminders for your tasks',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint('   ✅ SCHEDULED SUCCESSFULLY');
    debugPrint('═══════════════════════════════════════════════════');
  }

  @override
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    debugPrint('🚀 Showing immediate notification: $title');
    await _notificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders',
          'Task Reminders',
          channelDescription: 'Simple reminders for your tasks',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  @override
  Future<void> cancelNotification(String taskId) async {
    final notificationId = taskId.hashCode.abs();
    await _notificationsPlugin.cancel(notificationId);
    debugPrint('🔕 Cancelled notification (ID: $notificationId)');
  }
}
