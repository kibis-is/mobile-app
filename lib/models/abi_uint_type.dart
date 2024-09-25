import 'dart:typed_data';

import 'package:kibisis/exceptions/abi_value_exception.dart';
import 'package:kibisis/utils/bigint_to_bytes.dart';
import 'package:kibisis/utils/bytes_to_bigint.dart';

class ABIUintType {
  final int size;

  ABIUintType(this.size) {
    if (size % 8 != 0 || size < 8 || size > 512) {
      throw ABIValueException('unsupported uint type bitSize: $size');
    }
  }

  Uint8List encode(BigInt value) {
    if (value >= BigInt.from(2).pow(size) || value < BigInt.zero) {
      throw ABIValueException('$value is not a non-negative int or too big to fit in size $toString()');
    }

    return bigIntToBytes(value, size);
  }

  BigInt decode(Uint8List bytes) {
    if (bytes.length != size / 8) {
      throw ABIValueException('byte length must correspond to "$toString()"');
    }

    return bytesToBigInt(bytes);
  }

  @override
  String toString() {
    return 'uint$size';
  }
}
