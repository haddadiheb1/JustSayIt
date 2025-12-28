import 'package:hive/hive.dart';
import 'package:just_say_it/data/models/note_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepositoryImpl();
});

abstract class NoteRepository {
  Future<void> init();
  List<NoteModel> getNotes();
  Stream<List<NoteModel>> watchNotes();
  Future<void> addNote(NoteModel note);
  Future<void> updateNote(NoteModel note);
  Future<void> deleteNote(String id);
}

class NoteRepositoryImpl implements NoteRepository {
  static const String _boxName = 'notes';
  Box<NoteModel>? _box;

  @override
  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<NoteModel>(_boxName);
    } else {
      _box = Hive.box<NoteModel>(_boxName);
    }
  }

  @override
  List<NoteModel> getNotes() {
    return _box?.values.toList() ?? [];
  }

  @override
  Stream<List<NoteModel>> watchNotes() async* {
    yield getNotes();
    yield* _box!.watch().map((_) => getNotes());
  }

  @override
  Future<void> addNote(NoteModel note) async {
    await _box?.put(note.id, note);
  }

  @override
  Future<void> updateNote(NoteModel note) async {
    await _box?.put(note.id, note);
  }

  @override
  Future<void> deleteNote(String id) async {
    await _box?.delete(id);
  }
}
