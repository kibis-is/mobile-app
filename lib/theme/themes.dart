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

String fontFamily = 'SF Pro Display';

// Light Theme
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  fontFamily: fontFamily,
  brightness: Brightness.light,
  textTheme: textThemeLight(),
  buttonTheme: buttonThemeLight(),
  elevatedButtonTheme: elevatedButtonThemeLight(),
  drawerTheme: const DrawerThemeData(
    backgroundColor: ColorPalette.lightThemeAntiFlashWhite,
  ),
  scaffoldBackgroundColor: ColorPalette.lightThemeAntiFlashWhite,
  cardColor: ColorPalette.lightThemeMagnolia,
  appBarTheme: appBarThemeLight(),
  listTileTheme: listTileTheme(ColorPalette.lightThemeMagnolia),
  colorScheme: const ColorScheme.light(
    brightness: Brightness.light,
    primary: ColorPalette.lightThemeMauveine,
    onPrimary: ColorPalette.lightThemeAntiFlashWhite,
    secondary: ColorPalette.lightThemeMyrtleGreen,
    onSecondary: ColorPalette.lightThemeAntiFlashWhite,
    error: ColorPalette.lightThemeError,
    onError: ColorPalette.lightThemeAntiFlashWhite,
    background: ColorPalette.lightThemeAntiFlashWhite,
    onBackground: ColorPalette.lightThemeChineseViolet,
    surface: ColorPalette.lightThemeMagnolia,
    onSurface: ColorPalette.lightThemeChineseViolet,
    onSurfaceVariant: ColorPalette.lightThemeLicorice,
    shadow: ColorPalette.lightThemeFrenchGray,
  ),
  inputDecorationTheme: inputDecorationTheme(
    ColorPalette.lightThemeFrenchGray,
    ColorPalette.lightThemePurple,
  ),
  pageTransitionsTheme: pageTransitions(),
  disabledColor: ColorPalette.lightThemeFrenchGray,
  bottomAppBarTheme: bottomAppBarTheme(ColorPalette.lightThemeAntiFlashWhite),
  tabBarTheme: const TabBarTheme(
    labelColor: ColorPalette.lightThemeMauveine,
    unselectedLabelColor: ColorPalette.lightThemeChineseViolet,
  ),
  chipTheme: const ChipThemeData(
    backgroundColor: ColorPalette.cardGradientMediumBlue,
    padding: EdgeInsets.zero,
    labelStyle: TextStyle(
      color: ColorPalette.lightThemeAntiFlashWhite,
      fontSize: 12,
    ),
    brightness: Brightness.light,
  ),
);

// Dark Theme
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  fontFamily: fontFamily,
  brightness: Brightness.dark,
  textTheme: textThemeDark(),
  buttonTheme: buttonThemeDark(),
  elevatedButtonTheme: elevatedButtonThemeDark(),
  scaffoldBackgroundColor: ColorPalette.darkThemeRaisinBlack,
  cardColor: ColorPalette.darkThemeGunmetal,
  appBarTheme: appBarThemeDark(),
  listTileTheme: listTileTheme(ColorPalette.darkThemeGunmetal),
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
    onSurfaceVariant: ColorPalette.darkThemeAntiflashWhite,
    shadow: ColorPalette.darkThemeBlack,
  ),
  inputDecorationTheme: inputDecorationTheme(
    ColorPalette.darkThemeGray,
    ColorPalette.darkThemeMauve,
  ),
  pageTransitionsTheme: pageTransitions(),
  disabledColor: ColorPalette.darkThemeGray,
  bottomAppBarTheme: bottomAppBarTheme(ColorPalette.darkThemeRaisinBlack),
  tabBarTheme: const TabBarTheme(
    labelColor: ColorPalette.darkThemeMauve,
    unselectedLabelColor: ColorPalette.darkThemeCadetGray,
  ),
  chipTheme: const ChipThemeData(
    backgroundColor: ColorPalette.cardGradientMediumBlue,
    padding: EdgeInsets.zero,
    labelStyle: TextStyle(
      color: ColorPalette.lightThemeAntiFlashWhite,
      fontSize: 12,
    ),
    brightness: Brightness.dark,
  ),
);
