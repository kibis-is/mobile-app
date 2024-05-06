import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/common_widgets/confirmation_dialog.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/wallet_manager_provider.dart';

class GeneralScreen extends ConsumerWidget {
  static String title = 'General';
  const GeneralScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: kScreenPadding,
            ),
            Text(
              'Danger Zone',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: kScreenPadding / 2,
            ),
            Text(
              'This will remove all accounts, settings, and security information.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(
              height: kScreenPadding,
            ),
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
            )
          ],
        ),
      ),
    );
  }
}
