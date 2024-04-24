import 'package:flutter/material.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/theme/appbar_theme.dart';
import 'package:kibisis/theme/button_theme.dart';
import 'package:kibisis/theme/color_palette.dart';
import 'package:kibisis/theme/page_transitions.dart';
import 'package:kibisis/theme/text_theme.dart';

String fontFamily = 'Anonymous Pro';

// Light Theme
final ThemeData lightTheme = ThemeData(
  fontFamily: fontFamily,
  brightness: Brightness.light,
  textTheme: textThemeLight(),
  buttonTheme: buttonThemeLight(),
  elevatedButtonTheme: elevatedButtonThemeLight(),
  drawerTheme: const DrawerThemeData(
    backgroundColor: ColorPalette.lightThemeWhite,
  ),
  scaffoldBackgroundColor: ColorPalette.lightThemeWhite,
  cardColor: ColorPalette.lightThemeWhiteSmoke,
  appBarTheme: appBarThemeLight(),
  listTileTheme: ListTileThemeData(
    tileColor: ColorPalette.lightThemeWhiteSmoke,
    contentPadding: const EdgeInsets.all(kSizedBoxSpacing),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(kButtonRadius), // Corner radius
    ),
  ),
  colorScheme: const ColorScheme.light(
    brightness: Brightness.light,
    primary: ColorPalette.lightThemeMauveine,
    onPrimary: ColorPalette.lightThemeWhite,
    secondary: ColorPalette.lightThemeTeal,
    onSecondary: ColorPalette.lightThemeWhite,
    error: ColorPalette.lightThemeError,
    onError: ColorPalette.lightThemeWhite,
    background: ColorPalette.lightThemeWhite,
    onBackground: ColorPalette.lightThemeCadetGray,
    surface: ColorPalette.lightThemeWhiteSmoke,
    onSurface: ColorPalette.lightThemeCadetGray,
    shadow: ColorPalette.lightThemeFrenchGray,
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kButtonRadius),
      borderSide: const BorderSide(color: ColorPalette.lightThemeFrenchGray),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kButtonRadius),
      borderSide: const BorderSide(color: ColorPalette.lightThemeCadetGray),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kButtonRadius),
      borderSide: const BorderSide(color: ColorPalette.lightThemePurple),
    ),
  ),
  pageTransitionsTheme: pageTransitions(),
);

// Dark Theme
final ThemeData darkTheme = ThemeData(
  fontFamily: fontFamily,
  brightness: Brightness.dark,
  textTheme: textThemeDark(),
  buttonTheme: buttonThemeDark(),
  elevatedButtonTheme: elevatedButtonThemeDark(),
  scaffoldBackgroundColor: ColorPalette.darkThemeRaisinBlack,
  cardColor: ColorPalette.darkThemeGunmetal,
  appBarTheme: appBarThemeDark(),
  listTileTheme: ListTileThemeData(
    tileColor: ColorPalette.darkThemeGunmetal,
    contentPadding: const EdgeInsets.all(kSizedBoxSpacing),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(kButtonRadius),
    ),
  ),
  drawerTheme: const DrawerThemeData(
    backgroundColor: ColorPalette.darkThemeRaisinBlack,
  ),
  colorScheme: const ColorScheme.dark(
    brightness: Brightness.dark,
    primary: ColorPalette.darkThemeMauve,
    onPrimary: ColorPalette.darkThemeRaisinBlack,
    secondary: ColorPalette.darkThemeKeppel,
    onSecondary: ColorPalette.darkThemeAntiflashWhite,
    error: ColorPalette.darkThemeError,
    onError: ColorPalette.darkThemeAntiflashWhite,
    background: ColorPalette.darkThemeRaisinBlack,
    onBackground: ColorPalette.darkThemeCadetGray,
    surface: ColorPalette.darkThemeGunmetal,
    onSurface: ColorPalette.darkThemeCadetGray,
    shadow: ColorPalette.darkThemeBlack,
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kButtonRadius),
      borderSide: const BorderSide(color: ColorPalette.darkThemeGray),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kButtonRadius),
      borderSide: const BorderSide(color: ColorPalette.darkThemeMauve),
    ),
  ),
  pageTransitionsTheme: pageTransitions(),
);
