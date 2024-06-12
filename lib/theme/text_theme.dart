import 'package:flutter/material.dart';
import 'package:kibisis/theme/color_palette.dart';

// This is the base font size in px that is equivalent to 1 rem
double baseFontSize = 16.0;

TextTheme textThemeLight() {
  return const TextTheme(
    displayLarge: TextStyle(
        fontSize: 32.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.lightThemeLicorice),
    displayMedium: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.lightThemeLicorice),
    displaySmall: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.lightThemeLicorice),
    headlineLarge: TextStyle(
        fontSize: 96.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.lightThemeLicorice),
    headlineMedium: TextStyle(
        fontSize: 48.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.lightThemeLicorice),
    headlineSmall: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.lightThemeLicorice),
    titleLarge: TextStyle(
        fontSize: 32.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.lightThemeLicorice),
    titleMedium: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.lightThemeLicorice),
    titleSmall: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.lightThemeLicorice),
    bodyLarge: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.lightThemeChineseViolet),
    bodyMedium: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.lightThemeChineseViolet),
    bodySmall: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.lightThemeChineseViolet),
    labelLarge: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.lightThemeChineseViolet),
    labelMedium: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.lightThemeChineseViolet),
    labelSmall: TextStyle(
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.lightThemeChineseViolet),
  );
}

TextTheme textThemeDark() {
  return const TextTheme(
    displayLarge: TextStyle(
        fontSize: 32.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.darkThemeAntiflashWhite),
    displayMedium: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.darkThemeAntiflashWhite),
    displaySmall: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.darkThemeAntiflashWhite),
    headlineLarge: TextStyle(
        fontSize: 64.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.darkThemeAntiflashWhite),
    headlineMedium: TextStyle(
        fontSize: 48.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.darkThemeAntiflashWhite),
    headlineSmall: TextStyle(
        fontSize: 32.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.darkThemeAntiflashWhite),
    titleLarge: TextStyle(
        fontSize: 32.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.darkThemeAntiflashWhite),
    titleMedium: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.darkThemeAntiflashWhite),
    titleSmall: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.darkThemeAntiflashWhite),
    bodyLarge: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.darkThemeCadetGray),
    bodyMedium: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.darkThemeCadetGray),
    bodySmall: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.darkThemeCadetGray),
    labelLarge: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.darkThemeCadetGray),
    labelMedium: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.darkThemeCadetGray),
    labelSmall: TextStyle(
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.darkThemeCadetGray),
  );
}
