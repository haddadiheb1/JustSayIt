import 'package:freezed_annotation/freezed_annotation.dart';

part 'note.freezed.dart';

@freezed
class Note with _$Note {
  const factory Note({
    required String id,
    required String title,
    required String content,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Note;

  factory Note.create({
    required String content,
  }) {
    final now = DateTime.now();
    // Extract first line as title, or use first 50 chars
    final lines = content.trim().split('\n');
    final title = lines.first.isEmpty
        ? (content.length > 50 ? '${content.substring(0, 50)}...' : content)
        : lines.first;

    return Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
    );
  }
}
