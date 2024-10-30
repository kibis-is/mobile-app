import 'package:flutter/material.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/utils/app_icons.dart';
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
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kWidgetRadius),
            side: BorderSide(color: context.colorScheme.onBackground),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: kScreenPadding, vertical: kScreenPadding / 2)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: context.textTheme.displayMedium),
          AppIcons.icon(icon: iconData),
        ],
      ),
    );
  }
}
