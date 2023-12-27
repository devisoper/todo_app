import 'package:flutter/material.dart';

import '../models/note.dart';

/// The notes_list.dart widget state
class NotesState extends ChangeNotifier {
  final _notes = <Note>[];

  /// Adds a new note at the beginning
  void addNewNote(Note note) {
    _notes.insert(0, note);
    notifyListeners();
  }

  /// Adds new notes at the beginning
  void addNotes(List<Note> notes) {
    _notes.insertAll(0, notes.reversed);
    notifyListeners();
  }

  /// Deletes a note
  void deleteNote(Note note) {
    _notes.remove(note);
    notifyListeners();
  }

  /// Updates a note
  void updateNote(Note oldNote, Note newNote) {
    final index = _notes.indexOf(oldNote);
    _notes[index] = newNote;

    notifyListeners();
  }

  /// The notes
  List<Note> get notes => _notes;
}
