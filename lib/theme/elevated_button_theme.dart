import 'package:flutter/material.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/theme/color_palette.dart';
import 'package:kibisis/theme/text_theme.dart';

ElevatedButtonThemeData elevatedButtonTheme({
  required Color backgroundColor,
  required Color foregroundColor,
}) {
  return ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(backgroundColor),
      foregroundColor: MaterialStateProperty.all(foregroundColor),
      textStyle:
          MaterialStateProperty.all(TextStyle(fontSize: baseFontSize * 1.5)),
      padding: MaterialStateProperty.all(const EdgeInsets.all(kButtonPadding)),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kWidgetRadius),
        ),
      ),
    ),
  );
}

ElevatedButtonThemeData elevatedButtonThemeLight() {
  return elevatedButtonTheme(
    backgroundColor: ColorPalette.lightThemeSecondary,
    foregroundColor: Colors.white,
  );
}

ElevatedButtonThemeData elevatedButtonThemeDark() {
  return elevatedButtonTheme(
    backgroundColor: ColorPalette.darkThemeSecondary,
    foregroundColor: Colors.white,
  );
}
