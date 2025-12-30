import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:say_task/core/utils/notification_service.dart';
import 'package:say_task/domain/repositories/task_repository.dart';
import 'package:say_task/data/repositories/task_repository_impl.dart';

// Theme mode provider
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt('themeMode') ?? 0;
    state = ThemeMode.values[themeModeIndex];
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
  }
}

// Notifications enabled provider
final notificationsEnabledProvider =
    StateNotifierProvider<NotificationsNotifier, bool>((ref) {
  final notificationService = ref.read(notificationServiceProvider);
  final taskRepository = ref.read(taskRepositoryProvider);
  return NotificationsNotifier(notificationService, taskRepository);
});

class NotificationsNotifier extends StateNotifier<bool> {
  final NotificationService _notificationService;
  final TaskRepository _taskRepository;

  NotificationsNotifier(this._notificationService, this._taskRepository)
      : super(true) {
    _loadNotificationsEnabled();
  }

  Future<void> _loadNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('notificationsEnabled') ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', enabled);

    if (enabled) {
      // Reschedule all future tasks
      debugPrint('🔔 Re-enabling notifications: Scheduling future tasks...');
      final tasks = await _taskRepository.getTasks();
      for (final task in tasks) {
        if (!task.isCompleted && task.scheduledDate.isAfter(DateTime.now())) {
          await _notificationService.scheduleTask(
            taskId: task.id,
            taskTitle: task.title,
            taskTime: task.scheduledDate,
          );
        }
      }
    } else {
      // Cancel all
      debugPrint('🔕 Disabling notifications: Cancelling all tasks...');
      final tasks = await _taskRepository.getTasks();
      for (final task in tasks) {
        await _notificationService.cancelNotification(task.id);
      }
    }
  }
}
