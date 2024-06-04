// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/common_widgets/pin_pad.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/pin_entry_provider.dart';

class PinPadScreen extends ConsumerWidget {
  final PinPadMode mode;

  const PinPadScreen({super.key, required this.mode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(pinEntryStateNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(mode == PinPadMode.setup ? 'Setup PIN' : 'Unlock'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          const SizedBox(height: kScreenPadding),
          Expanded(child: PinPad(mode: mode)),
          const SizedBox(height: kScreenPadding),
        ],
      ),
    );
  }
}
