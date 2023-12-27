import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../../../app/models/note.dart';
import '../../../app/providers/notes_state.dart';
import '../../../app/router/router.dart';
import '../../../app/router/routes.dart';
import '../../../globals.dart';

final _logger = Logger();

/// Loads all notes from Firestore
class NotesList extends StatefulWidget {
  /// Init
  const NotesList({super.key});

  @override
  State<NotesList> createState() => _NotesListState();
}

class _NotesListState extends State<NotesList> {
  static const _limit = 5;

  final _db = FirebaseFirestore.instance;
  late final _state = Provider.of<NotesState>(context, listen: false);

  bool _loading = true;
  bool _allLoaded = false;
  DocumentSnapshot? _lastDocument;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchNotes());
  }

  Future<void> _fetchNotes() async {
    if (_allLoaded) {
      Fluttertoast.showToast(msg: 'All notes have been loaded');
      return;
    }

    setState(() => _loading = true);

    final ref = _db.collection(notesCollection);

    try {
      var query = ref.orderBy('updated');
      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }
      query = query.limit(_limit);

      final response = await query.get();

      final notes = response.docs.map((e) => Note.fromJson(e.data())..id = e.id).toList();

      _allLoaded = notes.length < _limit;
      _lastDocument = response.docs.lastOrNull;

      _state.addNotes(notes);
    } on FirebaseException catch (err) {
      _logger.e('Failed to fetch notes', error: err);
      showError();
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          if (_loading) const LinearProgressIndicator(),
          Column(
            children: [
              const Expanded(child: _ListNotes()),
              if (Platform.isIOS)
                CupertinoButton(
                  onPressed: _fetchNotes,
                  child: const Text('Load more'),
                )
              else
                TextButton(
                  onPressed: _fetchNotes,
                  child: const Text('Load more'),
                ),
            ],
          ),
        ],
      );
}

class _ListNotes extends StatefulWidget {
  const _ListNotes();

  @override
  State<_ListNotes> createState() => _ListNotesState();
}

class _ListNotesState extends State<_ListNotes> {
  final _db = FirebaseFirestore.instance;

  Note? _updatingNote;

  @override
  Widget build(BuildContext context) => Consumer<NotesState>(
        builder: (_, state, __) {
          if (state.notes.isEmpty) {
            return const Center(
              child: Text('No notes'),
            );
          }

          return ListView.builder(
            itemCount: state.notes.length,
            itemBuilder: (context, index) {
              final note = state.notes[index];

              return Dismissible(
                key: Key(note.id),
                confirmDismiss: (_) async => _deleteNote(state, note),
                background: Container(
                  color: Theme.of(context).colorScheme.errorContainer,
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(Platform.isIOS ? CupertinoIcons.delete : Icons.delete_outlined),
                  ),
                ),
                child: ListTile(
                  enabled: _updatingNote?.id != note.id,
                  title: Text(note.title),
                  subtitle: Text(
                    note.description,
                    maxLines: 2,
                  ),
                  onTap: () => _updateNote(state, note),
                ),
              );
            },
          );
        },
      );

  Future<bool> _deleteNote(NotesState state, Note note) async {
    final ref = _db.collection(notesCollection).doc(note.id);

    try {
      await ref.delete();
      state.deleteNote(note);
      return true;
    } on FirebaseException catch (err) {
      _logger.e('Failed to fetch notes', error: err);
      showError();
    }

    return false;
  }

  Future<void> _updateNote(NotesState state, Note oldNote) async {
    final updatedNote = await router.pushNamed<Note?>(routeEditorLayout, extra: oldNote);

    if (updatedNote != null && oldNote.isDifferentFrom(updatedNote)) {
      setState(() => _updatingNote = oldNote);

      final ref = _db.collection(notesCollection).doc(oldNote.id);

      try {
        await ref.update(updatedNote.toJson()..putIfAbsent('updated', FieldValue.serverTimestamp));
        state.updateNote(oldNote, updatedNote..id = oldNote.id);
      } on FirebaseException catch (err) {
        _logger.e('Failed to fetch notes', error: err);
        showError();
      }

      setState(() => _updatingNote = null);
    }
  }
}
