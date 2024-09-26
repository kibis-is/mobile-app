import 'package:kibisis/constants/avm.dart';

class AVMMaxTransactionSizeException implements Exception {
  final String? message;
  final String name = 'AVMMaxTransactionSizeException';

  AVMMaxTransactionSizeException({this.message});

  @override
  String toString() {
    if (message != null) {
      return '$name: $message';
    }

    return '$name: transaction group size exceeds the maximum size of "$MAX_TRANSACTION_GROUP_SIZE"';
  }
}
