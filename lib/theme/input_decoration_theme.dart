// Common InputDecorationTheme
import 'package:flutter/material.dart';
import 'package:kibisis/constants/constants.dart';

InputDecorationTheme inputDecorationTheme(
    Color borderColor, Color focusedBorderColor) {
  return InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kWidgetRadius),
      borderSide: BorderSide(color: borderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kWidgetRadius),
      borderSide: BorderSide(color: borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kWidgetRadius),
      borderSide: BorderSide(color: focusedBorderColor),
    ),
  );
}
