import 'package:flutter/material.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/utils/theme_extensions.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrDialog extends StatelessWidget {
  final String qrData;
  final String? title;

  const QrDialog({
    super.key,
    required this.qrData,
    this.title = 'Scan QR Code',
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      titlePadding: const EdgeInsets.all(kScreenPadding),
      title: SizedBox(
        width: double.infinity,
        child: Text(
          title!,
          textAlign: TextAlign.center,
          style: context.textTheme.titleLarge,
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      content: Container(
        width: double.maxFinite,
        alignment: Alignment.center,
        child: QrImageView(
          backgroundColor: Colors.white,
          data: qrData,
          version: QrVersions.auto,
        ),
      ),
      actions: <Widget>[
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Padding(
              padding: const EdgeInsets.all(kScreenPadding / 2),
              child: Text(
                'Close',
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colorScheme.secondary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
