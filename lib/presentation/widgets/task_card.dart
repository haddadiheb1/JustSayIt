import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:just_say_it/core/theme/app_theme.dart';
import 'package:just_say_it/domain/entities/task.dart';
import 'package:just_say_it/presentation/providers/task_provider.dart';

class TaskCard extends ConsumerWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOverdue =
        task.scheduledDate.isBefore(DateTime.now()) && !task.isCompleted;

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        ref.read(deleteTaskProvider(task.id));
      },
      background: Container(
        color: AppTheme.errorRed,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        child: ListTile(
          onTap: () {
            ref.read(toggleTaskProvider(task));
          },
          leading: Checkbox(
            value: task.isCompleted,
            activeColor: AppTheme.primaryBlue,
            shape: const CircleBorder(),
            onChanged: (val) {
              ref.read(toggleTaskProvider(task));
            },
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              color: task.isCompleted ? Colors.grey : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            DateFormat('h:mm a').format(task.scheduledDate),
            style: TextStyle(
              color: isOverdue ? AppTheme.errorRed : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}
