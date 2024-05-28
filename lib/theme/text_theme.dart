import 'package:flutter/material.dart';
import 'package:kibisis/theme/color_palette.dart';

// This is the base font size in px that is equivalent to 1 rem
double baseFontSize = 16.0;

TextTheme textThemeLight() {
  return const TextTheme(
    displayLarge: TextStyle(
        fontSize: 32.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.lightThemePaynesGray),
    displayMedium: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.lightThemePaynesGray),
    displaySmall: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.lightThemePaynesGray),
    headlineLarge: TextStyle(
        fontSize: 96.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.lightThemePaynesGray),
    headlineMedium: TextStyle(
        fontSize: 48.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.lightThemePaynesGray),
    headlineSmall: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.lightThemePaynesGray),
    titleLarge: TextStyle(
        fontSize: 32.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.lightThemePaynesGray),
    titleMedium: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.lightThemePaynesGray),
    titleSmall: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.lightThemePaynesGray),
    bodyLarge: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.lightThemeCadetGray),
    bodyMedium: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.lightThemeCadetGray),
    bodySmall: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.lightThemeCadetGray),
    labelLarge: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.lightThemeCadetGray),
    labelMedium: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.lightThemeCadetGray),
    labelSmall: TextStyle(
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        color: ColorPalette.lightThemeCadetGray),
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
