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
  final String publicAddress;
  String? nextToken; // To store the nextToken for pagination

  TransactionsNotifier(this.ref, this.publicAddress)
      : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    await getTransactions(publicAddress, isInitial: true);
  }

  Future<void> getTransactions(String publicAddress,
      {bool isInitial = false}) async {
    if (publicAddress.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }
    try {
      if (isInitial) {
        // Reset state and token for initial load
        state = const AsyncValue.loading();
        nextToken = null;
      }

      final response = await ref
          .read(algorandServiceProvider)
          .getTransactions(publicAddress, limit: 5);

      final transactions = response.transactions;

      if (mounted) {
        if (isInitial) {
          state = AsyncValue.data(transactions);
        } else {
          final currentState = state.value ?? [];
          // Append the new transactions to the current state
          state = AsyncValue.data([...currentState, ...transactions]);
        }
        nextToken = response.nextToken; // Update the nextToken for pagination
      }
    } catch (e) {
      if (mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  void reset() {
    state = const AsyncValue.data([]);
    nextToken = null; // Reset pagination when resetting
  }
}
