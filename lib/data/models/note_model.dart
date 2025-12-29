import 'package:hive/hive.dart';

class NoteModel extends HiveObject {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> images;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.images = const [],
  });

  factory NoteModel.create(
      {required String content, List<String> images = const []}) {
    final now = DateTime.now();
    final lines = content.trim().split('\n');
    final title = lines.first.isEmpty
        ? (content.length > 50 ? '${content.substring(0, 50)}...' : content)
        : lines.first;

    return NoteModel(
      id: now.millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
      images: images,
    );
  }

  NoteModel copyWith({
    String? title,
    String? content,
    List<String>? images,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      images: images ?? this.images,
    );
  }
}

// Manual TypeAdapter implementation
class NoteModelAdapter extends TypeAdapter<NoteModel> {
  @override
  final int typeId = 1;

  @override
  NoteModel read(BinaryReader reader) {
    return NoteModel(
      id: reader.readString(),
      title: reader.readString(),
      content: reader.readString(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      images: (reader.readList()).cast<String>(),
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
  }
}
