import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_say_it/presentation/providers/settings_provider.dart';
import 'package:just_say_it/presentation/providers/task_provider.dart';
import 'package:just_say_it/data/repositories/note_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance Section
          _buildSectionHeader('Appearance'),
          _buildThemeSelector(themeMode),
          const SizedBox(height: 24),

          // Notifications Section
          _buildSectionHeader('Notifications'),
          _buildNotificationToggle(notificationsEnabled),
          const SizedBox(height: 24),

          // Data Management Section
          _buildSectionHeader('Data Management'),
          _buildClearTasksButton(),
          const SizedBox(height: 12),
          _buildClearNotesButton(),
          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader('About'),
          _buildPrivacyPolicyLink(),
          const SizedBox(height: 12),
          _buildAppVersion(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildThemeSelector(ThemeMode currentMode) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          _buildThemeOption(
            'Light',
            Icons.light_mode_outlined,
            ThemeMode.light,
            currentMode,
          ),
          Divider(
              height: 1,
              color: Theme.of(context).dividerColor.withValues(alpha: 0.2)),
          _buildThemeOption(
            'Dark',
            Icons.dark_mode_outlined,
            ThemeMode.dark,
            currentMode,
          ),
          Divider(
              height: 1,
              color: Theme.of(context).dividerColor.withValues(alpha: 0.2)),
          _buildThemeOption(
            'System',
            Icons.brightness_auto_outlined,
            ThemeMode.system,
            currentMode,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
      String label, IconData icon, ThemeMode mode, ThemeMode currentMode) {
    final isSelected = mode == currentMode;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
      onTap: () {
        ref.read(themeModeProvider.notifier).setThemeMode(mode);
      },
    );
  }

  Widget _buildNotificationToggle(bool enabled) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: SwitchListTile(
        secondary: Icon(
          Icons.notifications_outlined,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        title: const Text('Task Reminders'),
        subtitle: const Text('Get notified about upcoming tasks'),
        value: enabled,
        onChanged: (value) {
          ref
              .read(notificationsEnabledProvider.notifier)
              .setNotificationsEnabled(value);
        },
      ),
    );
  }

  Widget _buildClearTasksButton() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: ListTile(
        leading: Icon(
          Icons.delete_outline,
          color: Theme.of(context).colorScheme.error,
        ),
        title: const Text('Clear All Tasks'),
        subtitle: const Text('Delete all tasks permanently'),
        onTap: () => _showClearConfirmation('tasks'),
      ),
    );
  }

  Widget _buildClearNotesButton() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: ListTile(
        leading: Icon(
          Icons.delete_outline,
          color: Theme.of(context).colorScheme.error,
        ),
        title: const Text('Clear All Notes'),
        subtitle: const Text('Delete all notes permanently'),
        onTap: () => _showClearConfirmation('notes'),
      ),
    );
  }

  Widget _buildPrivacyPolicyLink() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: ListTile(
        leading: Icon(
          Icons.privacy_tip_outlined,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        title: const Text('Privacy Policy'),
        trailing: const Icon(Icons.open_in_new, size: 20),
        onTap: () {
          // TODO: Open privacy policy URL
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Privacy policy link will be added soon')),
          );
        },
      ),
    );
  }

  Widget _buildAppVersion() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: ListTile(
        leading: Icon(
          Icons.info_outline,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        title: const Text('App Version'),
        trailing: Text(
          _appVersion.isEmpty ? '1.0.0' : _appVersion,
          style: TextStyle(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  Future<void> _showClearConfirmation(String type) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear All ${type == 'tasks' ? 'Tasks' : 'Notes'}?'),
        content: Text(
          'This will permanently delete all your ${type}. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      if (type == 'tasks') {
        await _clearAllTasks();
      } else {
        await _clearAllNotes();
      }
    }
  }

  Future<void> _clearAllTasks() async {
    final tasks = await ref.read(taskListProvider.future);
    for (final task in tasks) {
      await ref.read(deleteTaskProvider(task.id).future);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All tasks deleted')),
      );
    }
  }

  Future<void> _clearAllNotes() async {
    final noteRepo = ref.read(noteRepositoryProvider);
    final notes = noteRepo.getNotes();
    for (final note in notes) {
      await noteRepo.deleteNote(note.id);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All notes deleted')),
      );
    }
  }
}
