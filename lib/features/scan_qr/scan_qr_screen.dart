import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/multipart_scan_provider.dart';
import 'package:kibisis/utils/barcode_scanner.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class QrCodeScannerScreen extends ConsumerStatefulWidget {
  static const String title = 'Scan QR';
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

  Timer? _debounceTimer;
  bool isProcessing = false;

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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildScannerView(),
          _buildScanTargetIndicator(),
          _buildScanProgressIndicator(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text(QrCodeScannerScreen.title),
    );
  }

  Widget _buildScannerView() {
    return MobileScanner(
      key: qrKey,
      controller: controller,
      onDetect: (BarcodeCapture capture) {
        if (_debounceTimer?.isActive ?? false || isProcessing) {
          return;
        }
        _debounceTimer = Timer(const Duration(milliseconds: 2000), () async {
          isProcessing = true;
          var scannerLogic = QRCodeScannerLogic(
            context: context,
            ref: ref,
            scanMode: widget.scanMode,
            controller: controller,
            accountFlow: widget.accountFlow,
          );
          scannerLogic.handleBarcode(capture);
          isProcessing = false;
        });
      },
    );
  }

  Widget _buildScanTargetIndicator() {
    return Center(
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          border: Border.all(color: context.colorScheme.primary, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildScanProgressIndicator() {
    return Positioned(
      bottom: kScreenPadding,
      left: kScreenPadding,
      right: kScreenPadding,
      child: Consumer(
        builder: (context, ref, child) {
          final scanState = ref.watch(multipartScanProvider);
          if (scanState.totalParts > 0) {
            int nextPart = scanState.scannedParts.length + 1;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LinearProgressIndicator(
                  value: scanState.scannedParts.length / scanState.totalParts,
                  backgroundColor: Colors.white,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      context.colorScheme.secondary),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    "Scan part $nextPart of ${scanState.totalParts}",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                )
              ],
            );
          } else {
            return const Text(
              'Scan a QR code',
              style: TextStyle(color: Colors.white, fontSize: 16),
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    controller.dispose();
    super.dispose();
  }
}
