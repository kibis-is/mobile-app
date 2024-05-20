import 'dart:convert';

import 'package:crypto/crypto.dart';

class CryptoUtils {
  static String hashPin(String pin) {
    var bytes = utf8.encode(pin);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }
}
