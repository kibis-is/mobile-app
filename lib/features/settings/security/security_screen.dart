import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_bottom_sheet.dart';
import 'package:kibisis/common_widgets/custom_dropdown.dart';
import 'package:kibisis/common_widgets/pin_pad_dialog.dart';
import 'package:kibisis/common_widgets/transparent_list_tile.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/settings/providers/pin_lock_provider.dart';
import 'package:kibisis/generated/l10n.dart';
import 'package:kibisis/models/select_item.dart';
import 'package:kibisis/providers/authentication_provider.dart';
import 'package:kibisis/providers/lock_timeout_provider.dart';
import 'package:kibisis/providers/storage_provider.dart';
import 'package:kibisis/routing/named_routes.dart';
import 'package:kibisis/utils/app_icons.dart';

class SecurityScreen extends ConsumerStatefulWidget {
  static String title = S.current.security;
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  bool? _enablePinLock;

  @override
  void initState() {
    super.initState();
    _enablePinLock = ref.read(pinLockStateAdapter);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(lockTimeoutProvider);

    return Scaffold(
      appBar: AppBar(title: Text(SecurityScreen.title)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
        child: Column(
          children: [
            const SizedBox(height: kScreenPadding),
            _enablePinLock == null
                ? const CircularProgressIndicator()
                : _buildSettingsToggle(),
            if (_enablePinLock ?? false) ...[
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
      title: Text(S.of(context).enablePasswordLock),
      value: _enablePinLock ?? false,
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
    List<SelectItem> timeoutList = [
      SelectItem(
          name: S.of(context).timeout1Minute, value: "60", icon: AppIcons.time),
      SelectItem(
          name: S.of(context).timeout2Minutes,
          value: "120",
          icon: AppIcons.time),
      SelectItem(
          name: S.of(context).timeout5Minutes,
          value: "300",
          icon: AppIcons.time),
      SelectItem(
          name: S.of(context).timeout10Minutes,
          value: "600",
          icon: AppIcons.time),
      SelectItem(
          name: S.of(context).timeout15Minutes,
          value: "900",
          icon: AppIcons.time),
    ];
    final selectedItem = timeoutList.firstWhere(
      (item) => item.value == timeoutSeconds.toString(),
      orElse: () => timeoutList.first,
    );

    return GestureDetector(
      onTap: () {
        customBottomSheet(
          context: context,
          items: timeoutList,
          header: S.of(context).selectTimeout,
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
          label: S.of(context).timeout,
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
          title: S.of(context).exportAccounts,
          onTap: () => _handlePinVerification(() {
            GoRouter.of(context).pushNamed(exportAccountsRouteName);
          }),
        ),
        const SizedBox(height: kScreenPadding),
        TransparentListTile(
          icon: AppIcons.importAccount,
          title: S.of(context).changePin,
          onTap: () => _handlePinVerification(() {
            GoRouter.of(context).pushNamed(pinPadChangePinRouteName);
          }),
        ),
        TransparentListTile(
          icon: AppIcons.importAccount,
          title: S.of(context).viewSeedPhrase,
          onTap: () => _handlePinVerification(() {
            GoRouter.of(context).pushNamed(viewSeedPhraseRouteName);
          }),
        ),
      ],
    );
  }

  Future<bool> _verifyPin() async {
    final pinVerified = await showDialog<bool>(
      context: context,
      builder: (context) => PinPadDialog(
        title: S.of(context).verifyPin,
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
    ref.read(isAuthenticatedProvider.notifier).state = newValue;
  }

  Future<void> _handlePinVerification(VoidCallback onPinVerified) async {
    final pinVerified = await _verifyPin();
    if (pinVerified && context.mounted) {
      onPinVerified();
    }
  }
}
