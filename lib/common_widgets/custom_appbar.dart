// custom_app_bar.dart
import 'package:flutter/material.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class SplitAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget leadingWidget;
  final Widget actionWidget;
  @override
  final Size preferredSize;

  const SplitAppBar({
    super.key,
    required this.leadingWidget,
    required this.actionWidget,
  }) : preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        color: context.colorScheme.background,
        alignment: Alignment.center,

        padding: const EdgeInsets.only(left: kScreenPadding, right: 0, top: kScreenPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: leadingWidget,
            ),
            const SizedBox(
                width: kScreenPadding),
            actionWidget,
          ],
        ),
      ),
    );
  }
}
