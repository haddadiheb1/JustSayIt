import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:say_task/core/theme/app_theme.dart';
import 'package:say_task/core/utils/date_parser.dart';
import 'package:say_task/core/utils/notification_service.dart';
import 'package:say_task/core/utils/speech_service.dart';
import 'package:say_task/domain/entities/task.dart';
import 'package:say_task/presentation/providers/speech_provider.dart';
import 'package:say_task/presentation/providers/task_provider.dart';
import 'package:say_task/presentation/widgets/mic_button.dart';
import 'package:say_task/presentation/widgets/task_card.dart';
import 'package:say_task/presentation/widgets/task_confirm_sheet.dart';
import 'package:say_task/presentation/widgets/voice_capture_sheet.dart';
import 'package:say_task/presentation/screens/manual_task_entry_screen.dart';
import 'package:say_task/presentation/screens/stats_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _capturedText = ""; // Store the captured text locally

  @override
  void initState() {
    super.initState();
    // Initialize services - must await the app initialization
    Future.microtask(() async {
      await ref.read(initializeAppProvider.future);
      ref.read(notificationServiceProvider).init();
      ref.read(speechServiceProvider).init();
    });
  }

  void _startListening() async {
    final speechService = ref.read(speechServiceProvider);
    final notifier = ref.read(speechStateProvider.notifier);
    final isListeningNotifier = ref.read(listeningStateProvider.notifier);

    // Reset captured text
    _capturedText = "";

    // Show listening sheet
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => VoiceCaptureSheet(
        onStop: () => _stopListening(),
      ),
    );

    isListeningNotifier.setListening(true);
    notifier.update("");

    debugPrint('Starting speech recognition...');
    await speechService.startListening(onResult: (text) {
      debugPrint('Speech result received: "$text"');
      _capturedText = text; // Store in local variable
      notifier.update(text); // Also update provider for UI
    });
    debugPrint('Speech recognition started');
  }

  void _stopListening() async {
    final speechService = ref.read(speechServiceProvider);

    // Stop the speech service
    await speechService.stopListening();

    // Give a small delay to ensure final result is captured
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    // Close listening sheet
    Navigator.of(context).pop();
    ref.read(listeningStateProvider.notifier).setListening(false);

    debugPrint('Captured text from local variable: "$_capturedText"');

    if (_capturedText.isNotEmpty) {
      _processVoiceCommand(_capturedText);
    } else {
      debugPrint('No text captured from speech');
      // Show a message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No speech detected. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _processVoiceCommand(String text) {
    debugPrint('Processing voice command: "$text"');
    final result = DateTimeParser.parse(text);
    debugPrint(
        'Parser result - title: "${result.title}", dateTime: ${result.dateTime}');

    if (result.dateTime == null) {
      debugPrint('Warning: dateTime is null, using current time');
    }

    debugPrint('Showing task confirmation sheet...');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => TaskConfirmSheet(
        initialTitle: result.title,
        initialDate: result.dateTime ?? DateTime.now(),
      ),
    );
  }

  int _compareTasks(Task a, Task b) {
    // 1. Sort by Priority (Descending: High > Medium > Low)
    // High=2, Medium=1, Low=0. So b.compare(a) gives Descending.
    int priorityComp = b.priority.value.compareTo(a.priority.value);
    if (priorityComp != 0) return priorityComp;

    // 2. Sort by Date (Ascending: Sooner > Later)
    return a.scheduledDate.compareTo(b.scheduledDate);
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(taskListProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Voice Tasks',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManualTaskEntryScreen(),
                ),
              );
            },
            icon: Icon(
              Icons.edit_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            tooltip: 'Add task manually',
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatsScreen()),
              );
            },
            icon: Icon(
              Icons.bar_chart_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            tooltip: 'View Stats',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: tasksAsync.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.task_alt, size: 64, color: Colors.grey[300]),
                  const Gap(16),
                  Text(
                    "No tasks yet.\nTap the mic to add one.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          // Group tasks
          final overdue = <Task>[];
          final today = <Task>[];
          final tomorrow = <Task>[];
          final nextWeek = <Task>[];
          final upcoming = <Task>[];
          final completed = <Task>[];

          final now = DateTime.now();
          final startOfToday = DateTime(now.year, now.month, now.day);
          final startOfTomorrow = startOfToday.add(const Duration(days: 1));
          final startOfNextWeek = startOfToday.add(const Duration(days: 2));
          final startOfUpcoming = startOfToday.add(const Duration(days: 8));

          for (final t in tasks) {
            if (t.isCompleted) {
              completed.add(t);
            } else {
              if (t.scheduledDate.isBefore(startOfToday)) {
                overdue.add(t);
              } else if (t.scheduledDate.isBefore(startOfTomorrow)) {
                today.add(t);
              } else if (t.scheduledDate.isBefore(startOfNextWeek)) {
                tomorrow.add(t);
              } else if (t.scheduledDate.isBefore(startOfUpcoming)) {
                nextWeek.add(t);
              } else {
                upcoming.add(t);
              }
            }
          }

          // Sort using priority logic
          for (final list in [overdue, today, tomorrow, nextWeek, upcoming]) {
            list.sort(_compareTasks);
          }
          completed.sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));

          Widget buildSection(String title, List<Task> tasks,
              {Color? titleColor, IconData? icon}) {
            if (tasks.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Row(
                    children: [
                      if (icon != null) ...[
                        Icon(icon,
                            size: 18, color: titleColor ?? Colors.grey[700]),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: titleColor ?? AppTheme.primaryBlue,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: (titleColor ?? AppTheme.primaryBlue)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tasks.length.toString(),
                          style: TextStyle(
                            color: titleColor ?? AppTheme.primaryBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ImplicitlyAnimatedList<Task>(
                  items: tasks,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  areItemsTheSame: (a, b) => a.id == b.id,
                  itemBuilder: (context, animation, item, index) {
                    return SizeFadeTransition(
                      sizeFraction: 0.7,
                      curve: Curves.easeInOut,
                      animation: animation,
                      child: TaskCard(task: item, index: index),
                    );
                  },
                ),
              ],
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                buildSection("Overdue", overdue,
                    titleColor: AppTheme.errorRed,
                    icon: Icons.warning_amber_rounded),
                buildSection("Today", today,
                    titleColor: AppTheme.primaryBlue, icon: Icons.today),
                buildSection("Tomorrow", tomorrow,
                    titleColor: Colors.orange, icon: Icons.event),
                buildSection("Next 7 Days", nextWeek,
                    titleColor: Colors.purple, icon: Icons.date_range),
                buildSection("Upcoming", upcoming,
                    titleColor: Colors.grey[700], icon: Icons.update),
                if (completed.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.green[600],
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Completed",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "(${completed.length})",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ImplicitlyAnimatedList<Task>(
                    items: completed,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    areItemsTheSame: (a, b) => a.id == b.id,
                    itemBuilder: (context, animation, item, index) {
                      return SizeFadeTransition(
                        sizeFraction: 0.7,
                        curve: Curves.easeInOut,
                        animation: animation,
                        child: TaskCard(task: item, index: index),
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
      floatingActionButton: MicButton(
        isListening: ref.watch(listeningStateProvider),
        onPressed: _startListening,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
