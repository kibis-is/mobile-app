import 'dart:convert';
import 'dart:typed_data';

import 'package:algorand_dart/algorand_dart.dart';
import 'package:crypto/crypto.dart';
import 'package:kibisis/constants/avm.dart';
import 'package:kibisis/exceptions/avm_max_transaction_size_exception.dart';

/// Convenience function to compute the group ID of a list of a group of atomic
/// transactions.
///
/// The transaction IDs for the each transaction are calculated, then
/// the group ID is calculated by encoding the list of transaction IDs in a
/// message pack structure:
/// ```
/// {
///   "txlist": [[9, 9, 0...], [7, 8, 9..]..],
/// }
/// ```
///
/// The returning bytes are the concatenation of the bytes of the "TG" prefix
/// with the created "txlist" message pack.
///
/// **Parameters:**
/// - [List<Map<String, dynamic>>] [transactions]: The message pack encoded
/// transactions.
///
/// **Returns:**
/// [Uint8List?] The computed ID or null if the list is empty.
///
/// **Throws:**
/// [AVMMaxTransactionSizeException] If the list of transactions exceeds the transaction group limit of 16.
Uint8List? computeGroupID(List<Map<String, dynamic>> transactions) {
  List<Uint8List> transactionIDBytes;

  if (transactions.isEmpty) {
    return null;
  }

  if (transactions.length > maxTransactionGroupSize) {
    throw AvmMaxTransactionSizeException();
  }

  // compute the the transaction ids
  transactionIDBytes = transactions
      .map((value) => Uint8List.fromList(
          sha512256.convert(Encoder.encodeMessagePack(value)).bytes))
      .toList();

  return Uint8List.fromList(sha512256.convert([
    ...utf8.encode(transactionGroupPrefix), // add the "TG" prefix as bytes
    ...Encoder.encodeMessagePack({
      'txlist': transactionIDBytes,
    })
  ]).bytes);
}
