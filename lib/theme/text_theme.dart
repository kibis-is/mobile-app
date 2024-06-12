import 'package:flutter/material.dart';
import 'package:kibisis/theme/color_palette.dart';

double baseFontSize = 16.0;

TextStyle _textStyle(
    double fontSizeMultiplier, FontWeight fontWeight, Color color) {
  return TextStyle(
    fontSize: baseFontSize * fontSizeMultiplier,
    fontWeight: fontWeight,
    color: color,
  );
}

TextTheme textTheme({
  required Color displayColor,
  required Color bodyColor,
  required Color labelColor,
}) {
  return TextTheme(
    displayLarge: _textStyle(2, FontWeight.w400, displayColor),
    displayMedium: _textStyle(1.5, FontWeight.w400, displayColor),
    displaySmall: _textStyle(1.25, FontWeight.w400, displayColor),
    headlineLarge: _textStyle(4, FontWeight.w400, displayColor),
    headlineMedium: _textStyle(3, FontWeight.w400, displayColor),
    headlineSmall: _textStyle(1.25, FontWeight.w400, displayColor),
    titleLarge: _textStyle(2, FontWeight.w400, displayColor),
    titleMedium: _textStyle(1.5, FontWeight.w400, displayColor),
    titleSmall: _textStyle(1.25, FontWeight.w400, displayColor),
    bodyLarge: _textStyle(1.25, FontWeight.w400, bodyColor),
    bodyMedium: _textStyle(1.125, FontWeight.w400, bodyColor),
    bodySmall: _textStyle(1, FontWeight.w400, bodyColor),
    labelLarge: _textStyle(1, FontWeight.w400, labelColor),
    labelMedium: _textStyle(0.875, FontWeight.w400, labelColor),
    labelSmall: _textStyle(0.75, FontWeight.w400, labelColor),
  );
}

TextTheme textThemeLight() {
  return textTheme(
    displayColor: ColorPalette.lightThemeLicorice,
    bodyColor: ColorPalette.lightThemeChineseViolet,
    labelColor: ColorPalette.lightThemeChineseViolet,
  );
}

TextTheme textThemeDark() {
  return textTheme(
    displayColor: ColorPalette.darkThemeAntiflashWhite,
    bodyColor: ColorPalette.darkThemeCadetGray,
    labelColor: ColorPalette.darkThemeCadetGray,
  );
}
