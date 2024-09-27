import 'package:kibisis/models/base_contract.dart';
import 'package:test/test.dart';

void main() {
  final address = 'INM3RC2AU43ZYJNLUOJF3NMWVK56CDL36JVQUP2G573E3PY4PU7KGHELJA';

  group('address', () {
    test("should return the application's address", () async {
      // arrange
      final contract = BaseContract(appID: BigInt.from(6779767), algodURL: 'https://somewhre');
      // act
      final result = contract.address();

      // assert
      expect(result, address);
    });
  });
}