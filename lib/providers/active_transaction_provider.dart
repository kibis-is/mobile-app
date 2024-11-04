import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:algorand_dart/algorand_dart.dart';

final activeTransactionProvider =
    StateNotifierProvider<ActiveTransactionNotifier, Transaction?>(
  (ref) => ActiveTransactionNotifier(),
);

class ActiveTransactionNotifier extends StateNotifier<Transaction?> {
  ActiveTransactionNotifier() : super(null);

  void setActiveTransaction(Transaction? transaction) {
    state = transaction;
  }
}
