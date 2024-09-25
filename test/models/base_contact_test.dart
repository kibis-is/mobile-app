import 'dart:convert';

import 'package:algorand_dart/algorand_dart.dart';
import 'package:kibisis/models/base_contract.dart';
import 'package:test/test.dart';

void main() {
  final address = 'INM3RC2AU43ZYJNLUOJF3NMWVK56CDL36JVQUP2G573E3PY4PU7KGHELJA';

  group('convertAddressToAppArg', () {
    test('should convert an address string to an address arg', () {
      // arrange
      // act
      final result = BaseContract.convertAddressToAppArg(address);

      // assert
      expect(base64.encode(result), 'Q1m4i0CnN5wlq6OSXbWWqrvhDXvyawo/Ru/2Tb8cfT4=');
    });
  });

  group('convertStringToAppArg', () {
    test('should convert a string to a string arg', () {
      // arrange
      // act
      final result = BaseContract.convertStringToAppArg('Simply the best!');

      // assert
      expect(base64.encode(result), 'U2ltcGx5IHRoZSBiZXN0IQ==');
    });
  });

  group('convertUintToAppArg', () {
    test('should convert a BigInt to a uint arg', () {
      // arrange
      // act
      final result = BaseContract.convertUintToAppArg(BigInt.from(1000));

      // assert
      expect(base64.encode(result), 'AAAAAAAAA+g=');
    });
  });

  group('parseBase64EncodedAddressArg', () {
    test('should parse an address string from a base64 address arg', () {
      // arrange
      final encodedArg = base64.encode(Address.decodeAddress(address));
      // act
      final result = BaseContract.parseBase64EncodedAddressArg(encodedArg);

      // assert
      expect(result, address);
    });
  });

  group('parseBase64EncodedStringArg', () {
    test('should parse a string from a base64 string arg', () {
      // arrange
      final arg = 'Simply the best!';
      final encodedArg = base64.encode(utf8.encode(arg));
      // act
      final result = BaseContract.parseBase64EncodedStringArg(encodedArg);

      // assert
      expect(result, arg);
    });
  });

  group('parseBase64EncodedUintArg', () {
    test('should parse a bigint from a base64 uint arg', () {
      // arrange
      final arg = BigInt.from(1000);
      final encodedArg = base64.encode(BigIntEncoder.encodeUint64(arg));
      // act
      final result = BaseContract.parseBase64EncodedUintArg(encodedArg);

      // assert
      expect(result, arg);
    });
  });

  group('parseMethodSignature', () {
    test('should parse the method signature', () {
      // arrange
      final methodSignature = 'arc200_transfer(address,uint256)bool';
      // act
      final result = BaseContract.parseMethodSignature(methodSignature);

      // assert
      expect(base64.encode(result), '2nAluQ==');
    });
  });

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
