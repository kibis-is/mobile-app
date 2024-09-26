import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:kibisis/constants/avm.dart';

/// Signs a transaction using the supplied Ed21559 key pair.
///
/// The signature is the signed transaction bytes prefixed with the bytes of
/// string: "TX".
///
/// **Parameters:**
/// - [SimpleKeyPair] [keyPair]: The Ed21559 key pair o sign the transaction.
/// - [Uint8List] [transaction]: The transaction to sign.
///
/// **Returns:**
/// [Future<Map<String, dynamic>>] The signed transaction, in message pack
/// format.
Future<Map<String, dynamic>> signTransaction({
  required SimpleKeyPair keyPair,
  required Uint8List transaction,
}) async {
  final publicKey = await keyPair.extractPublicKey();
  final signature = await Ed25519().sign(
    Uint8List.fromList([
      ...utf8.encode(TRANSACTION_PREFIX), // prefix the transaction bytes with "TX"
      ...transaction,
    ]),
    keyPair: keyPair,
  );

  return {
    'sgnr': Uint8List.fromList(publicKey.bytes),
    'sig': signature,
    'txn': transaction,
  };
}
