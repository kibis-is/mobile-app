import 'package:algorand_dart/algorand_dart.dart';
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
  /// BigInt balance = contract.balanceOf('INM3RC2AU43ZYJNLUOJF3NMWVK56CDL36JVQUP2G573E3PY4PU7KGHELJA');
  /// print(balance.toString()); // Output: 1000
  /// ```
  Future<BigInt> balanceOf(String address) async {
    final result = await readByMethodSignature(methodSignature: 'arc200_balanceOf(address)uint256', appArgs: [
      BaseContract.convertAddressToAppArg(address),
    ]);

    if (!Address.isAlgorandAddress(address)) {

    }

    if (result == null) {
      return BigInt.zero;
    }

    return ABIUintType(256).decode(result);
  }
}
