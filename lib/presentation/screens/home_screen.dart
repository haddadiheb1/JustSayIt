import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:just_say_it/core/theme/app_theme.dart';
import 'package:just_say_it/core/utils/date_parser.dart';
import 'package:just_say_it/core/utils/notification_service.dart';
import 'package:just_say_it/core/utils/speech_service.dart';
import 'package:just_say_it/domain/entities/task.dart';
import 'package:just_say_it/presentation/providers/speech_provider.dart';
import 'package:just_say_it/presentation/providers/task_provider.dart';
import 'package:just_say_it/presentation/widgets/mic_button.dart';
import 'package:just_say_it/presentation/widgets/task_card.dart';
import 'package:just_say_it/presentation/widgets/task_confirm_sheet.dart';
import 'package:just_say_it/presentation/widgets/voice_capture_sheet.dart';
import 'package:just_say_it/presentation/screens/manual_task_entry_screen.dart';

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
          final today = <Task>[];
          final upcoming = <Task>[];
          final completed = <Task>[];

          final now = DateTime.now();
          final startOfToday = DateTime(now.year, now.month, now.day);
          final endOfToday = startOfToday.add(const Duration(days: 1));

          for (final t in tasks) {
            if (t.isCompleted) {
              completed.add(t);
            } else if (t.scheduledDate.isBefore(endOfToday)) {
              today.add(t);
            } else {
              upcoming.add(t);
            }
          }

          // Sort using priority logic
          today.sort(_compareTasks);
          upcoming.sort(_compareTasks);
          // Completed tasks usually sorted by date completed, or just date?
          // Let's keep date for completed, or priority too?
          // Usually completed tasks are list history. Latest completed top?
          // Assuming date for now, descending?
          completed.sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                if (today.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Today",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue)),
                    ),
                  ),
                  ImplicitlyAnimatedList<Task>(
                    items: today,
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
                if (upcoming.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Upcoming",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue)),
                    ),
                  ),
                  ImplicitlyAnimatedList<Task>(
                    items: upcoming,
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
                if (completed.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.all(16),
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
                          "Completed (${completed.length})",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
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
