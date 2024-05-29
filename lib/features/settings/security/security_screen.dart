import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/common_widgets/settings_toggle.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/settings/models/timeout.dart';
import 'package:kibisis/features/settings/providers/settings_providers.dart';
import 'package:kibisis/providers/lock_timeout_provider.dart';

class SecurityScreen extends ConsumerWidget {
  static const String title = 'Security';
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeoutSeconds =
        ref.watch(lockTimeoutProvider); // Get the current timeout in seconds
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
            SettingsToggle(
                title: 'Enable Password Lock',
                provider: enablePasswordLockProvider),
            if (enablePasswordLock) ...[
              const SizedBox(height: kScreenPadding),
              DropdownButton<Timeout>(
                value: Timeout.timeoutList.firstWhere(
                    (item) => item.time == timeoutSeconds,
                    orElse: () => Timeout.timeoutList.first),
                onChanged: (Timeout? newValue) {
                  if (newValue != null) {
                    ref
                        .read(lockTimeoutProvider.notifier)
                        .setTimeout(newValue.time);
                  }
                },
                items: Timeout.timeoutList.map((Timeout timeout) {
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
