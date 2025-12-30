import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import "package:say_task/presentation/providers/speech_provider.dart";

class LiveWaveform extends ConsumerStatefulWidget {
  const LiveWaveform({super.key});

  @override
  ConsumerState<LiveWaveform> createState() => _LiveWaveformState();
}

class _LiveWaveformState extends ConsumerState<LiveWaveform>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final level = ref.watch(speechLevelProvider);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(200, 60),
          painter: WaveformPainter(level, _controller.value),
        );
      },
    );
  }
}

class WaveformPainter extends CustomPainter {
  final double
      level; // 0.0 to 1.0 (reallstically -10 to 10 from speech_to_text but we will normalize)
  final double animationValue;

  WaveformPainter(this.level, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final barCount = 5;
    final spacing = 8.0;
    final totalWidth = size.width;
    final barWidth = (totalWidth - (spacing * (barCount - 1))) / barCount;

    // Center the bars
    final startX =
        (size.width - ((barWidth * barCount) + (spacing * (barCount - 1)))) / 2;

    for (int i = 0; i < barCount; i++) {
      // Create a wave effect based on index and animation
      final waveOffset = (i / barCount) * 2 * math.pi;
      final animOffset = animationValue * 2 * math.pi;

      // Combine sound level with a sine wave for "live" feel even when quiet
      double sineWave = math.sin(waveOffset + animOffset);

      // Base height 10
      // Dynamic height from level (up to 40)
      // Idle motion from sineWave (up to 5)
      double barHeight = 10.0 + (level * 40) + (sineWave * 5.0);

      // Make middle bar naturally taller for aesthetic
      if (i == 2) barHeight *= 1.2;

      barHeight = barHeight.clamp(5.0, size.height);

      final x = startX + (i * (barWidth + spacing));
      final y = (size.height - barHeight) / 2;

      final rRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(4),
      );

      canvas.drawRRect(rRect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return oldDelegate.level != level ||
        oldDelegate.animationValue != animationValue;
  }
}
