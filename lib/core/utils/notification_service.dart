import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationServiceImpl();
});

abstract class NotificationService {
  Future<void> init();
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  });
  Future<void> scheduleTaskReminder({
    required String taskId,
    required String taskTitle,
    required DateTime taskDate,
  });
  Future<void> cancelNotification(int id);
}

class NotificationServiceImpl implements NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  Future<void> init() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // Request permissions for Android 13+
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );
  }

  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) {
      debugPrint('⚠️ Scheduled date is in the past, skipping');
      return;
    }

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);
    debugPrint('🔔 Scheduling notification:');
    debugPrint('   ID: $id');
    debugPrint('   Title: $title');
    debugPrint('   Scheduled for: $tzScheduledDate');
    debugPrint('   Timezone: ${tz.local.name}');

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_channel',
          'Tasks',
          channelDescription: 'Task reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  @override
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  @override
  Future<void> scheduleTaskReminder({
    required String taskId,
    required String taskTitle,
    required DateTime taskDate,
  }) async {
    // Calculate reminder time (10 minutes before task)
    final reminderTime = taskDate.subtract(const Duration(minutes: 10));

    debugPrint('📅 Scheduling reminder for task: $taskTitle');
    debugPrint('   Task time: $taskDate');
    debugPrint('   Reminder time: $reminderTime');
    debugPrint('   Current time: ${DateTime.now()}');
    debugPrint(
        '   Time until reminder: ${reminderTime.difference(DateTime.now())}');

    // Skip if reminder time is in the past
    if (reminderTime.isBefore(DateTime.now())) {
      debugPrint('⚠️ Reminder time is in the past, skipping notification');
      return;
    }

    // Convert task ID string to integer for notification ID
    final notificationId = taskId.hashCode.abs();
    debugPrint('   Notification ID: $notificationId');

    // Schedule the reminder notification
    try {
      await scheduleNotification(
        id: notificationId,
        title: '⏰ Task Reminder',
        body: 'Your task "$taskTitle" starts in 10 minutes!',
        scheduledDate: reminderTime,
      );
      debugPrint('✅ Notification scheduled successfully!');
    } catch (e) {
      debugPrint('❌ Error scheduling notification: $e');
    }
  }
}
