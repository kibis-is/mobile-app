import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/generated/l10n.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRCodeScannerLogic {
  final AccountFlow accountFlow;
  final ScanMode scanMode;

  QRCodeScannerLogic({
    this.accountFlow = AccountFlow.general,
    this.scanMode = ScanMode.catchAll,
  });

  Future<dynamic> handleBarcode(
      BarcodeCapture capture, BuildContext context) async {
    try {
      String rawData = capture.barcodes.first.rawValue ?? '';
      if (rawData.isEmpty) throw Exception(S.of(context).invalidQrCodeData);

      switch (scanMode) {
        case ScanMode.privateKey:
          if (isPublicKeyFormat(rawData)) {
            throw Exception(S.of(context).expectedPrivateKeyButPublic);
          } else if (isSupportedWalletConnectUri(rawData, context)) {
            throw Exception(S.of(context).expectedPrivateKeyButWalletConnect);
          }
          return await _handleImportAccountUri(rawData, context);

        case ScanMode.publicKey:
          if (!isPublicKeyFormat(rawData)) {
            throw Exception(S.of(context).expectedPublicKey);
          }
          return _handlePublicKey(rawData, context);

        case ScanMode.session:
          if (!isSupportedWalletConnectUri(rawData, context)) {
            throw Exception(S.of(context).expectedWalletConnectUri);
          }
          return Uri.parse(rawData);

        case ScanMode.catchAll:
          if (isPublicKeyFormat(rawData)) {
            return _handlePublicKey(rawData, context);
          } else if (isImportAccountUri(rawData)) {
            return await _handleImportAccountUri(rawData, context);
          } else if (isSupportedWalletConnectUri(rawData, context)) {
            return Uri.parse(rawData);
          } else {
            throw Exception(S.of(context).unknownQrCodeType);
          }
      }
    } catch (e) {
      rethrow;
    }
  }

  bool isSupportedWalletConnectUri(String rawData, BuildContext context) {
    if (!rawData.startsWith('wc:')) return false;
    try {
      Uri uri = Uri.parse(rawData);
      final segments = uri.toString().split('@');
      if (segments.length > 1) {
        final version = int.tryParse(segments[1].substring(0, 1));
        if (version == 1) {
          throw UnsupportedError(S.of(context).walletConnectV1NotSupported);
        } else if (version == 2) {
          return true;
        } else {
          throw UnsupportedError(S.of(context).unknownWalletConnectVersion);
        }
      } else {
        throw UnsupportedError(S.of(context).invalidWalletConnectUri);
      }
    } catch (e) {
      throw UnsupportedError(
          '${S.of(context).failedParseWalletConnectUri}: $e');
    }
  }

  bool isImportAccountUri(String uriString) {
    if (!uriString.startsWith('avm://account/import')) return false;
    Uri? uri = Uri.tryParse(uriString);
    if (uri == null) return false;
    return uri.hasAbsolutePath && uriString.contains('import');
  }

  String _handlePublicKey(String rawData, BuildContext context) {
    if (isPublicKeyFormat(rawData)) {
      return rawData;
    } else {
      throw Exception(S.of(context).invalidPublicKeyFormat);
    }
  }

  Future<dynamic> _handleImportAccountUri(
      String uri, BuildContext context) async {
    Uri? parsedUri = Uri.tryParse(uri);
    if (parsedUri == null) {
      throw Exception(S.of(context).invalidUriFormat);
    }

    List<MapEntry<String, String>> params =
        getOrderedQueryParameters(parsedUri.query);

    bool isModernUri = params.any((param) => param.key == 'privatekey') &&
        !params.any((param) => param.key == 'encoding' && param.value == 'hex');

    if (isModernUri) {
      bool isPaginated = params.any((param) => param.key == 'page');
      if (isPaginated) {
        return handlePaginatedUri(params, context);
      } else {
        return handleModernUri(params, context);
      }
    } else if (params
        .any((param) => param.key == 'encoding' && param.value == 'hex')) {
      return handleLegacyUri(params, context);
    } else {
      throw Exception(S.of(context).unknownImportUriFormat);
    }
  }

  Map<String, dynamic> handlePaginatedUri(
      List<MapEntry<String, String>> params, BuildContext context) {
    String? checksum;
    String? pageInfo;

    for (var param in params) {
      if (param.key == 'checksum') {
        checksum = param.value;
      } else if (param.key == 'page') {
        pageInfo = param.value;
      }
    }

    if (checksum == null || pageInfo == null) {
      throw Exception(S.of(context).paginatedUriMissingInfo);
    }

    List<String> pageParts = pageInfo.split(':');
    if (pageParts.length != 2) {
      throw Exception(S.of(context).invalidPageFormat);
    }
    int currentPage = int.parse(pageParts[0]);
    int totalPages = int.parse(pageParts[1]);

    return {
      'checksum': checksum,
      'currentPage': currentPage,
      'totalPages': totalPages,
      'params': params,
    };
  }

  List<Map<String, dynamic>> handleModernUri(
      List<MapEntry<String, String>> params, BuildContext context) {
    List<Map<String, dynamic>> result = [];

    String? currentName;
    int importedAccountCounter = 1;

    for (var param in params) {
      if (param.key == 'name') {
        currentName = param.value;
      } else if (param.key == 'privatekey') {
        String name = currentName ??
            S.of(context).importedAccountWithCounter(importedAccountCounter);

        if (currentName == null) {
          importedAccountCounter++;
        }
        currentName = null;

        Uint8List? seed = _decodePrivateKey(param.value);

        if (seed == null || seed.length != 32) {
          throw Exception(S.of(context).invalidPrivateKey);
        }

        result.add({
          'name': name,
          'seed': seed,
        });
      }
    }

    return result;
  }

  List<Map<String, dynamic>> handleLegacyUri(
      List<MapEntry<String, String>> params, BuildContext context) {
    List<Map<String, dynamic>> result = [];

    final String name = S.of(context).importedAccount;

    final privateKeyParam = params.firstWhere(
      (param) => param.key == 'privatekey',
      orElse: () => throw Exception(S.of(context).missingPrivateKeyLegacy),
    );

    Uint8List? seed = _decodePrivateKey(privateKeyParam.value);

    if (seed == null || seed.length != 32) {
      throw Exception(S.of(context).invalidPrivateKey);
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
        }
      }
    } catch (_) {}
    return null;
  }

  bool isPublicKeyFormat(String data) {
    return data.length == 58 && RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(data);
  }

  List<MapEntry<String, String>> getOrderedQueryParameters(String query) {
    List<MapEntry<String, String>> params = [];

    var queryString = query.split('?').last;
    var parts = queryString.split('&');

    for (var part in parts) {
      var index = part.indexOf('=');
      if (index != -1) {
        var key = Uri.decodeComponent(part.substring(0, index));
        var value = Uri.decodeComponent(part.substring(index + 1));
        params.add(MapEntry(key, value));
      }
    }

    return params;
  }
}
