import 'package:flutter/material.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class CustomFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;

  const CustomFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72 - kWidgetRadius,
      child: FloatingActionButton(
        heroTag: null,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(kWidgetRadius),
            topLeft: Radius.circular(kWidgetRadius),
            bottomRight: Radius.circular(0),
            bottomLeft: Radius.circular(0),
          ),
        ),
        backgroundColor: context.colorScheme.secondary,
        foregroundColor: context.colorScheme.onSecondary,
        elevation: 0,
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(kScreenPadding / 2),
          child: AppIcons.icon(
              icon: icon,
              size: AppIcons.large,
              color: context.colorScheme.onSecondary),
        ),
      ),
    );
  }
}
