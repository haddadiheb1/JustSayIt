import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:just_say_it/core/theme/app_theme.dart';
import 'package:just_say_it/domain/entities/task.dart';
import 'package:just_say_it/presentation/providers/task_provider.dart';
import 'package:just_say_it/presentation/widgets/task_actions_sheet.dart';
import 'package:just_say_it/presentation/widgets/task_edit_dialog.dart';

class TaskCard extends ConsumerStatefulWidget {
  final Task task;
  final int index;

  const TaskCard({super.key, required this.task, this.index = 0});

  @override
  ConsumerState<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends ConsumerState<TaskCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Stagger the animation based on index
    Future.delayed(Duration(milliseconds: widget.index * 50), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue = widget.task.scheduledDate.isBefore(DateTime.now()) &&
        !widget.task.isCompleted;

    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dismissible(
          key: Key(widget.task.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) {
            ref.read(deleteTaskProvider(widget.task.id));
          },
          background: Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red[400]!, Colors.red[600]!],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            child:
                const Icon(Icons.delete_sweep, color: Colors.white, size: 32),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              gradient: isOverdue
                  ? LinearGradient(
                      colors: [Colors.red[50]!, Colors.red[100]!],
                    )
                  : LinearGradient(
                      colors: [Colors.white, Colors.grey[50]!],
                    ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: widget.task.isCompleted
                      ? Colors.grey.withValues(alpha: 0.1)
                      : AppTheme.primaryBlue.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  ref.read(toggleTaskProvider(widget.task));
                },
                onLongPress: () {
                  _showTaskActions(context);
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Animated Checkbox
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 300),
                        tween: Tween(
                          begin: 0.0,
                          end: widget.task.isCompleted ? 1.0 : 0.0,
                        ),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: 1.0 + (value * 0.2),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: widget.task.isCompleted
                                      ? AppTheme.primaryBlue
                                      : Colors.grey[400]!,
                                  width: 2,
                                ),
                                color: widget.task.isCompleted
                                    ? AppTheme.primaryBlue
                                    : Colors.transparent,
                              ),
                              child: widget.task.isCompleted
                                  ? const Icon(
                                      Icons.check,
                                      size: 18,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      // Task Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                decoration: widget.task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: widget.task.isCompleted
                                    ? Colors.grey
                                    : Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              child: Text(widget.task.title),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: isOverdue
                                      ? AppTheme.errorRed
                                      : Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('h:mm a')
                                      .format(widget.task.scheduledDate),
                                  style: TextStyle(
                                    color: isOverdue
                                        ? AppTheme.errorRed
                                        : Colors.grey[600],
                                    fontSize: 13,
                                    fontWeight: isOverdue
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                                if (isOverdue) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.errorRed,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'OVERDUE',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showTaskActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskActionsSheet(
        task: widget.task,
        onEdit: () => _showEditDialog(context),
        onDelete: () {
          ref.read(deleteTaskProvider(widget.task.id));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text('Task "${widget.task.title}" deleted'),
                ],
              ),
              backgroundColor: Colors.red[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => TaskEditDialog(task: widget.task),
    );
  }
}
