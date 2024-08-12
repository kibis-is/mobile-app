import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/common_widgets/pin_pad.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/pin_pad/providers/pin_title_provider.dart';

class PinPadScreen extends ConsumerWidget {
  final PinPadMode mode;

  const PinPadScreen({super.key, required this.mode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = mode == PinPadMode.setup
        ? ref.watch(pinTitleProvider)
        : (mode == PinPadMode.unlock ? "Unlock" : "Verify Pin");

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
