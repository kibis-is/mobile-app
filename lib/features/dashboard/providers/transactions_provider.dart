import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:algorand_dart/algorand_dart.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/algorand_provider.dart';

final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, AsyncValue<List<Transaction>>>(
  (ref) {
    final publicAddress =
        ref.watch(accountProvider).account?.publicAddress ?? '';
    return TransactionsNotifier(ref, publicAddress);
  },
);

class TransactionsNotifier
    extends StateNotifier<AsyncValue<List<Transaction>>> {
  final Ref ref;
  final String publicAddress; // This needs to be passed to the constructor

  TransactionsNotifier(this.ref, this.publicAddress)
      : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    await getTransactions(publicAddress);
  }

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
