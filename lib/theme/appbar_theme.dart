import 'package:flutter/material.dart';
import 'package:kibisis/theme/color_palette.dart';

AppBarTheme appBarTheme({
  required Color backgroundColor,
  required Color foregroundColor,
}) {
  return AppBarTheme(
    elevation: 0.0,
    shadowColor: Colors.transparent,
    backgroundColor: backgroundColor,
    centerTitle: true,
    foregroundColor: foregroundColor,
    titleTextStyle: const TextStyle(
      fontWeight: FontWeight.bold,
    )
  );
}

AppBarTheme appBarThemeDark() {
  return appBarTheme(
    backgroundColor: ColorPalette.darkThemeBackground,
    foregroundColor: ColorPalette.darkThemeHeader,
  );
}

AppBarTheme appBarThemeLight() {
  return appBarTheme(
    backgroundColor: ColorPalette.lightThemeBackground,
    foregroundColor: ColorPalette.lightThemeHeader,
  );
}
