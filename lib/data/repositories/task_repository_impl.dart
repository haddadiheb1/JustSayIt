import 'package:say_task/data/datasources/local_task_datasource.dart';
import 'package:say_task/data/models/task_model.dart';
import 'package:say_task/domain/entities/task.dart';
import 'package:say_task/domain/entities/task_category.dart';
import 'package:say_task/domain/repositories/task_repository.dart';
import 'package:say_task/core/utils/notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final dataSource = ref.watch(localTaskDataSourceProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return TaskRepositoryImpl(dataSource, notificationService);
});

class TaskRepositoryImpl implements TaskRepository {
  final LocalTaskDataSource _dataSource;
  final NotificationService _notificationService;

  TaskRepositoryImpl(this._dataSource, this._notificationService);

  @override
  Future<void> init() => _dataSource.init();

  @override
  Future<List<Task>> getTasks() async {
    final models = _dataSource.getTasks();
    return models.map(_mapToEntity).toList();
  }

  @override
  Stream<List<Task>> watchTasks() {
    return _dataSource.watchTasks().map(
          (models) => models.map(_mapToEntity).toList(),
        );
  }

  @override
  Future<void> addTask(String title, DateTime dateTime,
      {TaskCategory? category}) async {
    final model = TaskModel.create(
      title: title,
      scheduledDate: dateTime,
      category: category ?? TaskCategory.defaultCategory,
    );
    await _dataSource.addTask(model);

    // Check if notifications are enabled
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;

    if (notificationsEnabled) {
      // Schedule notification
      await _notificationService.scheduleTask(
        taskId: model.id,
        taskTitle: model.title,
        taskTime: model.scheduledDate,
      );
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    // Cancel notification
    await _notificationService.cancelNotification(id);

    await _dataSource.deleteTask(id);
  }

  @override
  Future<void> updateTask(Task task) async {
    final model = _mapToModel(task);
    await _dataSource.updateTask(model);

    // Cancel old notifications and reschedule with new time
    await _notificationService.cancelNotification(task.id);

    // Only reschedule if task is not completed
    if (!task.isCompleted) {
      final prefs = await SharedPreferences.getInstance();
      final notificationsEnabled =
          prefs.getBool('notificationsEnabled') ?? true;

      if (notificationsEnabled) {
        await _notificationService.scheduleTask(
          taskId: task.id,
          taskTitle: task.title,
          taskTime: task.scheduledDate,
        );
      }
    }
  }

  @override
  Future<void> toggleTaskCompletion(Task task) async {
    final isCompleting = !task.isCompleted;
    final updatedTask = task.copyWith(
      isCompleted: isCompleting,
      completedAt: isCompleting ? DateTime.now() : null,
    );
    await updateTask(updatedTask);

    // Cancel notification if task is being completed
    if (updatedTask.isCompleted) {
      await _notificationService.cancelNotification(task.id);
    }
  }

  Task _mapToEntity(TaskModel model) {
    return Task(
      id: model.id,
      title: model.title,
      scheduledDate: model.scheduledDate,
      isCompleted: model.isCompleted,
      category: model.category,
      priority: model.priority,
      completedAt: model.completedAt,
    );
  }

  TaskModel _mapToModel(Task entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      scheduledDate: entity.scheduledDate,
      isCompleted: entity.isCompleted,
      categoryIndex: entity.category.index,
      priorityIndex: entity.priority.index,
      completedAt: entity.completedAt,
    );
  }
}
