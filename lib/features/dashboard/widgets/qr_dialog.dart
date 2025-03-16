import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/generated/l10n.dart';
import 'package:kibisis/utils/theme_extensions.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:kibisis/utils/copy_to_clipboard.dart';
import 'package:kibisis/utils/save_qr_image.dart';

class QrDialog extends StatelessWidget {
  final String qrData;
  final String? title;

  const QrDialog({
    super.key,
    required this.qrData,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final GlobalKey qrKey = GlobalKey();
    final dialogTitle = title ?? S.of(context).scanQrCode;

    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      titlePadding: const EdgeInsets.all(kScreenPadding),
      title: SizedBox(
        width: double.infinity,
        child: Text(
          dialogTitle,
          textAlign: TextAlign.center,
          style: context.textTheme.titleMedium,
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      content: Container(
        width: double.maxFinite,
        alignment: Alignment.center,
        child: RepaintBoundary(
          key: qrKey,
          child: QrImageView(
            backgroundColor: Colors.white,
            data: qrData,
            version: QrVersions.auto,
          ),
        ),
      ),
      actions: <Widget>[
        buildActionRow(context, qrKey),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Padding(
              padding: const EdgeInsets.all(kScreenPadding / 2),
              child: Text(
                S.of(context).close,
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

  Widget buildActionRow(BuildContext context, GlobalKey qrKey) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () => QRCodeUtils.shareQrImage(qrKey),
          tooltip: S.of(context).shareQr,
        ),
        const SizedBox(width: kScreenPadding),
        IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () => copyToClipboard(context, qrData),
          tooltip: S.of(context).copyUri,
        ),
        if (Platform.isAndroid || Platform.isIOS)
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => QRCodeUtils.saveQrImage(qrKey),
            tooltip: S.of(context).downloadQrImage,
          ),
      ],
    );
  }
}
