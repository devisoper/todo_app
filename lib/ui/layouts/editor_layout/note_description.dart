import 'package:flutter/material.dart';

/// Note description editor
class NoteDescription extends StatelessWidget {
  /// Init
  const NoteDescription({required TextEditingController descriptionController, super.key})
      : _descriptionController = descriptionController;

  final TextEditingController _descriptionController;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _descriptionController,
          decoration: const InputDecoration.collapsed(hintText: 'Add description...'),
        ),
      );
}
