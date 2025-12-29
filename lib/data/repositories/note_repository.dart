import 'package:hive/hive.dart';
import 'package:say_task/data/models/note_model.dart';
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

  Box<NoteModel> get _ensureBox {
    if (_box == null || !_box!.isOpen) {
      if (Hive.isBoxOpen(_boxName)) {
        _box = Hive.box<NoteModel>(_boxName);
      }
    }
    return _box!;
  }

  @override
  List<NoteModel> getNotes() {
    try {
      return _ensureBox.values.toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Stream<List<NoteModel>> watchNotes() async* {
    yield getNotes();
    try {
      yield* _ensureBox.watch().map((_) => getNotes());
    } catch (e) {
      // If box is not available, just yield empty list
      yield [];
    }
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
