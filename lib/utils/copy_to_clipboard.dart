// File: lib/utils/clipboard_utils.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void copyToClipboard(BuildContext context, String text) async {
  final scaffold = ScaffoldMessenger.of(context);
  ClipboardData data = ClipboardData(text: text);
  await Clipboard.setData(data);
  scaffold.showSnackBar(
    const SnackBar(content: Text("Copied to clipboard")),
  );
  debugPrint('text: $text');
  debugPrint('data: $data');
}
