import 'dart:typed_data';

/// Convenience function to calculate the new minimum balance requirement (MBR),
/// in microalgos, for an app's account for a given box. This is calculated
/// using the formula: 2500 + 400 * (key size + value size).
///
/// **Parameters:**
/// - [key]: The Uint8List key of the box.
/// - [value]: The Uint8List value of the box.
///
/// **Returns:**
/// A int representing the MBR of the box.
///
int calculateBoxMBR(Uint8List key, Uint8List value) {
  int size = key.length + value.length;

  return 2500 + (400 * size);
}
