import 'dart:async';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/top_snack_bar.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/loading_provider.dart';
import 'package:kibisis/providers/temporary_account_provider.dart';
import 'package:kibisis/utils/account_setup.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRCodeScannerLogic {
  final BuildContext context;
  final WidgetRef ref;
  final ScanMode scanMode;
  final MobileScannerController controller;
  final AccountFlow? accountFlow;

  QRCodeScannerLogic({
    required this.context,
    required this.ref,
    required this.scanMode,
    required this.controller,
    this.accountFlow,
  });

  Future<void> handleBarcode(BarcodeCapture capture) async {
    try {
      if (scanMode == ScanMode.privateKey) {
        await _handlePrivateKeyMode(capture.barcodes.first.rawValue);
      } else if (scanMode == ScanMode.publicKey) {
        await _handlePublicKeyMode(capture.barcodes.first.rawValue);
      }
    } catch (e) {
      if (!context.mounted) return;
      showCustomSnackBar(
        context: context,
        snackType: SnackType.error,
        message: e.toString(),
      );
    } finally {
      controller.start();
    }
  }

  Future<void> _handlePrivateKeyMode(String? qrData) async {
    if (qrData == null) return;
    ref.read(loadingProvider.notifier).startLoading();
    final uri = Uri.parse(qrData);
    final privateKey = uri.queryParameters['privatekey']?.toUpperCase();
    final encoding = uri.queryParameters['encoding'];
    final name = uri.queryParameters['name'];

    if (privateKey == null || encoding != 'hex') {
      showCustomSnackBar(
        context: context,
        snackType: SnackType.error,
        message: 'QR code does not contain a valid account or encoding',
      );
      ref.read(loadingProvider.notifier).stopLoading();
      return;
    }

    if (privateKey.length != 64 ||
        !RegExp(r'^[0-9a-fA-F]+$').hasMatch(privateKey)) {
      showCustomSnackBar(
        context: context,
        snackType: SnackType.error,
        message: 'Invalid private key format',
      );
      ref.read(loadingProvider.notifier).stopLoading();
      return;
    }

    final seed = Uint8List.fromList(hex.decode(privateKey));
    try {
      await ref
          .read(temporaryAccountProvider.notifier)
          .restoreAccountFromSeed(seed, name: name);

      if (name != null && name.isNotEmpty) {
        await AccountSetupUtility.completeAccountSetup(ref, name, accountFlow!);
        if (!context.mounted) return;
        GoRouter.of(context).go('/');
        showCustomSnackBar(
            context: context,
            snackType: SnackType.success,
            message: 'Account "$name" imported successfully!');
      } else {
        if (!context.mounted) return;
        GoRouter.of(context).push(accountFlow == AccountFlow.setup
            ? '/setup/setupNameAccount'
            : '/addAccount/addAccountNameAccount');
      }
    } catch (e) {
      if (!context.mounted) return;
      showCustomSnackBar(
          context: context,
          snackType: SnackType.error,
          message: 'Failed to import account: ${e.toString()}');
    } finally {
      ref.read(loadingProvider.notifier).stopLoading();
    }
  }

  Future<void> _handlePublicKeyMode(String? qrData) async {
    if (qrData == null) return;

    if (qrData.length == 58 && RegExp(r'^[A-Z2-7]+$').hasMatch(qrData)) {
      if (!context.mounted) return;
      Navigator.pop(context, qrData);
    } else {
      showCustomSnackBar(
        context: context,
        snackType: SnackType.error,
        message: 'Invalid recipient address',
      );
    }
  }
}
