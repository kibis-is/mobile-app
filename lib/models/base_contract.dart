import 'dart:convert';
import 'dart:typed_data';

import 'package:algorand_dart/algorand_dart.dart';
import 'package:crypto/crypto.dart';
import 'package:kibisis/constants/avm.dart';

class BaseContract {
  // private variables
  final AlgodClient _algod;

  // public variables
  final int appID;

  BaseContract(
    this.appID,
    this._algod,
  );

  /// Gets the the application's address.
  ///
  /// Returns the application's address.
  ///
  /// Example:
  /// ```dart
  /// final contract = BaseContract(...)
  /// final address = contract.applicationAddress();
  /// print(address); // Output: I7F3LRWCPSKURPRQZ3RFEEI2KFJ4TYC7EKSL75YIWH7LJ4FD5DUMIIPRAU
  /// ```
  String applicationAddress() {
    final prefix = utf8.encode(APP_ID_PREFIX);
    final buffer = Uint8List.fromList([
      ...prefix,
      ...BigIntEncoder.encodeUint64(BigInt.from(appID)),
    ]);
    final digest = sha512256.convert(buffer as List<int>);

    return Address.encodeAddress(Uint8List.fromList(digest.bytes));
  }
}
