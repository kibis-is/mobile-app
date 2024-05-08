// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/common_widgets/confirmation_dialog.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/common_widgets/pin_pad.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/pin_entry_provider.dart';
import 'package:kibisis/providers/wallet_manager_provider.dart';

class PinPadScreen extends ConsumerWidget {
  final PinPadMode mode;

  const PinPadScreen({super.key, required this.mode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinState = ref.watch(pinEntryStateNotifierProvider);
    ref.watch(walletManagerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(mode == PinPadMode.setup ? 'Setup PIN' : 'Unlock'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          const SizedBox(height: kScreenPadding),
          CustomButton(
            text: 'Reset',
            isWarning: true,
            isFullWidth: true,
            onPressed: () async {
              bool confirm = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const ConfirmationDialog(
                    yesText: 'Reset',
                    noText: 'Cancel',
                    content:
                        'Are you sure you want to reset this device? This will remove all accounts, settings, and security information.',
                  );
                },
              );

              confirm
                  ? ref.read(walletManagerProvider.notifier).resetWallet()
                  : null;
            },
          ),
          Padding(
            padding: const EdgeInsets.all(kScreenPadding),
            child: Visibility(
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              visible: pinState.error.isNotEmpty,
              child: Text(
                pinState.error,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
          Expanded(
            child: PinPad(mode: mode),
          ),
          const SizedBox(height: kScreenPadding),
        ],
      ),
    );
  }
}
