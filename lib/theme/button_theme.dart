import 'package:flutter/material.dart';
import 'package:kibisis/theme/color_palette.dart';

ButtonThemeData buttonTheme({
  required Color buttonColor,
  required Color hoverColor,
  required Color splashColor,
}) {
  return ButtonThemeData(
    buttonColor: buttonColor,
    hoverColor: hoverColor,
    splashColor: splashColor,
    textTheme: ButtonTextTheme.primary,
  );
}

ButtonThemeData buttonThemeLight() {
  return buttonTheme(
    buttonColor: ColorPalette.lightThemePrimary,
    hoverColor: ColorPalette.lightThemePrimary,
    splashColor: ColorPalette.lightThemePrimary,
  );
}

ButtonThemeData buttonThemeDark() {
  return buttonTheme(
    buttonColor: ColorPalette.darkThemePrimary,
    hoverColor: ColorPalette.darkThemePrimary,
    splashColor: ColorPalette.darkThemePrimary,
  );
}
