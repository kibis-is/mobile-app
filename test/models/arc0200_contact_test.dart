import 'package:algorand_dart/algorand_dart.dart';
import 'package:kibisis/models/arc0200_contract.dart';
import 'package:test/test.dart';

void main() {
  final algodURL = 'https://testnet-api.voi.nodly.io';

  group('balanceOf', () {
    test('should get the balance of an address', () async {
      // arrange
      final contract = ARC0200Contract(
        appID: BigInt.from(6779767),
        algodURL: algodURL,
      );
      // act
      final result = await contract.balanceOf((await Account.random()).publicAddress);

      // assert
      expect(result, BigInt.zero);
    });
  });
}
