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
  );
}

AppBarTheme appBarThemeDark() {
  return appBarTheme(
    backgroundColor: ColorPalette.darkThemeRaisinBlack,
    foregroundColor: ColorPalette.darkThemeAntiflashWhite,
  );
}

AppBarTheme appBarThemeLight() {
  return appBarTheme(
    backgroundColor: ColorPalette.lightThemeAntiFlashWhite,
    foregroundColor: ColorPalette.lightThemeShadow,
  );
}
