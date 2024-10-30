import 'package:kibisis/constants/avm.dart';

class AvmMaxTransactionSizeException implements Exception {
  final String? message;
  final String name = 'AvmMaxTransactionSizeException';

  AvmMaxTransactionSizeException({this.message});

  @override
  String toString() {
    if (message != null) {
      return '$name: $message';
    }

    return '$name: transaction group size exceeds the maximum size of "$maxTransactionGroupSize"';
  }
}
