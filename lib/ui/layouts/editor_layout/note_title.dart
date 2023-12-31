import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Editor App Bar Title
class NoteTitle extends StatefulWidget {
  /// Init
  const NoteTitle({required String initialText, required TextEditingController titleController, super.key})
      : _initialText = initialText,
        _titleController = titleController;

  final String _initialText;
  final TextEditingController _titleController;

  @override
  State<NoteTitle> createState() => _NoteTitleState();
}

class _NoteTitleState extends State<NoteTitle> {
  final _focusNode = FocusNode();

  bool _isEditorVisible = false;
  late String _text = widget._initialText;

  @override
  void initState() {
    widget._titleController.text = widget._initialText;

    super.initState();
  }

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          if (!_isEditorVisible)
            GestureDetector(
              onTap: _editTitle,
              child: Text(_text),
            )
          else
            Row(
              children: [
                Expanded(
                  child: Platform.isIOS
                      ? CupertinoTextField(
                          controller: widget._titleController,
                          focusNode: _focusNode,
                          style: Theme.of(context).textTheme.titleLarge,
                          placeholder: 'My note',
                        )
                      : TextField(
                          controller: widget._titleController,
                          focusNode: _focusNode,
                          style: Theme.of(context).textTheme.titleLarge,
                          decoration: const InputDecoration.collapsed(
                            hintText: 'My note',
                          ),
                        ),
                ),
                if (Platform.isIOS)
                  CupertinoButton(
                    onPressed: _saveTitle,
                    child: const Text('Save'),
                  )
                else
                  IconButton(
                    onPressed: _saveTitle,
                    icon: const Icon(Icons.done_outlined),
                  ),
              ],
            ),
        ],
      );

  void _editTitle() {
    setState(() => _isEditorVisible = true);
    _focusNode.requestFocus();
  }

  void _saveTitle() => setState(() {
        _text = widget._titleController.text;
        _isEditorVisible = false;
      });
}
