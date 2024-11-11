import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/common_widgets/settings_toggle.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/settings/appearance/providers/dark_mode_provider.dart';
import 'package:kibisis/generated/l10n.dart';
import 'package:kibisis/providers/storage_provider.dart';

class AppearanceScreen extends ConsumerWidget {
  static String title = S.current.appearance;
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).appearance),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
        child: Column(
          children: [
            const SizedBox(
              height: kScreenPadding,
            ),
            SettingsToggle(
              title: S.of(context).darkMode,
              provider: isDarkModeStateAdapter,
              onChanged: (newValue) {
                final storage = ref.read(storageProvider);
                storage.setIsDarkMode(ref.read(isDarkModeStateAdapter));
              },
            ),
          ],
        ),
      ),
    );
  }
}
