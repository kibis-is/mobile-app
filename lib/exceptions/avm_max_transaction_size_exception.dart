import 'package:kibisis/constants/avm.dart';
import 'package:kibisis/generated/l10n.dart'; // Import localization

class AvmMaxTransactionSizeException implements Exception {
  final String? message;
  final String name = 'AvmMaxTransactionSizeException';

  AvmMaxTransactionSizeException({this.message});

  @override
  String toString() {
    if (message != null) {
      return '$name: $message';
    }

    return '$name: ${S.current.transactionGroupSizeExceeded(maxTransactionGroupSize)}';
  }
}
