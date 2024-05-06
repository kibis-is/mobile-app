import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/common_widgets/settings_toggle.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/settings/providers/settings_providers.dart';

class AppearanceScreen extends ConsumerWidget {
  static String title = 'Appearance';
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            SettingsToggle(
              title: 'Dark Mode',
              provider: isDarkModeProvider,
            ),
          ],
        ),
      ),
    );
  }
}
