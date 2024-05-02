import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/theme/providers/theme_provider.dart';

class AppearanceScreen extends ConsumerWidget {
  static String title = 'Appearance';
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
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
            Switch(
              value: ref.watch(themeProvider) == ThemeMode.dark,
              onChanged: (newValue) {
                ref.read(themeProvider.notifier).update(
                    (state) => newValue ? ThemeMode.dark : ThemeMode.light);
              },
            ),
          ],
        ),
      ),
    );
  }
}
