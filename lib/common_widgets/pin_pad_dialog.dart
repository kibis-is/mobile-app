import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/common_widgets/pin_pad.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/utils/app_icons.dart';

class PinPadDialog extends StatelessWidget {
  final String title;
  final VoidCallback onPinVerified;

  const PinPadDialog({
    super.key,
    required this.title,
    required this.onPinVerified,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          leading: IconButton(
            icon: AppIcons.icon(icon: AppIcons.cross, size: AppIcons.small),
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ),
        body: Consumer(
          builder: (context, ref, child) {
            return PinPad(
              mode: PinPadMode.verifyTransaction,
              onPinVerified: () {
                onPinVerified();
                Navigator.of(context).pop(true);
              },
            );
          },
        ),
      ),
    );
  }
}
