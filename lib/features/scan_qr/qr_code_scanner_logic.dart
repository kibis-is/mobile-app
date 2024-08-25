import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:flutter/foundation.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vibration/vibration.dart';

enum QrType {
  privateKeyLegacy,
  privateKey,
  privateKeyPaginated,
  publicKey,
  unknown
}

class QRCodeScannerLogic {
  // final Function(String)? onDataScanned;
  final AccountFlow accountFlow;
  final ScanMode scanMode;

  QRCodeScannerLogic({
    required this.accountFlow,
    // this.onDataScanned,
    this.scanMode = ScanMode.general,
  });

  Future<dynamic> handleBarcode(BarcodeCapture capture) async {
    try {
      String rawData = capture.barcodes.first.rawValue ?? '';
      if (rawData.isEmpty) throw Exception('Invalid QR code data');

      await _handleVibration();

      if (isValidUri(rawData)) {
        return await _handleUri(rawData);
      } else {
        return _handleNonUriData(rawData);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> _handleUri(String rawData) async {
    List<Map<String, dynamic>> accounts = [];

    if (scanMode == ScanMode.general || scanMode == ScanMode.privateKey) {
      Map<String, List<String>> params = getQueryParameters(rawData);
      QrType qrType = getQrType(params);

      switch (qrType) {
        case QrType.privateKeyPaginated:
          // Handle paginated QR code parts.
          break;
        case QrType.privateKey:
          accounts.add(handleModernUri(params));
          break;
        case QrType.privateKeyLegacy:
          accounts.add(handleLegacyUri(params));
          break;
        default:
          throw Exception('Invalid URI');
      }
    } else {
      throw Exception("Invalid Account");
    }

    return accounts;
  }

  String _handleNonUriData(String rawData) {
    if ((scanMode == ScanMode.publicKey || scanMode == ScanMode.general)) {
      if (isPublicKeyFormat(rawData)) {
        return rawData;
      } else {
        throw Exception('Invalid QR Code');
      }
    } else {
      throw Exception('Invalid QR Code');
    }
  }

  Future<void> _handleVibration() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 100);
    }
  }

  Map<String, List<String>> getQueryParameters(String query) {
    var params = <String, List<String>>{};
    var parts = query.split('&');
    for (var part in parts) {
      var index = part.indexOf('=');
      if (index != -1) {
        var key = Uri.decodeComponent(part.substring(0, index));
        var value = Uri.decodeComponent(part.substring(index + 1));
        params.putIfAbsent(key, () => []).add(value);
      }
    }
    return params;
  }

  bool isValidUri(String uriString) {
    Uri? uri = Uri.tryParse(uriString);
    return uri?.hasAbsolutePath ?? false;
  }

  bool isPublicKeyFormat(String data) {
    return data.length == 58 && RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(data);
  }

  QrType getQrType(Map<String, List<String>> queryParams) {
    if (queryParams.containsKey('privatekey') &&
        queryParams.containsKey('page')) {
      return QrType.privateKeyPaginated;
    } else if (queryParams.containsKey('privatkey') &&
        queryParams.containsKey('encoding')) {
      return QrType.privateKeyLegacy;
    } else if (queryParams.containsKey('privatekey')) {
      return QrType.privateKey;
    }
    throw Exception('Invalid URI');
  }

  Map<String, dynamic> handleModernUri(Map<String, List<String>> params) {
    final String name = params['name']?.first ?? 'Imported Account';
    final String key = params['privatekey']?.first ?? '';
    Uint8List? seed = _decodePrivateKey(key);

    if (seed == null || seed.length != 32) {
      throw Exception('Invalid private key');
    }

    return {'name': name, 'seed': seed};
  }

  Map<String, dynamic> handleLegacyUri(Map<String, List<String>> params) {
    const String name = 'Imported Account';
    final String key = params['privatekey']?.first ?? '';
    Uint8List? seed = _decodePrivateKey(key);

    if (seed == null || seed.length != 32) {
      throw Exception('Invalid private key');
    }

    return {'name': name, 'seed': seed};
  }

  Uint8List? _decodePrivateKey(String key) {
    try {
      if (key.length == 44 && RegExp(r'^[A-Za-z0-9\-_]+=*$').hasMatch(key)) {
        return base64Url.decode(key);
      } else if (RegExp(r'^[0-9a-fA-F]+$').hasMatch(key)) {
        if (key.length == 128) {
          final privateKeyHex = key.substring(0, 64);
          return Uint8List.fromList(hex.decode(privateKeyHex));
        } else if (key.length == 64) {
          return Uint8List.fromList(hex.decode(key));
        } else {
          debugPrint('Invalid private key length');
        }
      } else {
        debugPrint('Key is neither valid Base64 nor valid Hex: $key');
      }
    } catch (e) {
      debugPrint('Failed to decode private key: $e');
    }
    return null;
  }
}
