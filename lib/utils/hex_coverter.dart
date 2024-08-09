import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:base32/base32.dart';
import 'package:flutter/foundation.dart';

class HexConverter {
  static String convertToHex(String input) {
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

  static bool _isHex(String input) {
    return RegExp(r'^[0-9a-fA-F]+$').hasMatch(input) && (input.length == 64);
  }

  static String _handleHex(String input) {
    return input.toLowerCase();
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

void main() {
  String userInput =
      '9b1d3ad61a62e0eadedd4d53fffe405a95ac461435c7b7e4e299f110f0c8407d';

  try {
    String hexPrivateKey = HexConverter.convertToHex(userInput);
    debugPrint('Hexadecimal Key: $hexPrivateKey');
  } catch (e) {
    debugPrint('Error: ${e.toString()}');
  }
}
