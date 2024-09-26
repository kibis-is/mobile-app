import 'dart:typed_data';

import 'package:algorand_dart/algorand_dart.dart';
import 'package:kibisis/constants/avm.dart';
import 'package:kibisis/exceptions/abi_value_exception.dart';

class ABIAddressType {
  Uint8List encode(String value) {
    if (!Address.isAlgorandAddress(value)) {
      throw ABIValueException('the supplied value "$value" is not a valid address');
    }

    return Address.decodeAddress(value);
  }

  String decode(Uint8List value) {
    if (value.buffer.lengthInBytes != ADDRESS_BYTE_SIZE) {
      throw ABIValueException('byte string must be $ADDRESS_BYTE_SIZE bytes long for a valid address, found "${value.buffer.lengthInBytes}" length');
    }

    return Address.encodeAddress(value);
  }

  @override
  String toString() {
    return 'address';
  }
}
