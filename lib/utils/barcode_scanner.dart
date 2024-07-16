import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/top_snack_bar.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/loading_provider.dart';
import 'package:kibisis/providers/temporary_account_provider.dart';
import 'package:kibisis/utils/account_setup.dart';
import 'package:kibisis/utils/refresh_account_data.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRCodeScannerLogic {
  final BuildContext context;
  final WidgetRef ref;
  final ScanMode scanMode;
  final MobileScannerController? controller;
  final AccountFlow? accountFlow;

  QRCodeScannerLogic({
    required this.context,
    required this.ref,
    required this.scanMode,
    this.controller,
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
      controller?.start();
    }
  }

  Future<void> handleMockBarcode(String capture) async {
    try {
      if (scanMode == ScanMode.privateKey) {
        await _handlePrivateKeyMode(capture);
      } else if (scanMode == ScanMode.publicKey) {
        await _handlePublicKeyMode(capture);
      }
    } catch (e) {
      if (!context.mounted) return;
      showCustomSnackBar(
        context: context,
        snackType: SnackType.error,
        message: e.toString(),
      );
    }
  }

  Map<String, List<String>> _parseQueryParams(String query) {
    var params = <String, List<String>>{};
    var parts = query.split('&');

    for (var part in parts) {
      var index =
          part.indexOf('='); // Find the first '=' which separates key and value
      if (index == -1) continue; // Skip if there's no '='

      var key = part.substring(0, index);
      var value = Uri.decodeComponent(
          part.substring(index + 1)); // Decode everything after the '='

      if (!params.containsKey(key)) {
        params[key] = [];
      }
      params[key]?.add(value);
    }

    return params;
  }

  bool _validateAccounts(List<String> names, List<String> keys) {
    if (keys.length != names.length) {
      return false;
    }

    Set<String> seenKeys = {};
    for (int i = 0; i < keys.length; i++) {
      // Check if the keys are of 44 characters and valid base64 URL encoding
      if (keys[i].length != 44 ||
          !RegExp(r'^[A-Za-z0-9\-_]+=*$').hasMatch(keys[i])) {
        return false;
      }
      if (!seenKeys.add(keys[i])) {
        // Duplicate key within the QR code
        continue;
      }
    }
    return true;
  }

  Future<void> _handlePrivateKeyMode(String? qrData) async {
    if (qrData == null) return;

    final uri = Uri.parse(qrData);
    final params = _parseQueryParams(uri.query);
    final names = params['name'] ?? [];
    final keys = params['privatekey'] ?? [];

    if (!_validateAccounts(names, keys)) {
      showCustomSnackBar(
        context: context,
        snackType: SnackType.error,
        message: 'Import Failed - Private keys are not valid',
      );
      return;
    }

    List<String> validNames = [];
    List<Uint8List> validSeeds = [];

    for (int i = 0; i < names.length; i++) {
      final base64Key = keys[i];

      try {
        final seed = base64Url.decode(base64Key);
        if (await ref
            .read(temporaryAccountProvider.notifier)
            .accountAlreadyExists(base64Key)) {
          continue; // Skip duplicate keys
        }

        validNames.add(names[i]);
        validSeeds.add(seed);
      } catch (e) {
        // Handle decoding error
        continue;
      }
    }

    if (validSeeds.isEmpty || validNames.isEmpty) {
      throw Exception('No valid private keys found in QR code');
    }

    try {
      for (int i = 0; i < validNames.length; i++) {
        await ref
            .read(temporaryAccountProvider.notifier)
            .restoreAccountFromSeed(validSeeds[i], name: validNames[i]);

        await AccountSetupUtility.completeAccountSetup(
          ref: ref,
          accountFlow: accountFlow!,
          accountName: validNames[i],
          setFinalState: i == validNames.length - 1,
        );
        invalidateProviders(ref);
      }

      if (validNames.length == 1) {
        if (!context.mounted) return;
        GoRouter.of(context).go('/');
      } else {
        if (!context.mounted) return;
        GoRouter.of(context).push('/wallets');
      }

      showCustomSnackBar(
        context: context,
        snackType: SnackType.success,
        message: 'Import Success',
      );
    } catch (e) {
      throw Exception(e.toString());
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
