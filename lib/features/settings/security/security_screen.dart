import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/common_widgets/custom_bottom_sheet.dart';
import 'package:kibisis/common_widgets/settings_toggle.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/settings/models/timeout.dart';
import 'package:kibisis/features/settings/providers/settings_providers.dart';

class SecurityScreen extends ConsumerWidget {
  static String title = 'Security';
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTimeout = ref.watch(lockTimeoutProvider);
    final enablePasswordLock = ref.watch(enablePasswordLockProvider);
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
              title: 'Enable Password Lock',
              provider: enablePasswordLockProvider,
            ),
            if (enablePasswordLock) ...[
              const SizedBox(
                height: kScreenPadding,
              ),
              TextButton(
                onPressed: () => customBottomSheet(
                  context: context,
                  header: "Select Lockout Time",
                  items: Timeout.timeoutList,
                  onPressed: () {
                    ref.read(lockTimeoutProvider.notifier).state =
                        selectedTimeout;
                  },
                ),
                child: Text(selectedTimeout.name),
              ),
              DropdownButton<Timeout>(
                value: selectedTimeout,
                hint: const Text('Select an option'),
                onChanged: (Timeout? newValue) {
                  if (newValue != null) {
                    ref.read(lockTimeoutProvider.notifier).state = newValue;
                  }
                },
                items: Timeout.timeoutList
                    .map<DropdownMenuItem<Timeout>>((Timeout timeout) {
                  return DropdownMenuItem<Timeout>(
                    value: timeout,
                    child: Text(timeout.name),
                  );
                }).toList(),
              ),
            ]
          ],
        ),
      ),
    );
  }
}