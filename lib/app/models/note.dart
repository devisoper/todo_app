/// Represents the note model
class Note {
  /// Init
  Note({required this.title, required this.description});

  /// Creates an instance from a given [json]
  factory Note.fromJson(Map<String, dynamic> json) => Note(
        title: json['title'],
        description: json['description'],
      );

  /// Note's ID
  late final String id;

  /// Note's title
  final String title;

  /// Note's description
  final String description;

  /// Converts the note to JSON (used to save a Firestore record)
  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
      };

  /// Whether if this note is different from a given [note]
  bool isDifferentFrom(Note note) =>
      title.trim() != note.title.trim() || description.trim() != note.description.trim();
}
