import 'package:hive/hive.dart';

class NoteModel extends HiveObject {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> images;
  final bool isPinned;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.images = const [],
    this.isPinned = false,
  });

  factory NoteModel.create(
      {required String content,
      String title = '',
      List<String> images = const [],
      bool isPinned = false}) {
    final now = DateTime.now();
    // Use provided title or fallback to extracting from content
    final finalTitle = title.isNotEmpty
        ? title
        : (content.trim().split('\n').firstOrNull ?? 'New Note');

    return NoteModel(
      id: now.millisecondsSinceEpoch.toString(),
      title: finalTitle,
      content: content,
      createdAt: now,
      updatedAt: now,
      images: images,
      isPinned: isPinned,
    );
  }

  NoteModel copyWith({
    String? title,
    String? content,
    List<String>? images,
    DateTime? updatedAt,
    bool? isPinned,
  }) {
    return NoteModel(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      images: images ?? this.images,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}

// Manual TypeAdapter implementation
class NoteModelAdapter extends TypeAdapter<NoteModel> {
  @override
  final int typeId = 1;

  @override
  @override
  NoteModel read(BinaryReader reader) {
    final id = reader.readString();
    final title = reader.readString();
    final content = reader.readString();
    final createdAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final updatedAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final images = (reader.readList()).cast<String>();

    bool isPinned = false;
    try {
      isPinned = reader.readBool();
    } catch (e) {
      // Legacy data might not have isPinned
    }

    return NoteModel(
      id: id,
      title: title,
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt,
      images: images,
      isPinned: isPinned,
    );
  }

  @override
  void write(BinaryWriter writer, NoteModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.content);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.writeInt(obj.updatedAt.millisecondsSinceEpoch);
    writer.writeList(obj.images);
    writer.writeBool(obj.isPinned);
  }
}
