import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/api/notes_api.dart';
import '../../../app/models/note.dart';
import '../../../app/providers/notes_state.dart';
import '../../../app/router/router.dart';
import '../../../app/router/routes.dart';
import 'notes_fetcher.dart';

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
              appBar: AppBar(title: const Text('My notes')),
              body: const SafeArea(child: NotesFetcher()),
              floatingActionButton: _AddNoteFAB(notesState.addNewNote),
            );
          },
        ),
      );
}

class _AddNoteFAB extends StatefulWidget {
  const _AddNoteFAB(Function(Note) onNoteAdded) : _onNoteAdded = onNoteAdded;

  final Function(Note) _onNoteAdded;

  @override
  State<_AddNoteFAB> createState() => _AddNoteFABState();
}

class _AddNoteFABState extends State<_AddNoteFAB> {
  bool _savingNote = false;

  @override
  Widget build(BuildContext context) => FloatingActionButton(
        onPressed: !_savingNote ? _createNote : null,
        child: Icon(Platform.isIOS ? CupertinoIcons.add : Icons.add_outlined),
      );

  Future<void> _createNote() async {
    final newNote = await router.pushNamed<Note?>(routeEditorLayout);

    if (newNote != null) {
      setState(() => _savingNote = true);

      final newID = await insertNote(newNote);

      if (newID != null) {
        widget._onNoteAdded(newNote.copyWithID(newID));
      }

      if (mounted) {
        setState(() => _savingNote = false);
      }
    }
  }
}
