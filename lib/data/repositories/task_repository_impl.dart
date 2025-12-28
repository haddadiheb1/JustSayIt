import 'package:just_say_it/data/datasources/local_task_datasource.dart';
import 'package:just_say_it/data/models/task_model.dart';
import 'package:just_say_it/domain/entities/task.dart';
import 'package:just_say_it/domain/repositories/task_repository.dart';
import 'package:just_say_it/core/utils/notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  Future<void> addTask(String title, DateTime dateTime) async {
    final model = TaskModel.create(title: title, scheduledDate: dateTime);
    await _dataSource.addTask(model);

    // Schedule reminder notification
    await _notificationService.scheduleTaskReminder(
      taskId: model.id,
      taskTitle: model.title,
      taskDate: model.scheduledDate,
    );
  }

  @override
  Future<void> deleteTask(String id) async {
    // Cancel reminder notification
    final notificationId = id.hashCode.abs();
    await _notificationService.cancelNotification(notificationId);

    await _dataSource.deleteTask(id);
  }

  @override
  Future<void> updateTask(Task task) async {
    final model = _mapToModel(task);
    await _dataSource.updateTask(model);
  }

  @override
  Future<void> toggleTaskCompletion(Task task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    await updateTask(updatedTask);

    // Cancel reminder if task is being completed
    if (updatedTask.isCompleted) {
      final notificationId = task.id.hashCode.abs();
      await _notificationService.cancelNotification(notificationId);
    }
  }

  Task _mapToEntity(TaskModel model) {
    return Task(
      id: model.id,
      title: model.title,
      scheduledDate: model.scheduledDate,
      isCompleted: model.isCompleted,
    );
  }

  TaskModel _mapToModel(Task entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      scheduledDate: entity.scheduledDate,
      isCompleted: entity.isCompleted,
    );
  }
}
