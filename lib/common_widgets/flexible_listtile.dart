import 'package:flutter/material.dart';
import 'package:kibisis/constants/constants.dart';

class FlexibleListTile extends StatelessWidget {
  const FlexibleListTile({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.contentPadding = const EdgeInsets.all(kScreenPadding),
  });

  final Widget leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsets contentPadding;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: contentPadding,
        child: Row(
          children: [
            leading,
            const SizedBox(width: kScreenPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  if (subtitle != null) ...[
                    const SizedBox(height: kScreenPadding / 2),
                    subtitle!,
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: kScreenPadding),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
