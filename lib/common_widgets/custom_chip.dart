import 'package:flutter/material.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/theme/color_palette.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class CustomChip extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color labelColor;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final Color borderColor;
  final double borderWidth;

  const CustomChip({
    super.key,
    required this.label,
    this.backgroundColor = ColorPalette.cardGradientMediumBlue,
    this.labelColor = ColorPalette.darkThemeAntiflashWhite,
    this.padding = const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2),
    this.borderRadius = const BorderRadius.all(Radius.circular(kWidgetRadius)),
    this.borderColor = ColorPalette.darkThemeAntiflashWhite,
    this.borderWidth = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      padding: padding,
      child: Text(
        label,
        style: context.textTheme.labelSmall
            ?.copyWith(color: labelColor, fontWeight: FontWeight.bold),
      ),
    );
  }
}
