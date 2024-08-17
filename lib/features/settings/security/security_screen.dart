import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_dropdown.dart';
import 'package:kibisis/common_widgets/pin_pad_dialog.dart';
import 'package:kibisis/common_widgets/settings_toggle.dart';
import 'package:kibisis/common_widgets/transparent_list_tile.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/settings/providers/pin_lock_provider.dart';
import 'package:kibisis/models/select_item.dart';
import 'package:kibisis/providers/lock_timeout_provider.dart';
import 'package:kibisis/providers/storage_provider.dart';
import 'package:kibisis/routing/named_routes.dart';
import 'package:kibisis/utils/app_icons.dart';

class SecurityScreen extends ConsumerWidget {
  static const String title = 'Security';
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(lockTimeoutProvider);
    final enablePinLock = ref.watch(pinLockStateAdapter);

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
            if (enablePinLock) ...[
              const SizedBox(height: kScreenPadding),
              buildTimeoutDropdown(ref),
            ],
            const SizedBox(height: kScreenPadding),
            buildSecurityOptions(context, ref),
          ],
        ),
      ),
    );
  }

  Widget buildSettingsToggle(WidgetRef ref) {
    return SettingsToggle(
      title: 'Enable Password Lock',
      provider: pinLockStateAdapter,
      onChanged: (newValue) {
        ref.read(pinLockProvider.notifier).setPasswordLock(newValue);
        final storage = ref.read(storageProvider);
        storage.setTimeoutEnabled(ref.read(pinLockStateAdapter));
      },
    );
  }

  Widget buildTimeoutDropdown(WidgetRef ref) {
    final timeoutSeconds = ref.watch(lockTimeoutProvider);
    return CustomDropDown(
      label: 'Timeout',
      items: timeoutList,
      selectedValue: timeoutList.firstWhere(
        (item) => item.value == timeoutSeconds.toString(),
        orElse: () => timeoutList.first,
      ),
      onChanged: (SelectItem? newValue) {
        if (newValue != null) {
          final int timeoutSeconds;
          try {
            timeoutSeconds = int.parse(newValue.value);
          } on Exception {
            return;
          }
          ref.read(lockTimeoutProvider.notifier).setTimeout(timeoutSeconds);
          final storage = ref.read(storageProvider);
          storage.setLockTimeout(ref.read(lockTimeoutProvider));
        }
      },
    );
  }

  Widget buildSecurityOptions(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        TransparentListTile(
          icon: AppIcons.importAccount,
          title: 'Export Accounts',
          onTap: () => _handleChangePin(context, ref, () {
            GoRouter.of(context).pushNamed(exportAccountsRouteName);
          }),
        ),
        const SizedBox(height: kScreenPadding),
        TransparentListTile(
          icon: AppIcons.importAccount,
          title: 'Change Pin',
          onTap: () => _handleChangePin(context, ref, () {
            GoRouter.of(context).pushNamed(pinPadChangePinRouteName);
          }),
        ),
      ],
    );
  }

  Future<void> _handleChangePin(
      BuildContext context, WidgetRef ref, VoidCallback onPinVerified) async {
    final pinVerified = await showDialog<bool>(
      context: context,
      builder: (context) => PinPadDialog(
        title: 'Verify Pin',
        onPinVerified: () {
          //pop is handled by the pinpad
        },
      ),
    );
    if (pinVerified == true && context.mounted) {
      onPinVerified();
    }
  }
}
