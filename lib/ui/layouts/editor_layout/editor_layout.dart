import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:string_extensions/string_extensions.dart';

import '../../../app/models/note.dart';
import '../../../globals.dart';
import 'note_description.dart';
import 'note_title.dart';

final _logger = Logger();

/// Editor/Viewer of note
class EditorLayout extends StatefulWidget {
  /// Init the editor with a given [noteID]
  const EditorLayout({required Note? noteID, super.key}) : _note = noteID;

  /// The note ID
  /// If not null, the note will load. Otherwise the editor creates a new one
  final Note? _note;

  @override
  State<EditorLayout> createState() => _EditorLayoutState();
}

class _EditorLayoutState extends State<EditorLayout> {
  final _db = FirebaseFirestore.instance;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late bool _loading = widget._note != null;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget._note != null) {
        _fetchDetails();
      }
    });
  }

  Future<void> _fetchDetails() async {
    final ref = _db.collection(notesCollection).doc(widget._note!.id);

    try {
      final shot = await ref.get();
      final note = Note.fromJson(shot.data()!);

      _titleController.text = note.title;
      _descriptionController.text = note.description;
    } on FirebaseException catch (err) {
      _logger.e('Failed to fetch notes', error: err);
      showError();
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => _loading
      ? Scaffold(appBar: AppBar())
      : Scaffold(
          appBar: AppBar(
            title: NoteTitle(titleController: _titleController),
          ),
          body: WillPopScope(
            onWillPop: _saveNote,
            child: SafeArea(
              child: SizedBox(
                width: double.maxFinite,
                height: double.maxFinite,
                child: NoteDescription(descriptionController: _descriptionController),
              ),
            ),
          ),
        );

  Future<bool> _saveNote() async {
    if (_descriptionController.text.isNotBlank) {
      final note = Note(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      Navigator.pop(context, note);
    } else {
      Fluttertoast.showToast(msg: 'Empty note discarded');
    }

    return true;
  }
}
