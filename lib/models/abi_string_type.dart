import 'dart:convert';
import 'dart:typed_data';

class ABIStringType {
  Uint8List encode(String value) {
    return utf8.encode(value);
  }

  String decode(Uint8List value) {
    final decodedString = utf8.decode(value);

    // trim any "null" bytes
    return decodedString.replaceAll('\x00', '');
  }

  @override
  String toString() {
    return 'string';
  }
}
