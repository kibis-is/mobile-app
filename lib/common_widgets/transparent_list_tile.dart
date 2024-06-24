import 'package:flutter/material.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class TransparentListTile extends StatelessWidget {
  final IconData icon; // Changed to IconData
  final String title;
  final VoidCallback onTap;

  const TransparentListTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      horizontalTitleGap: kScreenPadding * 2,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 0, vertical: kScreenPadding),
      tileColor: Colors.transparent,
      leading: AppIcons.icon(
        icon: icon,
        size: AppIcons.large,
        color: context.colorScheme.primary,
      ),
      title: Text(
        title,
        style: context.textTheme.displayLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
      trailing: AppIcons.icon(
        icon: AppIcons.arrowRight,
        size: AppIcons.large,
      ),
      onTap: onTap,
    );
  }
}
