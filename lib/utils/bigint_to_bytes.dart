import 'dart:typed_data';

/// Converts a BigInt into a byte array (Uint8List) of a specified size.
///
/// This function takes a BigInt and converts it to a hexadecimal string representation.
/// It then pads the string to ensure it matches the desired byte size and converts
/// the hexadecimal string into a Uint8List.
///
/// **Parameters:**
/// - [value]: The BigInt to be converted to bytes.
/// - [size]: The desired size of the output byte array in bytes.
///
/// **Returns:**
/// A Uint8List representing the byte array corresponding to the given BigInt.
///
/// **Example:**
/// ```dart
/// BigInt value = BigInt.from(123456789);
/// int size = 4; // For a 4-byte representation
/// Uint8List byteArray = bigIntToBytes(value, size);
/// print(byteArray); // Output: [7, 91, 205, 21]
/// ```
Uint8List bigIntToBytes(BigInt value, int size) {
  String hex = value.toRadixString(16);

  // pad the hex with zeros so it matches the size in bytes
  if (hex.length != size * 2) {
    hex = hex.padLeft(size * 2, '0');
  }

  // create a uint8list to hold the byte array
  final byteArray = Uint8List(hex.length ~/ 2);

  // fill the byte array
  for (int i = 0, j = 0; i < byteArray.length; i++, j += 2) {
    byteArray[i] = int.parse(hex.substring(j, j + 2), radix: 16);
  }

  return byteArray;
}
