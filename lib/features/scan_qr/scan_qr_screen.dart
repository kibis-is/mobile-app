import 'dart:async';
import 'package:convert/convert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:kibisis/providers/temporary_account_provider.dart';
import 'package:kibisis/common_widgets/top_snack_bar.dart';
import 'package:kibisis/utils/theme_extensions.dart';

enum ScanMode { privateKey, publicKey }

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
  MobileScannerController controller = MobileScannerController();
  bool _processing = false;
  Timer? _debounceTimer;

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
            onDetect: _onQRViewCreated,
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

  Future<void> _onQRViewCreated(BarcodeCapture capture) async {
    if (_processing) return;
    final String? qrData = capture.barcodes.first.rawValue;
    if (qrData == null) return;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 2000), () async {
      _processing = true;
      try {
        if (widget.scanMode == ScanMode.privateKey) {
          await _handlePrivateKeyMode(qrData);
        } else if (widget.scanMode == ScanMode.publicKey) {
          await _handlePublicKeyMode(qrData);
        }
      } catch (e) {
        if (!mounted) return;
        showCustomSnackBar(
          context: context,
          snackType: SnackType.error,
          message: e.toString(),
        );
      } finally {
        _processing = false;
        controller.start();
      }
    });
  }

  Future<void> _handlePrivateKeyMode(String qrData) async {
    final uri = Uri.parse(qrData);
    final privateKey = uri.queryParameters['privatekey']?.toUpperCase();
    if (privateKey == null) {
      showCustomSnackBar(
        context: context,
        snackType: SnackType.error,
        message: 'QR code is not an account',
      );
      return;
    }
    if (privateKey.length != 64 ||
        !RegExp(r'^[0-9a-fA-F]+$').hasMatch(privateKey)) {
      showCustomSnackBar(
        context: context,
        snackType: SnackType.error,
        message: 'Invalid private key format',
      );
      return;
    }

    final seed = Uint8List.fromList(hex.decode(privateKey));
    await ref
        .read(temporaryAccountProvider.notifier)
        .restoreAccountFromSeed(seed);

    if (!mounted) return;
    GoRouter.of(context).push(widget.accountFlow == AccountFlow.setup
        ? '/setup/setupNameAccount'
        : '/addAccount/addAccountNameAccount');
  }

  Future<void> _handlePublicKeyMode(String qrData) async {
    if (qrData.length == 58 && RegExp(r'^[A-Z2-7]+$').hasMatch(qrData)) {
      if (!mounted) return;
      Navigator.pop(context, qrData);
    } else {
      showCustomSnackBar(
        context: context,
        snackType: SnackType.error,
        message: 'Invalid recipient address',
      );
    }
  }

  @override
  void dispose() {
    controller.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }
}
