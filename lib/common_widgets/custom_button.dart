import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Icon? prefixIcon;
  final bool isFullWidth;
  final bool isSecondary;
  final bool isWarning;

  const CustomButton(
      {super.key,
      required this.text,
      required this.onPressed,
      this.prefixIcon,
      this.isFullWidth = false,
      this.isSecondary = false,
      this.isWarning = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton.icon(
        icon: prefixIcon ?? Container(),
        label: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: onPressed == null
              ? MaterialStateProperty.all(Theme.of(context).disabledColor)
              : isWarning
                  ? MaterialStateProperty.all(theme.colorScheme.error)
                  : isSecondary
                      ? MaterialStateProperty.all(Colors.transparent)
                      : MaterialStateProperty.all(theme.colorScheme.secondary),
          foregroundColor: isWarning
              ? MaterialStateProperty.all(theme.colorScheme.onSecondary)
              : isSecondary
                  ? MaterialStateProperty.all(theme.colorScheme.secondary)
                  : MaterialStateProperty.all(theme.colorScheme.onSecondary),
          side: isSecondary
              ? MaterialStateProperty.all(BorderSide(
                  color: Theme.of(context).colorScheme.secondary,
                  width: 2.0,
                  style: BorderStyle.solid,
                ))
              : null,
        ),
      ),
    );
  }
}
