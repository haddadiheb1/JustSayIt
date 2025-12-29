import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:say_task/data/models/note_model.dart';
import 'package:say_task/data/repositories/note_repository.dart';

part 'note_provider.g.dart';

@riverpod
class NoteList extends _$NoteList {
  @override
  Stream<List<NoteModel>> build() {
    final repository = ref.watch(noteRepositoryProvider);
    return repository.watchNotes();
  }
}

@riverpod
Future<void> addNote(Ref ref, NoteModel note) async {
  final repository = ref.read(noteRepositoryProvider);
  await repository.addNote(note);
}

@riverpod
Future<void> deleteNote(Ref ref, String id) async {
  final repository = ref.read(noteRepositoryProvider);
  await repository.deleteNote(id);
}

@riverpod
Future<void> updateNote(Ref ref, NoteModel note) async {
  final repository = ref.read(noteRepositoryProvider);
  await repository.updateNote(note);
}

@riverpod
Future<void> initializeNotes(Ref ref) async {
  final repository = ref.read(noteRepositoryProvider);
  await repository.init();
}
