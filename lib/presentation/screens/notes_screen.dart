import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:say_task/presentation/screens/note_editor_screen.dart';
import 'package:say_task/presentation/providers/note_provider.dart';
import 'package:say_task/presentation/widgets/note_card.dart';
import 'package:say_task/data/models/note_model.dart';
import 'package:say_task/presentation/widgets/empty_state_widget.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final notesAsync = ref.watch(noteListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
      ),
      body: Stack(
        children: [
          notesAsync.when(
            data: (notes) {
              if (notes.isEmpty) {
                return const EmptyStateWidget(
                  message: 'No notes yet',
                  subMessage: 'Capture ideas fast',
                  icon: Icons.note_outlined,
                );
              }

              // Sort notes: Pinned first, then by date descending (newest first)
              final sortedNotes = List<NoteModel>.from(notes)
                ..sort((a, b) {
                  if (a.isPinned != b.isPinned) {
                    return a.isPinned ? -1 : 1;
                  }
                  return b.createdAt.compareTo(a.createdAt);
                });

              return ListView.builder(
                padding: const EdgeInsets.only(
                    top: 8, bottom: 120), // Increased bottom padding
                itemCount: sortedNotes.length,
                itemBuilder: (context, index) {
                  final note = sortedNotes[index];
                  return NoteCard(
                    note: note,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoteEditorScreen(note: note),
                        ),
                      );
                    },
                    onDelete: () {
                      ref.read(deleteNoteProvider(note.id));
                    },
                    onPin: () {
                      final updatedNote =
                          note.copyWith(isPinned: !note.isPinned);
                      ref.read(updateNoteProvider(updatedNote));
                    },
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Error: $error'),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 110, // Position above the 80px navbar + margin
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NoteEditorScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
