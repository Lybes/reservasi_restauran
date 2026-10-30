import 'package:flutter/material.dart';

/// Padanan Toast.makeText(...).show()
void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
