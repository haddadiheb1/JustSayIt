import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:say_task/core/utils/notification_service.dart';
import 'package:say_task/data/models/task_model.dart';
import 'package:timezone/data/latest.dart' as tz;

class BackgroundService {
  static const int morningAlarmId = 1001;
  static const int eveningAlarmId = 1002;
  static const int missedTaskAlarmId = 1003;

  static Future<void> init() async {
    await AndroidAlarmManager.initialize();
    debugPrint('⏰ Alarm Manager Initialized');
    await scheduleAlarms();
  }

  static Future<void> scheduleAlarms() async {
    // Schedule Morning Nudge (8:00 AM)
    await _scheduleDaily(
      id: morningAlarmId,
      hour: 8,
      callback: morningNudgeCallback,
    );

    // Schedule Evening Reflection (9:00 PM)
    await _scheduleDaily(
      id: eveningAlarmId,
      hour: 21,
      callback: eveningReflectionCallback,
    );

    // Schedule Missed Task Check (Periodic - e.g., 2 PM)
    await _scheduleDaily(
      id: missedTaskAlarmId,
      hour: 14,
      callback: missedTaskCallback,
    );
  }

  static Future<void> _scheduleDaily({
    required int id,
    required int hour,
    required Function callback,
  }) async {
    tz.initializeTimeZones();
    // Default to local, but handle if not set (best effort)
    // For background scheduling, we often rely on simpler periodic or one-shot logic
    // But AndroidAlarmManager uses device time, so computing startAt is key.

    final now = DateTime.now();
    var target = DateTime(now.year, now.month, now.day, hour, 0);
    if (target.isBefore(now)) {
      target = target.add(const Duration(days: 1));
    }

    await AndroidAlarmManager.periodic(
      const Duration(days: 1),
      id,
      callback,
      startAt: target,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
    debugPrint('⏰ Scheduled alarm $id for $target');
  }

  // --- Static Callbacks (Must be static / top-level) ---

  @pragma('vm:entry-point')
  static Future<void> morningNudgeCallback() async {
    debugPrint('⏰ Executing Morning Nudge');
    final notificationService = NotificationServiceImpl();
    await notificationService.init();
    await notificationService.showNotification(
      id: 800,
      title: "Good morning ☀️",
      body: "Ready to plan your day? Tap to add your tasks.",
    );
  }

  @pragma('vm:entry-point')
  static Future<void> eveningReflectionCallback() async {
    debugPrint('⏰ Executing Evening Reflection');
    try {
      await _initHive();
      final box = await _openTaskBox();

      final today = DateTime.now();
      int completedToday = 0;

      for (var i = 0; i < box.length; i++) {
        final task = box.getAt(i);
        if (task != null && task.isCompleted && task.completedAt != null) {
          final cDate = task.completedAt!;
          if (cDate.year == today.year &&
              cDate.month == today.month &&
              cDate.day == today.day) {
            completedToday++;
          }
        }
      }

      final notificationService = NotificationServiceImpl();
      await notificationService.init();

      if (completedToday > 0) {
        await notificationService.showNotification(
          id: 900,
          title: "Day in Review 🌙",
          body: "You completed $completedToday tasks today! Great job! 🎉",
        );
      } else {
        await notificationService.showNotification(
          id: 900,
          title: "Day in Review 🌙",
          body: "Zero tasks completed today. Tomorrow is a fresh start! 💪",
        );
      }
    } catch (e) {
      debugPrint("Error in evening callback: $e");
    }
  }

  @pragma('vm:entry-point')
  static Future<void> missedTaskCallback() async {
    debugPrint('⏰ Executing Missed Task Check');
    try {
      await _initHive();
      final box = await _openTaskBox();
      final now = DateTime.now();

      String? overdueTaskTitle;

      for (var i = 0; i < box.length; i++) {
        final task = box.getAt(i);
        if (task != null && !task.isCompleted) {
          // Check if ANY task is overdue (scheduled before now)
          // Just picking the first one found or high priority
          if (task.scheduledDate.isBefore(now)) {
            overdueTaskTitle = task.title;
            break;
          }
        }
      }

      if (overdueTaskTitle != null) {
        final notificationService = NotificationServiceImpl();
        await notificationService.init();
        await notificationService.showNotification(
          id: 901,
          title: "Missed a task?",
          body:
              "You didn't complete '$overdueTaskTitle'. Want to reschedule? 🗓️",
        );
      }
    } catch (e) {
      debugPrint("Error in missed task callback: $e");
    }
  }

  // Hive Helper for Background Isolates
  static Future<void> _initHive() async {
    // In background isolate, we need to init hive again.
    // path_provider might not work in pure background depending on context,
    // but usually works if flutter engine is attached.
    // Safe bet: standard init.
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskModelAdapter());
    }
  }

  static Future<Box<TaskModel>> _openTaskBox() async {
    if (Hive.isBoxOpen('tasks')) {
      return Hive.box<TaskModel>('tasks');
    }
    return await Hive.openBox<TaskModel>('tasks');
  }
}
