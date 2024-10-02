import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_dropdown.dart';
import 'package:kibisis/common_widgets/pin_pad_dialog.dart';
import 'package:kibisis/common_widgets/transparent_list_tile.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/settings/providers/pin_lock_provider.dart';
import 'package:kibisis/models/select_item.dart';
import 'package:kibisis/providers/lock_timeout_provider.dart';
import 'package:kibisis/providers/storage_provider.dart';
import 'package:kibisis/routing/named_routes.dart';
import 'package:kibisis/utils/app_icons.dart';

class SecurityScreen extends ConsumerStatefulWidget {
  static const String title = 'Security';
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  late bool _enablePinLock;

  @override
  void initState() {
    super.initState();
    // Initialize the local state with the current value from the provider
    _enablePinLock = ref.read(pinLockStateAdapter);
  }

  @override
  Widget build(BuildContext context) {
    // Remove ref.watch(pinLockStateAdapter) since we're managing it locally
    ref.watch(lockTimeoutProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(SecurityScreen.title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
        child: Column(
          children: [
            const SizedBox(height: kScreenPadding),
            buildSettingsToggle(),
            if (_enablePinLock) ...[
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

  Widget buildSettingsToggle() {
    return SwitchListTile(
      title: const Text('Enable Password Lock'),
      value: _enablePinLock,
      onChanged: (newValue) async {
        if (!newValue) {
          // User is trying to disable password lock; prompt for PIN
          final pinVerified = await showDialog<bool>(
            context: context,
            builder: (context) => PinPadDialog(
              title: 'Verify Pin',
              onPinVerified: () {
                // The dialog will be popped within the PinPadDialog
              },
            ),
          );

          if (pinVerified == true && context.mounted) {
            // PIN verified; proceed to disable password lock
            setState(() {
              _enablePinLock = false;
            });
            ref.read(pinLockProvider.notifier).setPasswordLock(false);
            final storage = ref.read(storageProvider);
            storage.setTimeoutEnabled(false);
          } else {
            // PIN verification failed or was canceled; do not change the switch
            // No need to update _enablePinLock since it remains true
          }
        } else {
          // User is enabling password lock; proceed without verification
          setState(() {
            _enablePinLock = true;
          });
          ref.read(pinLockProvider.notifier).setPasswordLock(true);
          final storage = ref.read(storageProvider);
          storage.setTimeoutEnabled(true);
        }
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
          // The dialog will be popped within the PinPadDialog
        },
      ),
    );
    if (pinVerified == true && context.mounted) {
      onPinVerified();
    }
  }
}
