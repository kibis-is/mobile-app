import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/common_widgets/custom_dropdown.dart';
import 'package:kibisis/common_widgets/settings_toggle.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/settings/providers/settings_providers.dart';
import 'package:kibisis/providers/lock_timeout_provider.dart';

class SecurityScreen extends ConsumerWidget {
  static const String title = 'Security';
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeoutSeconds = ref.watch(lockTimeoutProvider);
    final enablePasswordLock = ref.watch(enablePasswordLockProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
        child: Column(
          children: [
            const SizedBox(height: kScreenPadding),
            buildSettingsToggle(ref),
            if (enablePasswordLock) ...[
              const SizedBox(height: kScreenPadding),
              buildTimeoutDropdown(ref, timeoutSeconds),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildSettingsToggle(WidgetRef ref) {
    return SettingsToggle(
      title: 'Enable Password Lock',
      provider: enablePasswordLockProvider,
    );
  }

  Widget buildTimeoutDropdown(WidgetRef ref, int timeoutSeconds) {
    return CustomDropDown(
      label: 'Timeout',
      items: timeoutList,
      selectedValue: timeoutList.firstWhere(
        (item) => item.value == timeoutSeconds,
        orElse: () => timeoutList.first,
      ),
      onChanged: (SelectItem? newValue) {
        if (newValue != null) {
          ref.read(lockTimeoutProvider.notifier).setTimeout(newValue.value);
        }
      },
    );
  }
}
