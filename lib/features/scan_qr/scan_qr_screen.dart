import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/confirmation_dialog.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/temporary_account_provider.dart';
import 'package:kibisis/utils/theme_extensions.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

enum ScanMode { privateKey, publicKey }

class QrCodeScannerScreen extends ConsumerStatefulWidget {
  static String title = 'Scan QR';
  final AccountFlow? accountFlow; // Optional
  final ScanMode scanMode;

  const QrCodeScannerScreen({
    super.key,
    this.accountFlow, // Now optional
    required this.scanMode,
  });

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
        if (widget.scanMode == ScanMode.privateKey) {
          final uri = Uri.parse(qrData?.toString() ?? '');
          final privateKey = uri.queryParameters['privatekey'];
          if (privateKey == null) {
            throw Exception('QR code is not an account');
          }

          // Validate the privateKey length and ensure it is a valid hexadecimal string
          if (privateKey.length != 128 ||
              !RegExp(r'^[0-9a-fA-F]+$').hasMatch(privateKey)) {
            throw Exception('Invalid private key format');
          }

          // Validate the privateKey length and ensure it is a valid hexadecimal string
          if (privateKey.length != 64 ||
              !RegExp(r'^[0-9a-fA-F]+$').hasMatch(privateKey)) {
            throw Exception('Invalid private key format');
          }

          // Convert the privateKey hex string to a list of bytes
          final privateKeyBytes = Uint8List.fromList(hex.decode(privateKey));
          if (privateKeyBytes.length != 32) {
            throw Exception('Private key must be 32 bytes long');
          }

          // Convert bytes to a base64 string if required by your method (example)
          final base64PrivateKey = base64.encode(privateKeyBytes);

          await ref
              .read(temporaryAccountProvider.notifier)
              .restoreAccountFromPrivateKey(base64PrivateKey);
          if (!mounted) return;
          GoRouter.of(context).push(widget.accountFlow == AccountFlow.setup
              ? '/setup/setupNameAccount'
              : '/addAccount/addAccountNameAccount');
        } else if (widget.scanMode == ScanMode.publicKey) {
          // Assuming public key format for other cases
          if (qrData != null &&
              qrData.length == 58 &&
              RegExp(r'^[A-Z2-7]+$').hasMatch(qrData)) {
            Navigator.pop(
                context, qrData); // Return the scanned data as public key
          } else {
            throw Exception('Invalid public key format');
          }
        }
      } catch (e) {
        await _showErrorDialog(e.toString());
      } finally {
        _processing = false;
      }
    });
  }

  Future<void> _showErrorDialog(String errorMessage) async {
    await controller?.pauseCamera();
    if (!mounted) return;
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: 'Error',
          content: errorMessage,
          isConfirmDialog: false, // Use non-confirmatory dialog
        );
      },
    );
    controller?.resumeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
