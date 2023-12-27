import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents the note model
class Note {
  /// Init
  Note({required this.id, required this.title, required this.description});

  /// Creates an instance from a given [DocumentSnapshot]
  factory Note.fromSnapshot(DocumentSnapshot shot) {
    final data = shot.data()! as Map<String, dynamic>;

    return Note(
      id: shot.id,
      title: data['title'],
      description: data['description'],
    );
  }

  /// Date the note was created
  static const createdAt = 'created_at';

  /// Date the note was updated
  static const updatedAt = 'updated_at';

  /// Note's ID
  final String? id;

  /// Note's title
  final String title;

  /// Note's description
  final String description;

  /// Converts the note to JSON (used to save a Firestore record)
  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
      };

  /// Whether if this note is different from other given [note]
  bool isDifferentFrom(Note note) =>
      title.trim() != note.title.trim() || description.trim() != note.description.trim();

  /// Copies the note with a given [id]
  Note copyWithID(String id) => Note(
        id: id,
        title: title,
        description: description,
      );
}
