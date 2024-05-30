import 'package:flutter/material.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class CustomTextButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final String? value;
  final IconData? iconData;

  const CustomTextButton({
    super.key,
    required this.title,
    this.onPressed,
    this.iconData,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.transparent, // Transparent background
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kWidgetRadius),
          side: BorderSide(
              color: context.colorScheme.onBackground), // Colored border
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: kScreenPadding,
            vertical: kScreenPadding / 2), // Padding inside the button
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: context.textTheme.displayMedium),
          Icon(iconData, size: 24),
        ],
      ),
    );
  }
}
