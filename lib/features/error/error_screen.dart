import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/generated/l10n.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class ErrorScreen extends StatelessWidget {
  final String? errorMessage;
  static String title = 'Error';

  const ErrorScreen({super.key, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: kScreenPadding,
            ),
            Text(
              errorMessage ?? S.of(context).defaultErrorMessage,
              style: context.textTheme.bodySmall,
            ),
            const Expanded(
              child: SizedBox(
                height: kScreenPadding,
              ),
            ),
            CustomButton(
              text: S.of(context).back,
              isFullWidth: true,
              onPressed: () {
                GoRouter.of(context).go('/');
              },
            ),
            const SizedBox(
              height: kScreenPadding,
            ),
          ],
        ),
      ),
    );
  }
}
