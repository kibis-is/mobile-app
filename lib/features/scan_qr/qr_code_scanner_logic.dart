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

  Future<Set<Map<String, dynamic>>> _handleUri(String rawData) async {
    Set<Map<String, dynamic>> accounts = {};

    if (scanMode == ScanMode.general || scanMode == ScanMode.privateKey) {
      Map<String, List<String>> params = getQueryParameters(rawData);
      QrType qrType = getQrType(params);

      switch (qrType) {
        case QrType.privateKeyPaginated:
          throw Exception('Paginated QR code not yet supported');
        case QrType.privateKey:
          accounts.addAll(handleModernUri(
              params)); // Use addAll to add all maps from the set
          break;
        case QrType.privateKeyLegacy:
          accounts.addAll(handleLegacyUri(params)); // Same for the legacy case
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
    // Initialize the lists to store names and private keys
    List<String> names = [];
    List<String> privateKeys = [];
    int importedAccountCounter = 1;
    String? lastName;

    // Remove the scheme part (avm://account/import?) from the query string
    var queryString = query.split('?').last;
    var parts = queryString.split('&');

    for (var part in parts) {
      var index = part.indexOf('=');
      if (index != -1) {
        var key = Uri.decodeComponent(part.substring(0, index));
        var value = Uri.decodeComponent(part.substring(index + 1));

        if (key == 'name') {
          lastName = value; // Capture the name
        } else if (key == 'privatekey') {
          if (lastName != null) {
            // Use the captured name
            names.add(lastName);
            lastName = null; // Reset lastName after use
          } else {
            // If no name found before this private key, use a default name
            names.add('Imported Account $importedAccountCounter');
            importedAccountCounter++;
          }
          privateKeys.add(value);
        }
      }
    }

    // Combine names and private keys into a map
    return {'name': names, 'privatekey': privateKeys};
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

  Set<Map<String, dynamic>> handleModernUri(Map<String, List<String>> params) {
    print(params);
    Set<Map<String, dynamic>> result = {};

    List<String> names = params['name'] ?? [];
    List<String> privateKeys = params['privatekey'] ?? [];

    // Handle the case where there's at least one name
    int importedAccountCounter = 1;

    for (int i = 0; i < privateKeys.length; i++) {
      String name;

      if (i < names.length) {
        // Use the provided name if it exists
        name = names[i];
      } else {
        // Use the default name and increment the counter for each additional key
        name = 'Imported Account $importedAccountCounter';
        importedAccountCounter++;
      }

      Uint8List? seed = _decodePrivateKey(privateKeys[i]);

      if (seed == null || seed.length != 32) {
        throw Exception('Invalid private key');
      }

      result.add({'name': name, 'seed': seed});
    }

    return result;
  }

  Set<Map<String, dynamic>> handleLegacyUri(Map<String, List<String>> params) {
    Set<Map<String, dynamic>> result = {};

    const String name = 'Imported Account';
    final String key = params['privatekey']?.first ?? '';
    Uint8List? seed = _decodePrivateKey(key);

    if (seed == null || seed.length != 32) {
      throw Exception('Invalid private key');
    }

    result.add({'name': name, 'seed': seed});

    return result;
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
