import 'package:algorand_dart/algorand_dart.dart';
import 'package:kibisis/models/base_contract.dart';
import 'package:test/test.dart';

void main() {
  group('applicationAddress', () {
    test("should return the application's address", () {
      // arrange
      final contract = BaseContract(
        6779767,
        AlgodClient(apiUrl: 'http://localhost:4001')
      );
      // act
      final address = contract.applicationAddress();

      // assert
      expect(address, 'INM3RC2AU43ZYJNLUOJF3NMWVK56CDL36JVQUP2G573E3PY4PU7KGHELJA');
    });
  });
}
