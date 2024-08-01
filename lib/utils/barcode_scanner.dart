import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/top_snack_bar.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/scan_qr/scan_qr_screen.dart';
import 'package:kibisis/features/scan_qr/widgets/progress_bar.dart';
import 'package:kibisis/providers/multipart_scan_provider.dart';
import 'package:kibisis/providers/temporary_account_provider.dart';
import 'package:kibisis/utils/account_setup.dart';
import 'package:kibisis/utils/refresh_account_data.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vibration/vibration.dart';

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
    bool isSuccess = false;
    try {
      String rawData = capture.barcodes.first.rawValue ?? '';
      await _handleVibration();
      isSuccess = await _processBarcodeData(rawData);
    } catch (e) {
      _resetProviders();
      if (context.mounted) {
        showCustomSnackBar(
          context: context,
          snackType: SnackType.error,
          message: e.toString(),
        );
      }
      rethrow;
    } finally {
      isSuccess ? controller?.stop() : controller?.start();
    }
  }

  Future<void> handleMockBarcode(String capture) async {
    try {
      if (scanMode == ScanMode.privateKey) {
        await _handlePrivateKey(capture);
      } else if (scanMode == ScanMode.publicKey) {
        await _handlePublicKey(capture);
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

  Future<void> _handleVibration() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 100);
    }
  }

  Future<bool> _processBarcodeData(String rawData) async {
    Uri uri = Uri.parse(rawData);
    Map<String, List<String>> params = _parseQueryParams(uri.query);

    if (scanMode == ScanMode.privateKey) {
      if (params.containsKey('page')) {
        return await _handlePaginatedScan(uri, params);
      } else {
        return await _handlePrivateKey(rawData);
      }
    } else if (scanMode == ScanMode.publicKey) {
      return await _handlePublicKey(rawData);
    }

    return false;
  }

  Future<bool> _handlePaginatedScan(
      Uri uri, Map<String, List<String>> params) async {
    _setPaginatedScanState(true);

    final pageDetails = params['page']![0].split(':');
    final currentPage = int.parse(pageDetails[0]);
    final totalPages = int.parse(pageDetails[1]);
    _updateScanProgress(currentPage, totalPages, uri);

    if (_isScanComplete(totalPages)) {
      if (!_validateChecksum()) {
        _resetProviders();
        throw Exception('Checksum mismatch. Operation aborted.');
      }
      return await _processFinalScannedParts();
    }
    return false;
  }

  void _setPaginatedScanState(bool state) {
    ref.read(isPaginatedScanProvider.notifier).state = state;
  }

  void _updateScanProgress(int currentPage, int totalPages, Uri uri) {
    ref.read(multipartScanProvider.notifier).setTotalParts(totalPages);
    ref
        .read(multipartScanProvider.notifier)
        .addPart(currentPage.toString(), uri.toString());
    var scanState = ref.read(multipartScanProvider);
    ref.read(progressBarProvider.notifier).state =
        scanState.scannedParts.length / totalPages;
  }

  bool _isScanComplete(int totalPages) {
    var scanState = ref.read(multipartScanProvider);
    return scanState.scannedParts.length == totalPages && scanState.isComplete;
  }

  bool _validateChecksum() {
    var scanState = ref.read(multipartScanProvider);
    String? expectedChecksum = Uri.parse(scanState.scannedParts.values.first)
        .queryParameters['checksum'];
    return scanState.scannedParts.values.every((uri) =>
        Uri.parse(uri).queryParameters['checksum'] == expectedChecksum);
  }

  Future<bool> _processFinalScannedParts() async {
    var scanState = ref.read(multipartScanProvider);
    for (var uri in scanState.scannedParts.values) {
      bool isFinalPart = uri == scanState.scannedParts.values.last;
      bool isSuccess = await _handlePrivateKey(uri, isFinalPart: isFinalPart);
      if (!isSuccess) return false;
    }
    _resetProviders();
    return true;
  }

  Future<bool> _handlePrivateKey(String? qrData,
      {bool isFinalPart = true}) async {
    if (qrData == null) {
      throw Exception('QR data is null');
    }

    try {
      final uri = Uri.parse(qrData);
      final params = _parseQueryParams(uri.query);
      final names = params['name'] ?? [];
      final keys = params['privatekey'] ?? [];

      if (!_validateAccounts(names, keys)) {
        throw Exception('Private keys are not valid');
      }

      await _restoreAccounts(names, keys);

      if (isFinalPart) {
        _navigateToAccountPage(names.length);
      }

      _showSuccessSnackBar();
      return true;
    } catch (e) {
      rethrow; // Rethrow the exception to be caught at the root level
    } finally {}
  }

  Future<void> _restoreAccounts(List<String> names, List<String> keys) async {
    List<String> validNames = [];
    List<Uint8List> validSeeds = [];

    for (int i = 0; i < names.length; i++) {
      final base64Key = keys[i];

      try {
        final seed = base64Url.decode(base64Key);
        if (await ref
            .read(temporaryAccountProvider.notifier)
            .accountAlreadyExists(base64Key)) {
          continue;
        }

        validNames.add(names[i]);
        validSeeds.add(seed);
      } catch (e) {
        continue;
      }
    }

    if (validSeeds.isEmpty || validNames.isEmpty) {
      throw Exception('No valid private keys found in QR code');
    }

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
  }

  Future<bool> _handlePublicKey(String? qrData) async {
    if (qrData == null) return false;

    if (qrData.length == 58 && RegExp(r'^[A-Z2-7]+$').hasMatch(qrData)) {
      if (context.mounted) {
        Navigator.pop(context, qrData);
      }
      return true;
    } else {
      throw Exception('Invalid recipient address');
    }
  }

  void _navigateToAccountPage(int numOfAccounts) {
    if (numOfAccounts == 1) {
      if (context.mounted) {
        GoRouter.of(context).go('/');
      }
    } else {
      if (context.mounted) {
        GoRouter.of(context).push('/wallets');
      }
    }
  }

  void _showSuccessSnackBar() {
    if (context.mounted) {
      showCustomSnackBar(
        context: context,
        snackType: SnackType.success,
        message: 'Import Success',
      );
    }
  }

  void _resetProviders() {
    ref.read(multipartScanProvider.notifier).reset();
    ref.read(progressBarProvider.notifier).state = 0.0;
    ref.read(isPaginatedScanProvider.notifier).state = false;
  }

  Map<String, List<String>> _parseQueryParams(String query) {
    var params = <String, List<String>>{};
    var parts = query.split('&');

    for (var part in parts) {
      var index = part.indexOf('=');
      if (index == -1) continue;

      var key = part.substring(0, index);
      var value = Uri.decodeComponent(part.substring(index + 1));

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
      if (keys[i].length != 44 ||
          !RegExp(r'^[A-Za-z0-9\-_]+=*$').hasMatch(keys[i])) {
        return false;
      }
      if (!seenKeys.add(keys[i])) {
        continue;
      }
    }
    return true;
  }
}
