import 'dart:typed_data';

/// Converts a Uint8List (byte array) to a BigInt.
///
/// This function takes a byte array (Uint8List) and converts it into a BigInt
/// by reading each byte and combining them into a larger integer value.
///
/// **Parameters:**
/// - [Uint8List] [bytes]: The bytes to be converted to a BigInt.
///
/// **Returns:**
/// [BigInt] The bytes converted to a BigInt.
///
/// **Example:**
/// ```dart
/// Uint8List byteArray = Uint8List.fromList([0x01, 0x02, 0x03]);
/// BigInt result = bytesToBigInt(byteArray);
/// print(result); // Output: 66051
/// ```
BigInt bytesToBigInt(Uint8List bytes) {
  BigInt res = BigInt.zero;

  for (int i = 0; i < bytes.length; i++) {
    // read the byte and shift the result left by 8 bits (1 byte)
    res = (res * BigInt.from(256)) + BigInt.from(bytes[i]);
  }

  return res;
}
