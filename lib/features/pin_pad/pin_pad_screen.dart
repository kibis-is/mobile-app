// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/common_widgets/pin_pad.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/pin_entry_provider.dart';

class PinPadScreen extends ConsumerWidget {
  const PinPadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinState = ref.watch(pinEntryStateNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter PIN'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          const SizedBox(height: kScreenPadding),
          if (pinState.error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(pinState.error,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          Expanded(
            child: PinPad(
              pinLength: 6,
              onComplete: (pin) {
                print("PIN Completed: $pin");
                // Add additional actions here, like verifying the PIN or navigating to another screen
              },
            ),
          ),
          const SizedBox(height: kScreenPadding),
        ],
      ),
    );
  }
}
