import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:algorand_dart/algorand_dart.dart';
import 'package:kibisis/providers/algorand_provider.dart';

final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, AsyncValue<List<Transaction>>>(
  (ref) => TransactionsNotifier(ref),
);

class TransactionsNotifier
    extends StateNotifier<AsyncValue<List<Transaction>>> {
  final Ref ref;

  TransactionsNotifier(this.ref) : super(const AsyncValue.loading());

  Future<void> getTransactions(String publicAddress) async {
    if (publicAddress.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }
    try {
      final transactions = await ref
          .read(algorandServiceProvider)
          .getTransactions(publicAddress);
      if (mounted) {
        state = AsyncValue.data(transactions);
      }
    } catch (e) {
      if (mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }
}
