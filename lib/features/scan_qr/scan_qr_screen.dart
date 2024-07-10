import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/utils/barcode_scanner.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class QrCodeScannerScreen extends ConsumerStatefulWidget {
  static String title = 'Scan QR';
  final AccountFlow? accountFlow;
  final ScanMode scanMode;

  const QrCodeScannerScreen({
    super.key,
    this.accountFlow,
    required this.scanMode,
  });

  @override
  QrCodeScannerScreenState createState() => QrCodeScannerScreenState();
}

class QrCodeScannerScreenState extends ConsumerState<QrCodeScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  MobileScannerController controller = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
  );

  @override
  void reassemble() {
    super.reassemble();
    if (defaultTargetPlatform == TargetPlatform.android) {
      controller.stop();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      controller.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return Scaffold(
        appBar: AppBar(
          title: Text(QrCodeScannerScreen.title),
        ),
        body: Center(
          child: Text(
            'QR Code scanning is not supported on this platform.',
            style: context.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(QrCodeScannerScreen.title),
      ),
      body: Stack(
        children: [
          MobileScanner(
            key: qrKey,
            controller: controller,
            onDetect: (capture) {
              var scannerLogic = QRCodeScannerLogic(
                context: context,
                ref: ref,
                scanMode: widget.scanMode,
                controller: controller,
                accountFlow: widget.accountFlow,
              );
              scannerLogic.handleBarcode(capture);
            },
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border:
                    Border.all(color: context.colorScheme.primary, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Center(
              child: (result != null)
                  ? Text(
                      'Barcode Type: ${result!.format} Data: ${result!.rawValue}',
                      style: const TextStyle(color: Colors.white),
                    )
                  : const Text(
                      'Scan a QR code',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
