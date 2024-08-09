import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:base32/base32.dart';

class HexConverter {
  static String convertToHex(String input) {
    if (_isUri(input)) {
      return _handleUri(input);
    }

    if (_isHex(input)) {
      return _handleHex(input);
    }

    if (_isBase64(input)) {
      return _handleBase64(input);
    }

    if (_isBase32(input)) {
      return _handleBase32(input);
    }

    throw Exception('Unsupported encoding or invalid string format.');
  }

  static bool _isUri(String input) {
    return input.startsWith('avm://');
  }

  static String _handleUri(String input) {
    final uri = Uri.parse(input);
    final privateKey = uri.queryParameters['privatekey'] ?? '';
    final encoding = uri.queryParameters['encoding'] ?? '';

    if (privateKey.isEmpty) {
      throw Exception('Private key is missing in the URI.');
    }

    switch (encoding.toLowerCase()) {
      case 'hex':
        return _handleHex(privateKey);
      case 'base64':
        return _handleBase64(privateKey);
      case 'base32':
        return _handleBase32(privateKey);
      default:
        throw Exception('Unsupported encoding in the URI.');
    }
  }

  static bool _isHex(String input) {
    return RegExp(r'^[0-9a-fA-F]+$').hasMatch(input);
  }

  static String _handleHex(String input) {
    if (input.length == 64) {
      return input.toLowerCase();
    } else if (input.length == 128) {
      return input.substring(0, 64).toLowerCase();
    } else {
      throw Exception('Invalid hex string length.');
    }
  }

  static bool _isBase64(String input) {
    return RegExp(r'^[A-Za-z0-9+/]+={0,2}$').hasMatch(input);
  }

  static String _handleBase64(String input) {
    try {
      final bytes = base64Decode(input);
      return hex.encode(bytes);
    } catch (e) {
      throw Exception('Invalid Base64 string.');
    }
  }

  static bool _isBase32(String input) {
    return RegExp(r'^[A-Z2-7]+=*$').hasMatch(input);
  }

  static String _handleBase32(String input) {
    try {
      final bytes = base32.decode(input);
      return hex.encode(bytes);
    } catch (e) {
      throw Exception('Invalid Base32 string.');
    }
  }
}
