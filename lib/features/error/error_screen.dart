import 'package:flutter/material.dart';
import 'package:kibisis/constants/constants.dart';
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
          children: [
            const SizedBox(
              height: kScreenPadding,
            ),
            Text(
              errorMessage ??
                  'There was an error. No further details provided.',
              style: context.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
