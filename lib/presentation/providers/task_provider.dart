import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:say_task/domain/entities/task.dart';
import 'package:say_task/domain/entities/task_category.dart';
import 'package:say_task/data/repositories/task_repository_impl.dart';
import 'package:say_task/core/services/widget_sync_service.dart';

part 'task_provider.g.dart';

@riverpod
class TaskList extends _$TaskList {
  @override
  Stream<List<Task>> build() {
    final repository = ref.watch(taskRepositoryProvider);

    return repository.watchTasks().map((list) {
      // Sync with widget whenever list changes
      WidgetSyncService().updateWidget(list);
      return list;
    });
  }
}

@riverpod
Future<void> addTask(
  Ref ref, {
  required String title,
  required DateTime date,
  TaskCategory? category,
}) async {
  final repository = ref.read(taskRepositoryProvider);
  await repository.addTask(title, date, category: category);
}

@riverpod
Future<void> deleteTask(Ref ref, String id) async {
  final repository = ref.read(taskRepositoryProvider);
  await repository.deleteTask(id);
}

@riverpod
Future<void> toggleTask(Ref ref, Task task) async {
  final repository = ref.read(taskRepositoryProvider);
  await repository.toggleTaskCompletion(task);
}

@riverpod
Future<void> updateTask(Ref ref, Task task) async {
  final repository = ref.read(taskRepositoryProvider);
  await repository.updateTask(task);
}

// Separate provider to just ensure init is called
@riverpod
Future<void> initializeApp(Ref ref) async {
  final repository = ref.read(taskRepositoryProvider);
  await repository.init();
}
