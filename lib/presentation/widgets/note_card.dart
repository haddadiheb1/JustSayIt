import 'package:flutter/material.dart';
import 'dart:io';

import 'package:say_task/data/models/note_model.dart';
import 'package:intl/intl.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const NoteCard({
    super.key,
    required this.note,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Simplified Card for Grid with Image Cover
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: const Color(0xFF252525), // Dark grey card background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        onLongPress: onDelete,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (note.images.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(note.images.first),
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        color: Colors.grey[800],
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image,
                            color: Colors.white54),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                note.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              if (note.content.isNotEmpty) ...[
                Text(
                  note.content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFB0BEC5), // Light grey text
                    height: 1.4,
                  ),
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
              ],
              Text(
                _formatDate(note.updatedAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF757575), // Darker grey date
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    if (now.difference(dateTime).inDays == 0) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (now.year == dateTime.year) {
      return DateFormat('MMMM d').format(dateTime);
    } else {
      return DateFormat('d/M/y').format(dateTime);
    }
  }
}
