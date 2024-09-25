import 'package:algorand_dart/algorand_dart.dart';
import 'package:kibisis/models/base_contract.dart';

class ARC0200Contract extends BaseContract {
  ARC0200Contract({
    required BigInt appID,
    required String algodURL,
    String? algodToken,
  }) : super(appID: appID, algodURL: algodURL, algodToken: algodToken);

  Future<BigInt> balanceOf({
    required String address
  }) async {
    final result = await readByMethodSignature(methodSignature: 'arc200_balanceOf(address)uint256', appArgs: [
      BaseContract.convertAddressToAppArg(address),
    ]);

    if (result == null) {
      return BigInt.zero;
    }

    return BigIntEncoder.decodeUint64(result);
  }
}
