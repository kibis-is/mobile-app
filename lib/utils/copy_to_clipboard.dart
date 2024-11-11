import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kibisis/common_widgets/top_snack_bar.dart';
import 'package:kibisis/generated/l10n.dart';

void copyToClipboard(BuildContext context, String text) async {
  ClipboardData data = ClipboardData(text: text);
  await Clipboard.setData(data);
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) return;
    showCustomSnackBar(
      context: context,
      snackType: SnackType.neutral,
      message: S.current.copiedToClipboard,
    );
  });
}
