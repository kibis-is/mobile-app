import 'package:flutter/material.dart';
import 'package:kibisis/constants/constants.dart';

class CustomFabChild extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color iconColor;
  final double size;
  final double borderRadius;

  const CustomFabChild({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.backgroundColor,
    required this.iconColor,
    this.size = kScreenPadding * 3,
    this.borderRadius = kWidgetRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: IconButton(
        icon: Icon(icon),
        color: iconColor,
        onPressed: onPressed,
      ),
    );
  }
}
