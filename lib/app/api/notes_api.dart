import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

import '../../globals.dart';
import '../models/note.dart';

final _logger = Logger();
final _collection = FirebaseFirestore.instance.collection(notesCollection);

/// Fetch notes from Firestore and returns them next to the last snapshot reference
Future<(List<Note>, DocumentSnapshot?)?> getNotes(DocumentSnapshot? startAfterDoc, int limit) async {
  var query = _collection.orderBy(Note.updatedAt);
  if (startAfterDoc != null) {
    query = query.startAfterDocument(startAfterDoc);
  }
  query = query.limit(limit);

  try {
    final response = await query.get();

    final notes = response.docs.map(Note.fromSnapshot).toList();

    return (notes, response.docs.lastOrNull);
  } on FirebaseException catch (err) {
    _logger.e('Failed to fetch notes', error: err);
    showError();
  }

  return null;
}

/// Inserts a note to Firestore
Future<String?> insertNote(Note note) async {
  try {
    final noteDoc = _collection.doc();
    final data = note.toJson()
      ..putIfAbsent(Note.createdAt, FieldValue.serverTimestamp)
      ..putIfAbsent(Note.updatedAt, FieldValue.serverTimestamp);

    await noteDoc.set(data);

    return noteDoc.id;
  } on FirebaseException catch (err) {
    _logger.e('Failed to fetch notes', error: err);
    showError();
  }

  return null;
}

/// Updates a note to Firestore
Future<bool> updateNote(Note oldNote, Note newNote) async {
  final noteDoc = _collection.doc(oldNote.id);
  final newData = newNote.toJson()..putIfAbsent(Note.updatedAt, FieldValue.serverTimestamp);

  try {
    await noteDoc.update(newData);

    return true;
  } on FirebaseException catch (err) {
    _logger.e('Failed to fetch notes', error: err);
    showError();
  }

  return false;
}

/// Deletes a note to Firestore
Future<bool> deleteNote(Note note) async {
  final noteDoc = _collection.doc(note.id);

  try {
    await noteDoc.delete();

    return true;
  } on FirebaseException catch (err) {
    _logger.e('Failed to fetch notes', error: err);
    showError();
  }

  return false;
}
