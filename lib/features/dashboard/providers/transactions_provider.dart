import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:algorand_dart/algorand_dart.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/algorand_provider.dart';
import 'package:kibisis/features/dashboard/widgets/transaction_item.dart';
import 'dart:convert';
import 'package:kibisis/providers/contacts_provider.dart';
import 'package:kibisis/utils/first_or_where_null.dart';

final transactionsProvider = StateNotifierProvider.family<TransactionsNotifier,
    AsyncValue<List<Transaction>>, String>(
  (ref, publicAddress) {
    return TransactionsNotifier(ref, publicAddress);
  },
);

class PaginatedTransactionItems {
  final List<TransactionItem> items;
  final String? nextToken;

  PaginatedTransactionItems({required this.items, required this.nextToken});
}

class TransactionsNotifier
    extends StateNotifier<AsyncValue<List<Transaction>>> {
  final Ref ref;
  final String publicAddress;

  TransactionsNotifier(this.ref, this.publicAddress)
      : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    await getTransactions(isInitial: true);
  }

  Future<void> getTransactions({bool isInitial = false}) async {
    if (publicAddress.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    try {
      if (isInitial) {
        state = const AsyncValue.loading();
      }

      final response = await ref.read(algorandServiceProvider).getTransactions(
            publicAddress,
            limit: 5,
          );

      final transactions = response.transactions;

      if (mounted) {
        state = AsyncValue.data(transactions);
      }
    } catch (e) {
      if (mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  Future<PaginatedTransactionItems> getPaginatedTransactions(
      String? pageKey, int limit) async {
    if (publicAddress.isEmpty) {
      return PaginatedTransactionItems(items: [], nextToken: null);
    }

    try {
      final response = await ref.read(algorandServiceProvider).getTransactions(
            publicAddress,
            limit: limit,
            nextToken: pageKey,
          );

      final nextToken = response.nextToken;
      final transactions = response.transactions;

      List<TransactionItem> transactionItems = [];

      final contacts = ref.read(contactsListProvider).contacts;

      for (final transaction in transactions) {
        TransactionDirection direction;

        if (transaction.type == 'pay' || transaction.type == 'axfer') {
          final sender = transaction.sender;
          final receiver =
              transaction.paymentTransaction?.receiver.toString() ??
                  transaction.assetTransferTransaction?.receiver.toString() ??
                  '';

          if (sender == publicAddress && receiver != publicAddress) {
            direction = TransactionDirection.outgoing;
          } else if (receiver == publicAddress && sender != publicAddress) {
            direction = TransactionDirection.incoming;
          } else {
            direction = TransactionDirection.unknown;
          }
        } else {
          direction = TransactionDirection.unknown;
        }

        final otherPartyAddress = direction == TransactionDirection.outgoing
            ? transaction.paymentTransaction?.receiver.toString() ??
                transaction.assetTransferTransaction?.receiver.toString() ??
                ''
            : transaction.sender;

        final contact = contacts.firstWhereOrNull(
            (contact) => contact.publicKey == otherPartyAddress);
        final displayAddress = contact?.name ?? otherPartyAddress;

        final note = utf8.decode(base64.decode(transaction.note ?? ''));
        final type = transaction.type;
        final amountInAlgos = transaction.paymentTransaction != null
            ? Algo.fromMicroAlgos(transaction.paymentTransaction!.amount)
            : 0.0;
        final assetId = transaction.assetTransferTransaction?.assetId;
        final assetAmount = transaction.assetTransferTransaction?.amount ?? 0;

        String? assetName;
        if (assetId != null) {
          final asset =
              await ref.read(algorandServiceProvider).getAssetById(assetId);
          assetName = asset.params.name;
        }

        transactionItems.add(TransactionItem(
          transaction: transaction,
          direction: direction,
          otherPartyAddress: displayAddress,
          amount: assetId != null
              ? assetAmount.toString()
              : amountInAlgos.toString(),
          note: note,
          type: type,
          assetName: assetName,
        ));
      }

      return PaginatedTransactionItems(
        items: transactionItems,
        nextToken: nextToken,
      );
    } catch (e) {
      return PaginatedTransactionItems(items: [], nextToken: null);
    }
  }

  void reset() {
    state = const AsyncValue.data([]);
  }
}
