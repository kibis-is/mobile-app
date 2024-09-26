import 'dart:typed_data';

/// Convenience function to calculate the new minimum balance requirement (MBR),
/// in atomic units, for an app's account for a given box. This is calculated
/// using the formula: 2500 + 400 * (key size + value size).
///
/// **Parameters:**
/// - [Uint8List] [key]: The key of the box.
/// - [Uint8List] [value]: The value of the box.
///
/// **Returns:**
/// [int] The MBR of the box.
int calculateBoxMBR(Uint8List key, Uint8List value) {
  int size = key.length + value.length;

  return 2500 + (400 * size);
}
