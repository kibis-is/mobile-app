import 'dart:typed_data';

import 'package:algorand_dart/algorand_dart.dart';
import 'package:kibisis/models/abi_address_type.dart';
import 'package:kibisis/models/abi_string_type.dart';
import 'package:kibisis/models/abi_uint_type.dart';
import 'package:kibisis/models/base_contract.dart';

class ARC0200Contract extends BaseContract {
  ARC0200Contract({
    required BigInt appID,
    required String algodURL,
    String? algodToken,
  }) : super(appID: appID, algodURL: algodURL, algodToken: algodToken);

  /// Gets the balance of an address.
  ///
  /// If the address is not valid or a "zero" address, 0 is returned.
  ///
  /// **Parameters:**
  /// - [address]: The address to check.
  ///
  /// **Returns:**
  /// A Future<BigInt> of the balance of the address.
  ///
  /// **Example:**
  /// ```dart
  /// final contract = ARC0200Contract(...)
  /// Future<BigInt> balance = await contract.balanceOf('INM3RC2AU43ZYJNLUOJF3NMWVK56CDL36JVQUP2G573E3PY4PU7KGHELJA');
  /// print(balance.toString()); // Output: 1000
  /// ```
  Future<BigInt> balanceOf(String address) async {
    Uint8List? result;

    if (!Address.isAlgorandAddress(address)) {
      return BigInt.zero;
    }

    result = await readByMethodSignature(methodSignature: 'arc200_balanceOf(address)uint256', appArgs: [
      ABIAddressType().encode(address),
    ]);

    if (result == null) {
      return BigInt.zero;
    }

    return ABIUintType(256).decode(result);
  }

  /// Gets the decimals of the token.
  ///
  /// **Returns:**
  /// A Future<int> of the decimals.
  ///
  /// **Example:**
  /// ```dart
  /// final contract = ARC0200Contract(...)
  /// Future<int> decimals = await contract.decimals();
  /// print(decimals); // Output: 6
  /// ```
  Future<int> decimals() async {
    final result = await readByMethodSignature(methodSignature: 'arc200_decimals()uint8', appArgs: []);

    if (result == null) {
      return 0;
    }

    return ABIUintType(8).decode(result).toInt();
  }

  /// Gets the name of the token.
  ///
  /// **Returns:**
  /// A Future<String> of the name of the token.
  ///
  /// **Example:**
  /// ```dart
  /// final contract = ARC0200Contract(...)
  /// Future<String> name = await contract.name();
  /// print(name); // Output: Voi Incentive Token
  /// ```
  Future<String> name() async {
    final result = await readByMethodSignature(methodSignature: 'arc200_name()byte[32]', appArgs: []);

    if (result == null) {
      return '';
    }

    return ABIStringType().decode(result);
  }

  /// Gets the symbol of the token.
  ///
  /// **Returns:**
  /// A Future<String> of the symbol of the token.
  ///
  /// **Example:**
  /// ```dart
  /// final contract = ARC0200Contract(...)
  /// Future<String> symbol = await contract.symbol();
  /// print(symbol); // Output: $VIA
  /// ```
  Future<String> symbol() async {
    final result = await readByMethodSignature(methodSignature: 'arc200_symbol()byte[8]', appArgs: []);

    if (result == null) {
      return '';
    }

    return ABIStringType().decode(result);
  }

  /// Gets the total supply of the token.
  ///
  /// **Returns:**
  /// A Future<BigInt> of the total supply of the token.
  ///
  /// **Example:**
  /// ```dart
  /// final contract = ARC0200Contract(...)
  /// Future<BigInt> totalSupply = await contract.totalSupply();
  /// print(totalSupply.toString()); // Output: 1000
  /// ```
  Future<BigInt> totalSupply() async {
    final result = await readByMethodSignature(methodSignature: 'arc200_totalSupply()uint256', appArgs: []);

    if (result == null) {
      return BigInt.zero;
    }

    return ABIUintType(256).decode(result);
  }
}
