import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/theme/color_palette.dart';
import 'package:kibisis/utils/theme_extensions.dart';

BoxDecoration frozenBoxDecoration(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  var brightness = Theme.of(context).brightness;
  bool isDarkMode = brightness == Brightness.dark;

  Color frozenColor =
      isDarkMode ? ColorPalette.darkThemeFrozenColor : Colors.white;
  return BoxDecoration(
    color: context.colorScheme.background,
    gradient: RadialGradient(
      radius: (1 / 375) * screenWidth,
      colors: isDarkMode
          ? [
              context.colorScheme.background,
              ColorPalette.darkThemeFrozenSurfaceColor,
            ]
          : [
              context.colorScheme.surface,
              frozenColor,
            ],
    ),
    borderRadius: BorderRadius.circular(kWidgetRadius),
    border: GradientBoxBorder(
      gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: isDarkMode
              ? [
                  Colors.transparent,
                  Colors.white.withOpacity(0.5),
                ]
              : [
                  Colors.white.withOpacity(1),
                  Colors.white.withOpacity(1),
                ]),
      width: 2,
    ),
  );
}
