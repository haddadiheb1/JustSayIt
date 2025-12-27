import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:just_say_it/core/theme/app_theme.dart';
import 'package:just_say_it/presentation/providers/speech_provider.dart';

class VoiceCaptureSheet extends ConsumerWidget {
  final VoidCallback onStop;

  const VoiceCaptureSheet({super.key, required this.onStop});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveText = ref.watch(speechStateProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Listening...",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlue,
            ),
          ),
          const Gap(8),
          Text(
            "Speak clearly and loudly",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
          const Gap(24),
          Text(
            liveText.isEmpty
                ? "Say something like 'Buy milk tomorrow at 5pm'"
                : liveText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: liveText.isEmpty ? Colors.grey : Colors.black87,
            ),
          ),
          const Gap(32),
          // Stop button
          ElevatedButton.icon(
            onPressed: onStop,
            icon: const Icon(Icons.stop),
            label: const Text("Stop"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const Gap(24),
        ],
      ),
    );
  }
}
