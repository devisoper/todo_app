import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Note description editor
class NoteDescription extends StatefulWidget {
  /// Init
  const NoteDescription({required TextEditingController descriptionController, super.key})
      : _descriptionController = descriptionController;

  final TextEditingController _descriptionController;

  @override
  State<NoteDescription> createState() => _NoteDescriptionState();
}

class _NoteDescriptionState extends State<NoteDescription> {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Platform.isIOS
            ? CupertinoTextField(
                controller: widget._descriptionController,
                placeholder: 'Add description...',
                textAlignVertical: TextAlignVertical.top,
              )
            : TextField(
                controller: widget._descriptionController,
                decoration: const InputDecoration.collapsed(hintText: 'Add description...'),
              ),
      );
}
