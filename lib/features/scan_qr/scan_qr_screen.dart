import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/top_snack_bar.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/temporary_account_provider.dart';
import 'package:kibisis/utils/theme_extensions.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrCodeScannerScreen extends ConsumerStatefulWidget {
  static String title = 'Import via QR Code';
  final AccountFlow accountFlow;

  const QrCodeScannerScreen({super.key, required this.accountFlow});

  @override
  QrCodeScannerScreenState createState() => QrCodeScannerScreenState();
}

class QrCodeScannerScreenState extends ConsumerState<QrCodeScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  bool _processing = false;

  @override
  void reassemble() {
    super.reassemble();
    if (defaultTargetPlatform == TargetPlatform.android) {
      controller?.pauseCamera();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      controller?.resumeCamera();
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
      appBar: AppBar(
        title: Text(QrCodeScannerScreen.title),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (result != null)
                  ? Text(
                      'Barcode Type: ${result!.format.name}   Data: ${result!.code}')
                  : const Text('Scan a code'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onQRViewCreated(QRViewController controller) async {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (_processing) {
        return;
      }

      _processing = true;
      final qrData = scanData.code;
      try {
        final uri = Uri.parse(qrData!);
        final privateKey = uri.queryParameters['privatekey'];
        if (privateKey != null) {
          await ref
              .read(temporaryAccountProvider.notifier)
              .restoreAccountFromPrivateKey(privateKey);
          if (!mounted) return;
          GoRouter.of(context).push(widget.accountFlow == AccountFlow.setup
              ? '/setup/setupNameAccount'
              : '/addAccount/addAccountNameAccount');
        } else {
          throw Exception('Invalid QR code format');
        }
      } catch (e) {
        showCustomSnackBar(
          context: context,
          snackType: SnackType.error,
          message: e.toString(),
        );
      } finally {
        _processing = false;
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
