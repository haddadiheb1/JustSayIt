import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:say_task/core/theme/app_theme.dart';
import 'package:say_task/data/models/note_model.dart';
import 'package:say_task/presentation/providers/note_provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class NoteEditorScreen extends ConsumerStatefulWidget {
  final NoteModel? note;

  const NoteEditorScreen({super.key, this.note});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late final TextEditingController _contentController;
  late final TextEditingController _titleController;
  final List<String> _selectedImages = [];
  bool _isEditing = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _contentController =
        TextEditingController(text: widget.note?.content ?? '');
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _isEditing = widget.note != null;
    if (widget.note?.images != null) {
      _selectedImages.addAll(widget.note!.images);
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      // Copy to app dir to persist
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String extension = p.extension(image.path);
      // Create unique name to avoid conflicts
      final String uniqueName =
          '${DateTime.now().millisecondsSinceEpoch}$extension';
      final String savedPath = p.join(appDir.path, uniqueName);

      await File(image.path).copy(savedPath);

      if (!mounted) return;

      setState(() {
        _selectedImages.add(savedPath);
      });
    } catch (e) {
      debugPrint('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _saveNote() {
    if (_contentController.text.trim().isEmpty && _selectedImages.isEmpty) {
      return;
    }

    final String content = _contentController.text.trim();
    final String title = _titleController.text.trim();
    final List<String> images = List.from(_selectedImages);

    if (_isEditing && widget.note != null) {
      final updatedNote = widget.note!.copyWith(
        title: title.isEmpty ? 'Untitled Note' : title,
        content: content,
        images: images,
        updatedAt: DateTime.now(),
      );
      ref.read(updateNoteProvider(updatedNote));
    } else {
      final note =
          NoteModel.create(title: title, content: content, images: images);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Note' : 'New Note'),
        actions: [
          IconButton(
            onPressed: _pickImage,
            icon: const Icon(Icons.image_outlined),
            tooltip: 'Add Image',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              constraints: const BoxConstraints(
                minHeight: 200,
                maxHeight: 400,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    enabled: true, // Only allow editing if proper
                    decoration: const InputDecoration(
                      hintText: 'Title',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                      hintStyle: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Divider(
                      color: Theme.of(context)
                          .dividerColor
                          .withValues(alpha: 0.2)),
                  TextField(
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
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            if (_selectedImages.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final imagePath = _selectedImages[index];
                    return Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: FileImage(File(imagePath)),
                              fit: BoxFit.cover,
                            ),
                            border: Border.all(
                                color: Colors.grey.withValues(alpha: 0.3)),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Tip: ${_isEditing ? "Swipe left on a note to delete it quickly" : "Add a title to organize your notes better"}',
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
