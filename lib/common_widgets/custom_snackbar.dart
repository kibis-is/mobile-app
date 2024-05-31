import 'package:flutter/material.dart';
import 'package:kibisis/utils/theme_extensions.dart';

enum SnackType {
  neutral,
  success,
  error,
}

SnackBar customSnackbar({
  required BuildContext context,
  required String message,
  SnackType snackType = SnackType.neutral, // Default to neutral if not provided
}) {
  return SnackBar(
    content: Text(
      message,
      style: TextStyle(color: context.colorScheme.onPrimary)
          .copyWith(fontWeight: FontWeight.bold),
    ),
    backgroundColor: _getSnackbarColor(
        context, snackType), // Use helper function to determine the color
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.all(16),
    duration: const Duration(seconds: 5),
    action: SnackBarAction(
      label: 'CLOSE',
      onPressed: () {},
    ),
  );
}

Color _getSnackbarColor(BuildContext context, SnackType snackType) {
  switch (snackType) {
    case SnackType.success:
      return context.colorScheme.secondary;
    case SnackType.error:
      return context.colorScheme.error;
    case SnackType.neutral:
    default:
      return context.colorScheme.primary; // Default color
  }
}
