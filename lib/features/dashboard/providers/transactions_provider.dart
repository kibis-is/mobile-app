import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:algorand_dart/algorand_dart.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/algorand_provider.dart';
import 'package:kibisis/features/dashboard/widgets/transaction_item.dart';
import 'dart:convert';

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
  String? nextToken;

  TransactionsNotifier(this.ref, this.publicAddress)
      : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    await getTransactions(publicAddress, isInitial: true);
  }

  // Fetches initial transactions or more transactions for pagination
  Future<void> getTransactions(String publicAddress,
      {bool isInitial = false}) async {
    if (publicAddress.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    try {
      if (isInitial) {
        state = const AsyncValue.loading();
        nextToken = null; // Reset the nextToken for initial load
      }

      final response = await ref.read(algorandServiceProvider).getTransactions(
            publicAddress,
            limit: 5,
            nextToken: nextToken,
          );

      final transactions = response.transactions;

      if (mounted) {
        if (isInitial) {
          state = AsyncValue.data(transactions);
        } else {
          final currentState = state.value ?? [];
          state = AsyncValue.data([...currentState, ...transactions]);
        }

        nextToken = response.nextToken;
      }
    } catch (e) {
      if (mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  Future<List<TransactionItem>> getPaginatedTransactions(
      String publicAddress, int pageKey, int limit) async {
    if (publicAddress.isEmpty) return [];

    try {
      final response = await ref.read(algorandServiceProvider).getTransactions(
            publicAddress,
            limit: limit,
            nextToken: nextToken, // Use nextToken for pagination
          );

      // Update the nextToken for the next page
      nextToken = response.nextToken;

      final transactions = response.transactions;

      // Convert transactions to TransactionItems
      List<TransactionItem> transactionItems = [];

      for (final transaction in transactions) {
        final isOutgoing = transaction.sender == publicAddress;
        final otherPartyAddress = isOutgoing
            ? transaction.paymentTransaction?.receiver.toString() ?? ''
            : transaction.sender;

        final note = utf8.decode(base64.decode(transaction.note ?? ''));
        final type = transaction.type;
        final amountInAlgos = transaction.paymentTransaction != null
            ? Algo.fromMicroAlgos(transaction.paymentTransaction!.amount)
            : 0.0;
        final assetId = transaction.assetTransferTransaction?.assetId;
        final assetAmount = transaction.assetTransferTransaction?.amount ?? 0;

        // Resolve the asset name asynchronously if assetId is present
        String? assetName;
        if (assetId != null) {
          final asset =
              await ref.read(algorandServiceProvider).getAssetById(assetId);
          assetName = asset.params.name;
        }

        transactionItems.add(TransactionItem(
          transaction: transaction,
          isOutgoing: isOutgoing,
          otherPartyAddress: otherPartyAddress,
          amount: assetId != null
              ? assetAmount.toString()
              : amountInAlgos.toString(),
          note: note,
          type: type,
          assetName: assetName,
        ));
      }

      return transactionItems;
    } catch (e) {
      return [];
    }
  }

  void reset() {
    state = const AsyncValue.data([]);
    nextToken = null;
  }
}
