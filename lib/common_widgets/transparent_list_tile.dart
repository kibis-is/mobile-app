import 'package:flutter/material.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class TransparentListTile extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback onTap;

  const TransparentListTile(
      {super.key,
      required this.icon,
      required this.title,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      horizontalTitleGap: 32,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 0, vertical: kScreenPadding),
      tileColor: Colors.transparent,
      leading: Icon(
        color: context.colorScheme.primary,
        IconData(int.tryParse(icon) ?? 0xe237, fontFamily: 'MaterialIcons'),
      ),
      title: Text(
        title,
        style: context.textTheme.displayLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
      trailing: const Icon(Icons.keyboard_arrow_right_rounded),
      onTap: onTap,
    );
  }
}
