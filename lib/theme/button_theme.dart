import 'package:flutter/material.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/theme/color_palette.dart';

ButtonThemeData buttonThemeLight() {
  return const ButtonThemeData(
    buttonColor: ColorPalette.lightThemeMauveine,
    hoverColor: ColorPalette.lightThemePurple,
    splashColor: ColorPalette.lightThemePurple,
    textTheme: ButtonTextTheme.primary,
  );
}

ButtonThemeData buttonThemeDark() {
  return const ButtonThemeData(
    buttonColor: ColorPalette.darkThemeMauve,
    hoverColor: ColorPalette.darkThemeHeliotrope,
    splashColor: ColorPalette.darkThemeHeliotrope,
    textTheme: ButtonTextTheme.primary,
  );
}

ElevatedButtonThemeData elevatedButtonThemeLight() {
  return ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor:
          MaterialStateProperty.all(ColorPalette.lightThemeMauveine),
      foregroundColor: MaterialStateProperty.all(ColorPalette.lightThemeWhite),
      textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 24)),
      padding: MaterialStateProperty.all(const EdgeInsets.all(kButtonPadding)),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kButtonRadius),
        ),
      ),
    ),
  );
}

ElevatedButtonThemeData elevatedButtonThemeDark() {
  return ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(ColorPalette.darkThemeMauve),
      foregroundColor:
          MaterialStateProperty.all(ColorPalette.darkThemeAntiflashWhite),
      textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 24)),
      padding: MaterialStateProperty.all(const EdgeInsets.all(kButtonPadding)),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kButtonRadius),
        ),
      ),
    ),
  );
}
