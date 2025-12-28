import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_say_it/core/theme/app_theme.dart';
import 'package:just_say_it/data/models/note_model.dart';
import 'package:just_say_it/presentation/providers/note_provider.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final NoteModel? note;

  const NoteEditorScreen({super.key, this.note});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late final TextEditingController _contentController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _contentController =
        TextEditingController(text: widget.note?.content ?? '');
    _isEditing = widget.note != null;
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    if (_contentController.text.trim().isEmpty) return;

    if (_isEditing && widget.note != null) {
      final lines = _contentController.text.trim().split('\n');
      final title = lines.first.isEmpty
          ? (_contentController.text.length > 50
              ? '${_contentController.text.substring(0, 50)}...'
              : _contentController.text)
          : lines.first;

      final updatedNote = NoteModel(
        id: widget.note!.id,
        title: title,
        content: _contentController.text.trim(),
        createdAt: widget.note!.createdAt,
        updatedAt: DateTime.now(),
      );
      ref.read(updateNoteProvider(updatedNote));
    } else {
      final note = NoteModel.create(content: _contentController.text.trim());
      ref.read(addNoteProvider(note));
    }

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(_isEditing ? 'Note updated!' : 'Note saved!'),
          ],
        ),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _deleteNote() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(deleteNoteProvider(widget.note!.id));
              Navigator.pop(context);
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.delete, color: Colors.white),
                      SizedBox(width: 12),
                      Text('Note deleted'),
                    ],
                  ),
                  backgroundColor: AppTheme.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  duration: const Duration(seconds: 2),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Note' : 'New Note'),
        actions: [
          if (_isEditing)
            IconButton(
              onPressed: _deleteNote,
              icon: const Icon(Icons.delete_outline),
              color: AppTheme.error,
              tooltip: 'Delete note',
            ),
          TextButton.icon(
            onPressed: _saveNote,
            icon: const Icon(Icons.check),
            label: const Text('Save'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryIndigo,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              constraints: const BoxConstraints(
                minHeight: 200,
                maxHeight: 400,
              ),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.divider),
              ),
              child: TextField(
                controller: _contentController,
                autofocus: !_isEditing,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Start typing your note...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                  hintStyle: TextStyle(
                    color: AppTheme.textSecondary,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tip: ${_isEditing ? "Swipe left on a note to delete it quickly" : "First line becomes the title"}',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
