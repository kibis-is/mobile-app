import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kibisis/common_widgets/custom_snackbar.dart';
import 'package:kibisis/main.dart';

void copyToClipboard(BuildContext context, String text) async {
  ClipboardData data = ClipboardData(text: text);
  await Clipboard.setData(data);
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) return;
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      customSnackbar(
          context: context,
          message: "Copied to clipboard",
          snackType: SnackType.neutral),
    );
  });
  debugPrint('text: $text');
  debugPrint('data: $data');
}
