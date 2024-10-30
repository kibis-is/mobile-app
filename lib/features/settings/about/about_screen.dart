import 'package:flutter/material.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class AboutScreen extends StatelessWidget {
  static String title = 'About';
  const AboutScreen({super.key});

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'App Version:',
                  style: context.textTheme.displayMedium,
                ),
                const SizedBox(
                  width: kScreenPadding,
                ),
                Text(
                  'v$kVersionNumber',
                  style: context.textTheme.displayMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
