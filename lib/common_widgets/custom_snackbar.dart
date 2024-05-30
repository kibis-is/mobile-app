import 'package:flutter/material.dart';
import 'package:kibisis/utils/theme_extensions.dart';

SnackBar customSnackbar(BuildContext context, message) {
  return SnackBar(
    content: Text(
      message,
      style: TextStyle(color: context.colorScheme.onPrimary)
          .copyWith(fontWeight: FontWeight.bold),
    ),
    backgroundColor: context.colorScheme.primary,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.only(top: 0, left: 0, right: 0),
    duration: const Duration(seconds: 5),
    showCloseIcon: true,
  );
}
