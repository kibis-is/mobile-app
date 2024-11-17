import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRCodeScannerWidget extends StatelessWidget {
  const QRCodeScannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mobile Scanner")),
      body: MobileScanner(
        onDetect: (BarcodeCapture capture) {
          final List<Barcode> barcodes = capture.barcodes;

          // If there's at least one barcode detected, get the first one
          if (barcodes.isNotEmpty) {
            final String? code = barcodes.first.rawValue;
            if (code != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Scanned Code: $code")),
              );
            }
          }
        },
      ),
    );
  }
}
