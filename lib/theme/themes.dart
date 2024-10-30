import 'package:flutter/material.dart';
import 'package:kibisis/theme/appbar_theme.dart';
import 'package:kibisis/theme/bottom_app_bar_theme.dart';
import 'package:kibisis/theme/button_theme.dart';
import 'package:kibisis/theme/color_palette.dart';
import 'package:kibisis/theme/elevated_button_theme.dart';
import 'package:kibisis/theme/input_decoration_theme.dart';
import 'package:kibisis/theme/list_tile_theme.dart';
import 'package:kibisis/theme/page_transitions.dart';
import 'package:kibisis/theme/text_theme.dart';

String fontFamily = 'Nunito';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  fontFamily: fontFamily,
  brightness: Brightness.light,
  textTheme: textThemeLight(),
  buttonTheme: buttonThemeLight(),
  elevatedButtonTheme: elevatedButtonThemeLight(),
  drawerTheme: const DrawerThemeData(
    backgroundColor: ColorPalette.lightThemeBackground,
  ),
  scaffoldBackgroundColor: ColorPalette.lightThemeBackground,
  cardColor: ColorPalette.lightThemeBackground,
  appBarTheme: appBarThemeLight(),
  listTileTheme: listTileTheme(ColorPalette.lightThemeBackground),
  colorScheme: const ColorScheme.light(
    brightness: Brightness.light,
    primary: ColorPalette.lightThemePrimary,
    onPrimary: Colors.white,
    secondary: ColorPalette.lightThemeSecondary,
    onSecondary: Colors.white,
    error: ColorPalette.lightThemeError,
    onError: Colors.white,
    background: ColorPalette.lightThemeBackground,
    onBackground: ColorPalette.lightThemeBody,
    surface: ColorPalette.lightThemeSurface,
    onSurface: ColorPalette.lightThemeHeader,
    onSurfaceVariant: ColorPalette.lightThemeBody,
    shadow: ColorPalette.lightThemeSurface,
  ),
  inputDecorationTheme: inputDecorationTheme(
    ColorPalette.lightThemeBody,
    ColorPalette.lightThemePrimary,
  ),
  pageTransitionsTheme: pageTransitions(),
  disabledColor: ColorPalette.lightThemeDisabled,
  bottomAppBarTheme: bottomAppBarTheme(ColorPalette.lightThemeBackground),
  tabBarTheme: const TabBarTheme(
    labelColor: ColorPalette.lightThemePrimary,
    unselectedLabelColor: ColorPalette.lightThemeBody,
  ),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  fontFamily: fontFamily,
  brightness: Brightness.dark,
  textTheme: textThemeDark(),
  buttonTheme: buttonThemeDark(),
  elevatedButtonTheme: elevatedButtonThemeDark(),
  scaffoldBackgroundColor: ColorPalette.darkThemeBackground,
  cardColor: ColorPalette.darkThemeBackground,
  appBarTheme: appBarThemeDark(),
  listTileTheme: listTileTheme(ColorPalette.darkThemeBackground),
  drawerTheme: const DrawerThemeData(
    backgroundColor: ColorPalette.darkThemeBackground,
  ),
  colorScheme: const ColorScheme.dark(
    brightness: Brightness.dark,
    primary: ColorPalette.darkThemePrimary,
    onPrimary: Colors.white,
    secondary: ColorPalette.darkThemeSecondary,
    onSecondary: Colors.white,
    error: ColorPalette.darkThemeError,
    onError: Colors.white,
    background: ColorPalette.darkThemeBackground,
    onBackground: ColorPalette.darkThemeBody,
    surface: ColorPalette.darkThemeSurface,
    onSurface: ColorPalette.darkThemeHeader,
    onSurfaceVariant: ColorPalette.darkThemeBody,
    shadow: ColorPalette.darkThemeSurface,
  ),
  inputDecorationTheme: inputDecorationTheme(
    ColorPalette.darkThemeBody,
    ColorPalette.darkThemePrimary,
  ),
  pageTransitionsTheme: pageTransitions(),
  disabledColor: ColorPalette.darkThemeDisabled,
  bottomAppBarTheme: bottomAppBarTheme(ColorPalette.darkThemeBackground),
  tabBarTheme: const TabBarTheme(
    labelColor: ColorPalette.darkThemePrimary,
    unselectedLabelColor: ColorPalette.darkThemeBody,
  ),
);
