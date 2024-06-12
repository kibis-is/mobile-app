import 'package:flutter/material.dart';
import 'package:kibisis/constants/constants.dart';

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
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(kWidgetRadius),
            topLeft: Radius.circular(kWidgetRadius),
            bottomRight: Radius.circular(0),
            bottomLeft: Radius.circular(0),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
        elevation: 0,
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(kScreenPadding / 2),
          child: Icon(
            icon,
            size: kScreenPadding * 2,
          ),
        ),
      ),
    );
  }
}