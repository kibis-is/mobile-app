import 'package:flutter/material.dart';

SnackBar customSnackbar(BuildContext context, message) {
  return SnackBar(
    content: Text(
      message,
      style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)
          .copyWith(fontWeight: FontWeight.bold),
    ),
    backgroundColor: Theme.of(context).colorScheme.primary,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.only(top: 0, left: 0, right: 0),
    duration: const Duration(seconds: 5),
    showCloseIcon: true,
  );
}
