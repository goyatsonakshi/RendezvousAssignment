import 'package:flutter/material.dart';
import '../../theme.dart'; // Import theme for consistent styling

// Reusable function to show a styled dialog.
Future<void> showCustomDialog(
    BuildContext context, String title, String content) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true, // Allow dismissing by tapping outside
    builder: (BuildContext context) {
      return AlertDialog(
        // Use theme styles
        backgroundColor: AppTheme.tanLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: const BorderSide(color: AppTheme.strokeBlue, width: 1),
        ),
        title: Text(title, style: AppTheme.headlineStyle.copyWith(fontSize: 20)),
        content: SingleChildScrollView( // Ensure content is scrollable
          child: Text(content, style: AppTheme.bodyStyle),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('OK', style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold)),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.fontBlue,
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      );
    },
  );
}


// Note: The Failure classes should remain in lib/core/error/failures.dart
// This file is now just for the dialog widget function.
