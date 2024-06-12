// Common ListTileThemeData
import 'package:flutter/material.dart';
import 'package:kibisis/constants/constants.dart';

ListTileThemeData listTileTheme(Color tileColor) {
  return ListTileThemeData(
    tileColor: tileColor,
    contentPadding: const EdgeInsets.all(kSizedBoxSpacing),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(kWidgetRadius),
    ),
  );
}
