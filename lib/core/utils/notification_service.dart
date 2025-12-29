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

      // Request exact alarm permission for Android 12+
      debugPrint('⏰ Requesting exact alarm permission...');
      final exactAlarmGranted =
          await androidImplementation.requestExactAlarmsPermission();
      debugPrint('⏰ Exact alarm permission granted: $exactAlarmGranted');
    }

    // Create notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'task_reminders',
      'Task Reminders',
      description: 'Reminders for your scheduled tasks',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await androidImplementation?.createNotificationChannel(channel);
    debugPrint('✅ Notification channel created');

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );

    debugPrint('✅ Notification service initialized');
  }

  // Handle notification actions
  void _handleNotificationResponse(NotificationResponse response) {
    debugPrint('📱 Notification action: ${response.actionId}');
    debugPrint('📱 Payload: ${response.payload}');

    if (response.payload == null) return;

    final taskId = response.payload!;

    if (response.actionId == 'snooze') {
      _snoozeTask(taskId);
    } else if (response.actionId == 'mark_done') {
      _markTaskDone(taskId);
    }
  }

  void _snoozeTask(String taskId) {
    debugPrint('⏰ Snoozing task: $taskId for 10 minutes');
    // Will be handled by repository
  }

  void _markTaskDone(String taskId) {
    debugPrint('✅ Marking task done: $taskId');
    // Will be handled by repository
  }

  // Add method to show immediate test notification
  Future<void> showTestNotification() async {
    debugPrint('🧪 Showing test notification...');
    await _notificationsPlugin.show(
      999,
      '🔔 Test Notification',
      'If you see this, notifications are working!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders',
          'Task Reminders',
          channelDescription: 'Reminders for your scheduled tasks',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
    debugPrint('✅ Test notification shown');
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
      debugPrint('⚠️ Reminder time is in the past, skipping');
      return;
    }

    final notificationId = taskId.hashCode.abs();
    final tzReminderTime = tz.TZDateTime.from(reminderTime, tz.local);

    debugPrint('   Notification ID: $notificationId');
    debugPrint('   TZ Reminder time: $tzReminderTime');
    debugPrint('   TZ Local: ${tz.local.name}');

    // Format time for notification
    final timeStr =
        '${taskDate.hour.toString().padLeft(2, '0')}:${taskDate.minute.toString().padLeft(2, '0')}';

    try {
      await _notificationsPlugin.zonedSchedule(
        notificationId,
        '⏰ Reminder: $taskTitle',
        'Scheduled for $timeStr (in 10 minutes)',
        tzReminderTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'task_reminders',
            'Task Reminders',
            channelDescription: 'Reminders for your scheduled tasks',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            fullScreenIntent: true,
            enableVibration: true,
            playSound: true,
            actions: <AndroidNotificationAction>[
              const AndroidNotificationAction(
                'snooze',
                'Snooze 10 min',
                showsUserInterface: false,
              ),
              const AndroidNotificationAction(
                'mark_done',
                'Mark Done',
                showsUserInterface: false,
              ),
            ],
          ),
        ),
        payload: taskId,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint('✅ Reminder scheduled successfully with ID: $notificationId');
    } catch (e) {
      debugPrint('❌ Error scheduling reminder: $e');
      rethrow;
    }

    // Show immediate test notification to verify delivery works
    debugPrint('🧪 Showing confirmation notification...');

    // Calculate reminder time for display
    final reminderTimeStr =
        '${reminderTime.hour.toString().padLeft(2, '0')}:${reminderTime.minute.toString().padLeft(2, '0')}';

    await _notificationsPlugin.show(
      99999,
      '✅ Reminder Set',
      'You\'ll be reminded at $reminderTimeStr (10 min before "$taskTitle")',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders',
          'Task Reminders',
          channelDescription: 'Reminders for your scheduled tasks',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}
