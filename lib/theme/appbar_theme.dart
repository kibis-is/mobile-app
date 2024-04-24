import 'package:flutter/material.dart';
import 'package:kibisis/theme/color_palette.dart';

AppBarTheme appBarThemeDark() {
  return const AppBarTheme(
    elevation: 0.0,
    shadowColor: Colors.transparent,
    backgroundColor: ColorPalette.darkThemeRaisinBlack,
    centerTitle: true,
    foregroundColor: ColorPalette.darkThemeAntiflashWhite,
  );
}

AppBarTheme appBarThemeLight() {
  return const AppBarTheme(
    elevation: 0.0,
    shadowColor: Colors.transparent,
    backgroundColor: ColorPalette.lightThemeWhite,
    centerTitle: true,
    foregroundColor: ColorPalette.lightThemeShadow,
  );
}
