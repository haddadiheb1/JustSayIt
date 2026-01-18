import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:say_task/core/theme/app_theme.dart';
import 'package:say_task/core/utils/date_parser.dart';
import 'package:say_task/core/utils/notification_service.dart';
import 'package:say_task/core/utils/speech_service.dart';
import 'package:say_task/presentation/providers/speech_provider.dart';
import 'package:say_task/presentation/providers/task_provider.dart';
import 'package:say_task/presentation/screens/home_screen.dart';
import 'package:say_task/presentation/screens/notes_screen.dart';
import 'package:say_task/presentation/screens/settings_screen.dart';
import 'package:say_task/presentation/screens/stats_screen.dart';
import 'package:say_task/presentation/widgets/task_confirm_sheet.dart';
import 'package:say_task/presentation/widgets/voice_capture_sheet.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;
  late final PageController _pageController;
  String _capturedText = "";

  final List<Widget> _screens = const [
    HomeScreen(),
    StatsScreen(),
    NotesScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);

    // Initialize services
    Future.microtask(() async {
      await ref.read(initializeAppProvider.future);
      ref.read(notificationServiceProvider).init();
      ref.read(speechServiceProvider).init();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == 2) return; // Middle button handled separately

    // Map navbar index to page index
    int pageIndex = index;
    if (index > 2) pageIndex = index - 1;

    setState(() {
      _currentIndex = pageIndex;
    });
    _pageController.jumpToPage(pageIndex);
  }

  void _startListening() async {
    // Switch to Home screen if not already there
    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
      _pageController.jumpToPage(0);
    }

    final speechService = ref.read(speechServiceProvider);
    final notifier = ref.read(speechStateProvider.notifier);
    final isListeningNotifier = ref.read(listeningStateProvider.notifier);

    // Reset state
    _capturedText = "";
    isListeningNotifier.setListening(true);
    notifier.update("");

    // Show listening sheet
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VoiceCaptureSheet(
        onStop: _stopListening,
      ),
    );

    debugPrint('Starting speech recognition...');
    await speechService.startListening(
      onResult: (text) {
        debugPrint('Speech result: "$text"');
        _capturedText = text;
        notifier.update(text);
      },
      onSoundLevelChange: (level) {
        ref.read(speechLevelProvider.notifier).update(level);
      },
    );
  }

  void _stopListening() async {
    final speechService = ref.read(speechServiceProvider);
    await speechService.stopListening();

    // Small delay for final result
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    // Close sheet
    Navigator.of(context).pop();
    ref.read(listeningStateProvider.notifier).setListening(false);

    if (_capturedText.isNotEmpty) {
      _processVoiceCommand(_capturedText);
    } else {
      _showNoSpeechError();
    }
  }

  void _processVoiceCommand(String text) {
    final result = DateTimeParser.parse(text);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => TaskConfirmSheet(
        initialTitle: result.title,
        initialDate: result.dateTime ?? DateTime.now(),
      ),
    );
  }

  void _showNoSpeechError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.mic_off_outlined, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text('No speech detected. Please try again.')),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Important for floating effect
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
      ),
      bottomNavigationBar: CozyBottomBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        onVoiceTap: _startListening,
      ),
    );
  }
}

class CozyBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onVoiceTap;

  const CozyBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onVoiceTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;

    // Responsive dimensions based on screen width
    final barHeight = 80.0;
    final micButtonSize =
        screenWidth * 0.16; // 16% of screen width, min 56, max 72
    final micIconSize = micButtonSize * 0.5; // 50% of button size
    final centerGap = micButtonSize * 0.9; // Gap scales with button size
    final micButtonTopOffset =
        (barHeight - micButtonSize) / 2; // Center vertically

    return Container(
      width: screenWidth,
      height: barHeight,
      margin: EdgeInsets.only(
        bottom: 24,
        left: screenWidth * 0.04, // 4% of screen width
        right: screenWidth * 0.04,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Shape
          CustomPaint(
            size: Size(screenWidth, barHeight),
            painter: CozyBarPainter(
              color: Theme.of(context).colorScheme.surface,
              shadowColor: Colors.black.withValues(alpha: 0.1),
            ),
          ),

          // Navigation Items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, 0, Icons.home_rounded, "Home"),
              _buildNavItem(context, 1, Icons.analytics_rounded, "Stats"),
              SizedBox(width: centerGap), // Responsive gap for the center bump
              _buildNavItem(context, 3, Icons.sticky_note_2_rounded,
                  "Notes"), // index 3 in navbar -> 2 in pages
              _buildNavItem(context, 4, Icons.settings_rounded,
                  "Settings"), // index 4 in navbar -> 3 in pages
            ],
          ),

          // Center Mic Button - Responsive with tap feedback
          Positioned(
            top: micButtonTopOffset.clamp(0.0, 8.0), // Clamp between 0 and 8
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onVoiceTap,
                borderRadius: BorderRadius.circular(micButtonSize / 2),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: micButtonSize.clamp(56.0, 72.0),
                  height: micButtonSize.clamp(56.0, 72.0),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppTheme.primaryIndigo,
                        Color(0xFF818CF8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryIndigo.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.mic_rounded,
                    color: Colors.white,
                    size: micIconSize.clamp(24.0, 36.0),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, int index, IconData icon, String label) {
    // Map navbar index to page index for comparison
    int pageIndex = index;
    if (index > 2) pageIndex = index - 1;

    final isSelected = currentIndex == pageIndex;
    final color = isSelected
        ? AppTheme.primaryIndigo
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4);

    // Responsive icon size based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize =
        (screenWidth * 0.065).clamp(22.0, 28.0); // Responsive icon size

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Constrain height
            children: [
              // Raise icons slightly to center them vertically in the bar
              // The bump starts higher, but the bar body is lower
              const Gap(12),
              Icon(icon, color: color, size: iconSize),
              if (isSelected)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryIndigo,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class CozyBarPainter extends CustomPainter {
  final Color color;
  final Color shadowColor;

  CozyBarPainter({required this.color, required this.shadowColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = shadowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final path = Path();

    // Constants for the curve
    const double cornerRadius = 24.0;
    const double bumpRadius = 38.0; // Radius of the hole/bump
    const double top = 20.0; // Top Y of the main bar (excluding bump)
    final double center = size.width / 2;

    // Start top-left
    path.moveTo(0 + cornerRadius, top);

    // Top line to bump start
    path.lineTo(center - bumpRadius - 10, top);

    // The convex bump
    path.cubicTo(
      center - bumpRadius, top, // control point 1
      center - bumpRadius, 0, // control point 2 (upwards)
      center, 0, // end point (top center)
    );
    path.cubicTo(
      center + bumpRadius, 0, // control point 1
      center + bumpRadius, top, // control point 2
      center + bumpRadius + 10, top, // end point
    );

    // Top line to right corner
    path.lineTo(size.width - cornerRadius, top);

    // Top-right corner
    path.quadraticBezierTo(size.width, top, size.width, top + cornerRadius);

    // Right side
    path.lineTo(size.width, size.height - cornerRadius);

    // Bottom-right corner
    path.quadraticBezierTo(
        size.width, size.height, size.width - cornerRadius, size.height);

    // Bottom side
    path.lineTo(cornerRadius, size.height);

    // Bottom-left corner
    path.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);

    // Left side
    path.lineTo(0, top + cornerRadius);

    // Top-left corner
    path.quadraticBezierTo(0, top, cornerRadius, top);

    path.close();

    // Draw shadow
    canvas.drawPath(path.shift(const Offset(0, 5)), shadowPaint);

    // Draw shape
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
