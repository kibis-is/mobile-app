import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/main.dart';
import 'package:kibisis/providers/temporary_account_provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrCodeScannerScreen extends ConsumerStatefulWidget {
  static String title = 'Import via QR Code';
  final bool isSetupFlow;

  const QrCodeScannerScreen({super.key, this.isSetupFlow = true});

  @override
  QrCodeScannerScreenState createState() => QrCodeScannerScreenState();
}

class QrCodeScannerScreenState extends ConsumerState<QrCodeScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

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
            style: Theme.of(context).textTheme.headlineSmall,
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

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      result = scanData;
      final uri = Uri.parse(scanData.code!);
      if (uri.scheme == 'avm' &&
          uri.host == 'account' &&
          uri.path == '/import') {
        final encoding = uri.queryParameters['encoding'];
        final privateKey = uri.queryParameters['privatekey'];
        if (encoding == 'hex' && privateKey != null) {
          try {
            await ref
                .read(temporaryAccountProvider.notifier)
                .restoreAccountFromPrivateKey(privateKey);
            if (!mounted) return;
            GoRouter.of(context).push(widget.isSetupFlow
                ? '/setup/setupNameAccount'
                : '/addAccount/addAccountNameAccount');
          } catch (e) {
            if (!mounted) return;
            rootScaffoldMessengerKey.currentState?.showSnackBar(
              SnackBar(
                content: Text('Invalid QR code: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
