import 'package:flutter/material.dart';
import 'package:just_say_it/domain/entities/task_priority.dart';
import 'package:just_say_it/core/theme/app_theme.dart';
import 'package:gap/gap.dart';

class PrioritySelectorSheet extends StatelessWidget {
  final TaskPriority currentPriority;
  final ValueChanged<TaskPriority> onPrioritySelected;

  const PrioritySelectorSheet({
    super.key,
    required this.currentPriority,
    required this.onPrioritySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Select Priority',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
            textAlign: TextAlign.center,
          ),
          const Gap(24),
          ...TaskPriority.values.map((priority) {
            final isSelected = currentPriority == priority;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    onPrioritySelected(priority);
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? priority.color.withValues(alpha: 0.1)
                          : Theme.of(context)
                              .colorScheme
                              .surface
                              .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? priority.color
                            : Theme.of(context)
                                .dividerColor
                                .withValues(alpha: 0.2),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: priority.color,
                            boxShadow: [
                              BoxShadow(
                                color: priority.color.withValues(alpha: 0.4),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          priority.displayName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? priority.color
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        if (isSelected)
                          Icon(
                            Icons.check_circle_rounded,
                            color: priority.color,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const Gap(16),
        ],
      ),
    );
  }
}
