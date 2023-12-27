import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../../app/api/notes_api.dart';
import '../../../app/models/note.dart';
import '../../../app/providers/notes_state.dart';
import '../../../app/router/router.dart';
import '../../../app/router/routes.dart';

/// Loads all notes from Firestore
class NotesFetcher extends StatefulWidget {
  /// Init
  const NotesFetcher({super.key});

  @override
  State<NotesFetcher> createState() => _NotesFetcherState();
}

class _NotesFetcherState extends State<NotesFetcher> {
  static const _limit = 5;

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

    final response = await getNotes(_lastDocument, _limit);

    if (response != null) {
      _state.addNotes(response.$1);
      _lastDocument = response.$2;

      _allLoaded = response.$1.length < _limit;
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
              const Expanded(
                child: _NotesList(),
              ),
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

class _NotesList extends StatefulWidget {
  const _NotesList();

  @override
  State<_NotesList> createState() => _NotesListState();
}

class _NotesListState extends State<_NotesList> {
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
                key: Key(note.id!),
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

  Future<void> _updateNote(NotesState state, Note oldNote) async {
    final newNote = await router.pushNamed<Note?>(routeEditorLayout, extra: oldNote);

    if (newNote != null && oldNote.isDifferentFrom(newNote)) {
      setState(() => _updatingNote = oldNote);

      if (await updateNote(oldNote, newNote)) {
        state.replaceNote(oldNote, newNote.copyWithID(oldNote.id!));
      }

      if (mounted) {
        setState(() => _updatingNote = null);
      }
    }
  }

  Future<bool> _deleteNote(NotesState state, Note note) async {
    if (await deleteNote(note)) {
      state.deleteNote(note);
      return true;
    }
    return false;
  }
}
