import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  final Icon? prefixIcon;
  final bool isFullWidth;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.prefixIcon,
    this.isFullWidth = false,
  });

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
        onPressed: onPressed as void Function()?,
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(theme.colorScheme.secondary),
          foregroundColor:
              MaterialStateProperty.all(theme.colorScheme.onSecondary),
        ),
      ),
    );
  }
}
