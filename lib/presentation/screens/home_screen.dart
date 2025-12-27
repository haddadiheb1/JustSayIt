import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
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

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(taskListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Voice Tasks"),
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

          // Sort by time
          today.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
          upcoming.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

          return ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              if (today.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("Today",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue)),
                ),
                ...today.asMap().entries.map(
                    (entry) => TaskCard(task: entry.value, index: entry.key)),
              ],
              if (upcoming.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("Upcoming",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue)),
                ),
                ...upcoming.asMap().entries.map(
                    (entry) => TaskCard(task: entry.value, index: entry.key)),
              ],
              if (completed.isNotEmpty) ...[
                ExpansionTile(
                  title: const Text("Completed",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey)),
                  children: completed
                      .asMap()
                      .entries
                      .map((entry) =>
                          TaskCard(task: entry.value, index: entry.key))
                      .toList(),
                ),
              ],
            ],
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
