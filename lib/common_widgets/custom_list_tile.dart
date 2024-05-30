import 'package:flutter/material.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class CustomListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData leadingIcon;
  final IconData trailingIcon;
  final void Function() onTap;

  const CustomListTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.leadingIcon,
    required this.trailingIcon,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(
          kScreenPadding, kScreenPadding / 2, 0, kScreenPadding / 2),
      leading: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.colorScheme.primary,
        ),
        child: Padding(
          padding: const EdgeInsets.all(kScreenPadding / 2),
          child: Icon(leadingIcon,
              color: context.colorScheme.onPrimary, size: kScreenPadding * 1.5),
        ),
      ),
      title: Text(
        title,
        overflow: TextOverflow.ellipsis,
        style: context.textTheme.titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitle,
        style: context.textTheme.bodySmall,
      ),
      trailing: Padding(
        padding: const EdgeInsets.all(kScreenPadding),
        child: Icon(
          trailingIcon,
          color: context.colorScheme.onBackground,
        ),
      ),
      onTap: onTap,
    );
  }
}
