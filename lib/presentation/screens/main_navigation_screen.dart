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

    // Prevent unnecessary navigation if already on the page
    if (_currentIndex == pageIndex) return;

    // Animate smoothly to the page - state will be updated by onPageChanged
    _pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _startListening() async {
    // Switch to Home screen if not already there
    if (_currentIndex != 0) {
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
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
          setState(() {
            _currentIndex = index;
          });
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

    // Responsive dimensions
    final barHeight = 85.0;
    final navIconSize = (screenWidth * 0.065).clamp(24.0, 30.0);
    final micButtonSize = (screenWidth * 0.15).clamp(54.0, 68.0);
    final micIconSize = navIconSize * 1.0;
    final centerGap = micButtonSize * 0.8;

    // Bottom padding for safe area logic
    final bottomMargin = MediaQuery.of(context).padding.bottom > 0
        ? MediaQuery.of(context).padding.bottom + 8
        : 20.0;

    return Container(
      width: screenWidth,
      height: barHeight,
      margin: EdgeInsets.only(
        bottom: bottomMargin,
        left: 16,
        right: 16,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Background Shape with Shadow
          Positioned.fill(
            child: CustomPaint(
              painter: CozyBarPainter(
                color: Theme.of(context).colorScheme.surface,
                shadowColor: Colors.black.withValues(alpha: 0.15),
              ),
            ),
          ),

          // Navigation Items
          Padding(
            padding: const EdgeInsets.only(top: 20), // Align with bar body
            child: Row(
              children: [
                _buildNavItem(
                    context, 0, Icons.grid_view_rounded, "Home", navIconSize),
                _buildNavItem(
                    context, 1, Icons.bar_chart_rounded, "Stats", navIconSize),
                SizedBox(width: centerGap),
                _buildNavItem(
                    context, 3, Icons.note_alt_rounded, "Notes", navIconSize),
                _buildNavItem(context, 4, Icons.settings_rounded, "Settings",
                    navIconSize),
              ],
            ),
          ),

          // Center Mic Button
          Positioned(
            top:
                6, // Inset from the bump peak (0) to create "white space" above
            child: GestureDetector(
              onTap: onVoiceTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: micButtonSize,
                height: micButtonSize,
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
                      blurRadius: 15,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.mic_rounded,
                  color: Colors.white,
                  size: micIconSize,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon,
      String label, double iconSize) {
    int pageIndex = index;
    if (index > 2) pageIndex = index - 1;

    final isSelected = currentIndex == pageIndex;
    final color = isSelected
        ? AppTheme.primaryIndigo
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3);

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 200),
          scale: isSelected ? 1.1 : 1.0,
          curve: Curves.easeOutBack,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color,
                size: iconSize,
              ),
              const Gap(4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isSelected ? 4 : 0,
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
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    final path = Path();

    const double cornerRadius = 24.0;
    const double top = 20.0;
    final double center = size.width / 2;

    // Bump parameters - more organic
    const double bumpWidth = 45.0; // Width of the curve base

    path.moveTo(0, top + cornerRadius);

    // Top left corner
    path.quadraticBezierTo(0, top, cornerRadius, top);

    // Line to bump start
    path.lineTo(center - bumpWidth - 15, top);

    // Smoother organic transition to the bump
    path.cubicTo(
      center - bumpWidth + 5,
      top,
      center - bumpWidth + 5,
      0,
      center,
      0,
    );

    path.cubicTo(
      center + bumpWidth - 5,
      0,
      center + bumpWidth - 5,
      top,
      center + bumpWidth + 15,
      top,
    );

    // Top right corner
    path.lineTo(size.width - cornerRadius, top);
    path.quadraticBezierTo(size.width, top, size.width, top + cornerRadius);

    // Right side and bottom
    path.lineTo(size.width, size.height - cornerRadius);
    path.quadraticBezierTo(
        size.width, size.height, size.width - cornerRadius, size.height);
    path.lineTo(cornerRadius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);

    path.close();

    // Draw shadow first
    canvas.drawPath(path.shift(const Offset(0, 4)), shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
