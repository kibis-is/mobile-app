import 'package:flutter/material.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/theme/color_palette.dart';

ElevatedButtonThemeData elevatedButtonTheme({
  required Color backgroundColor,
  required Color foregroundColor,
}) {
  return ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(backgroundColor),
      foregroundColor: WidgetStateProperty.all(foregroundColor),
      textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 24)),
      padding: WidgetStateProperty.all(const EdgeInsets.all(kButtonPadding)),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kWidgetRadius),
        ),
      ),
    ),
  );
}

ElevatedButtonThemeData elevatedButtonThemeLight() {
  return elevatedButtonTheme(
    backgroundColor: ColorPalette.lightThemeMauveine,
    foregroundColor: ColorPalette.lightThemeAntiFlashWhite,
  );
}

ElevatedButtonThemeData elevatedButtonThemeDark() {
  return elevatedButtonTheme(
    backgroundColor: ColorPalette.darkThemeMauve,
    foregroundColor: ColorPalette.darkThemeAntiflashWhite,
  );
}
