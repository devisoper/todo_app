import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:string_extensions/string_extensions.dart';

import '../../../app/models/note.dart';
import 'note_description.dart';
import 'note_title.dart';

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
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDetails());
  }

  Future<void> _loadDetails() async {
    if (widget._note != null) {
      _titleController.text = widget._note!.title;
      _descriptionController.text = widget._note!.description;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: NoteTitle(
            initialText: widget._note?.title ?? 'My note',
            titleController: _titleController,
          ),
        ),
        body: WillPopScope(
          onWillPop: _popNote,
          child: SafeArea(
            child: SizedBox(
              width: double.maxFinite,
              height: double.maxFinite,
              child: NoteDescription(descriptionController: _descriptionController),
            ),
          ),
        ),
      );

  Future<bool> _popNote() async {
    if (_descriptionController.text.isNotBlank) {
      final note = Note(
        id: null,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      Navigator.pop(context, note);
    } else {
      Fluttertoast.showToast(msg: 'Discarded empty note');
    }

    return true;
  }
}
