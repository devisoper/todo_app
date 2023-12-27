import 'package:fluttertoast/fluttertoast.dart';

/// Firestore Notes Collection
const notesCollection = 'notes';

/// Shows a general error
void showError() => Fluttertoast.showToast(
      msg: 'Ups, something went wrong. Please try again later.',
    );
