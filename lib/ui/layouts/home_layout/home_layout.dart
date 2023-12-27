import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../../../app/models/note.dart';
import '../../../app/providers/notes_state.dart';
import '../../../app/router/router.dart';
import '../../../app/router/routes.dart';
import '../../../globals.dart';
import 'notes_list.dart';

final _logger = Logger();

/// Home Layout
class HomeLayout extends StatelessWidget {
  /// Init
  const HomeLayout({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => NotesState(),
        child: Builder(
          builder: (context) {
            final notesState = Provider.of<NotesState>(context, listen: false);

            return Scaffold(
              appBar: AppBar(
                title: const Text('My notes'),
              ),
              body: const SafeArea(
                child: NotesList(),
              ),
              floatingActionButton: _FabAction(notesState.addNewNote),
            );
          },
        ),
      );
}

class _FabAction extends StatefulWidget {
  const _FabAction(Function(Note) onNoteAdded) : _onNoteAdded = onNoteAdded;

  final Function(Note) _onNoteAdded;

  @override
  State<_FabAction> createState() => _FabActionState();
}

class _FabActionState extends State<_FabAction> {
  final _db = FirebaseFirestore.instance;
  bool _uploadingNote = false;

  @override
  Widget build(BuildContext context) => FloatingActionButton(
        onPressed: _createNote,
        child: _uploadingNote
            ? Platform.isIOS
                ? const CupertinoActivityIndicator()
                : const CircularProgressIndicator()
            : Icon(Platform.isIOS ? CupertinoIcons.add : Icons.add_outlined),
      );

  Future<void> _createNote() async {
    if (_uploadingNote) {
      return;
    }

    final newNote = await router.pushNamed<Note?>(routeEditorLayout);

    if (newNote != null) {
      setState(() => _uploadingNote = true);

      final ref = _db.collection(notesCollection).doc();

      try {
        await ref.set(
          newNote.toJson()
            ..putIfAbsent('created', FieldValue.serverTimestamp)
            ..putIfAbsent('updated', FieldValue.serverTimestamp),
        );
        widget._onNoteAdded(newNote..id = ref.id);
      } on FirebaseException catch (err) {
        _logger.e('Failed to fetch notes', error: err);
        showError();
      }

      setState(() => _uploadingNote = false);
    }
  }
}
