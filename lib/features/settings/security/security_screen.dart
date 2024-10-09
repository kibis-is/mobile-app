import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_bottom_sheet.dart';
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
    _enablePinLock = ref.read(pinLockStateAdapter);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(lockTimeoutProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(SecurityScreen.title)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
        child: Column(
          children: [
            const SizedBox(height: kScreenPadding),
            _buildSettingsToggle(),
            if (_enablePinLock) ...[
              const SizedBox(height: kScreenPadding),
              _buildTimeoutDropdown(),
            ],
            const SizedBox(height: kScreenPadding),
            _buildSecurityOptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsToggle() {
    return SwitchListTile(
      title: const Text('Enable Password Lock'),
      value: _enablePinLock,
      onChanged: (newValue) async {
        if (!newValue) {
          final pinVerified = await _verifyPin();
          if (pinVerified) {
            _updatePinLockState(false);
          }
        } else {
          _updatePinLockState(true);
        }
      },
    );
  }

  Widget _buildTimeoutDropdown() {
    final timeoutSeconds = ref.watch(lockTimeoutProvider);

    // Find the currently selected timeout item
    final selectedItem = timeoutList.firstWhere(
      (item) => item.value == timeoutSeconds.toString(),
      orElse: () => timeoutList.first,
    );

    return GestureDetector(
      onTap: () {
        customBottomSheet(
          context: context,
          items: timeoutList,
          header: 'Select Timeout',
          onPressed: (SelectItem selectedItem) {
            final int timeoutSeconds = int.parse(selectedItem.value);
            ref.read(lockTimeoutProvider.notifier).setTimeout(timeoutSeconds);
            ref.read(storageProvider).setLockTimeout(timeoutSeconds);
          },
        );
      },
      child: AbsorbPointer(
        absorbing: true,
        child: CustomDropDown(
          label: 'Timeout',
          items: timeoutList,
          selectedValue: selectedItem,
          onChanged: null,
        ),
      ),
    );
  }

  Widget _buildSecurityOptions() {
    return Column(
      children: [
        TransparentListTile(
          icon: AppIcons.importAccount,
          title: 'Export Accounts',
          onTap: () => _handlePinVerification(() {
            GoRouter.of(context).pushNamed(exportAccountsRouteName);
          }),
        ),
        const SizedBox(height: kScreenPadding),
        TransparentListTile(
          icon: AppIcons.importAccount,
          title: 'Change Pin',
          onTap: () => _handlePinVerification(() {
            GoRouter.of(context).pushNamed(pinPadChangePinRouteName);
          }),
        ),
      ],
    );
  }

  Future<bool> _verifyPin() async {
    final pinVerified = await showDialog<bool>(
      context: context,
      builder: (context) => PinPadDialog(
        title: 'Verify Pin',
        onPinVerified: () {},
      ),
    );
    return pinVerified == true;
  }

  void _updatePinLockState(bool newValue) {
    setState(() {
      _enablePinLock = newValue;
    });
    ref.read(pinLockProvider.notifier).setPasswordLock(newValue);
    ref.read(storageProvider).setTimeoutEnabled(newValue);
  }

  Future<void> _handlePinVerification(VoidCallback onPinVerified) async {
    final pinVerified = await _verifyPin();
    if (pinVerified && context.mounted) {
      onPinVerified();
    }
  }
}
