import 'package:flutter/material.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/utils/theme_extensions.dart';

enum ButtonType { primary, secondary, warning, disabled }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Icon? prefixIcon;
  final bool isFullWidth;
  final bool isOutline;
  final ButtonType buttonType;
  final bool isBottomNavigationPosition;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.prefixIcon,
    this.isFullWidth = false,
    this.isOutline = false,
    this.buttonType = ButtonType.secondary,
    this.isBottomNavigationPosition = false,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color foregroundColor;

    switch (buttonType) {
      case ButtonType.primary:
        backgroundColor = context.colorScheme.primary;
        foregroundColor = context.colorScheme.onPrimary;
        break;
      case ButtonType.secondary:
        backgroundColor = context.colorScheme.secondary;
        foregroundColor = context.colorScheme.onSecondary;
        break;
      case ButtonType.warning:
        backgroundColor = context.colorScheme.error;
        foregroundColor = context.colorScheme.onError;
        break;
      case ButtonType.disabled:
        backgroundColor = Theme.of(context).disabledColor;
        foregroundColor = context.colorScheme.onSecondary;
        break;
    }

    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: isBottomNavigationPosition
          ? const EdgeInsets.only(
              top: 0,
              bottom: kScreenPadding,
              left: kScreenPadding,
              right: kScreenPadding)
          : const EdgeInsets.all(0),
      child: ElevatedButton.icon(
        icon: prefixIcon ?? const SizedBox.shrink(),
        label: Text(
          text,
          style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isOutline ? backgroundColor : foregroundColor),
        ),
        onPressed: onPressed,
        style: ButtonStyle(
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100.0),
          )),
          backgroundColor: isOutline
              ? MaterialStateProperty.all(Colors.transparent)
              : MaterialStateProperty.all(backgroundColor),
          foregroundColor: isOutline
              ? MaterialStateProperty.all(backgroundColor)
              : MaterialStateProperty.all(foregroundColor),
          side: isOutline
              ? MaterialStateProperty.all(BorderSide(
                  color: backgroundColor,
                  width: 2.0,
                  style: BorderStyle.solid,
                ))
              : null,
        ),
      ),
    );
  }
}
