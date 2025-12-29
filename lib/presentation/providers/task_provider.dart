import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_say_it/domain/entities/task.dart';
import 'package:just_say_it/domain/entities/task_category.dart';
import 'package:just_say_it/data/repositories/task_repository_impl.dart';

part 'task_provider.g.dart';

@riverpod
class TaskList extends _$TaskList {
  @override
  Stream<List<Task>> build() {
    final repository = ref.watch(taskRepositoryProvider);
    // Ensure repository is initialized.
    // In a real app, this might be done in main or via a bootstraper
    // For now, we'll assume it's initialized before usage or init lazily
    // However, since watchTasks is a stream, we can just return it.
    return repository.watchTasks();
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
