import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:algorand_dart/algorand_dart.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/models/contact.dart';
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
  String? _nextToken;
  bool _isLoading = false;

  TransactionsNotifier(this.ref, this.publicAddress)
      : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    _nextToken = null;
    await getTransactions(isInitial: true);
  }

  Future<void> getTransactions({bool isInitial = false}) async {
    if (publicAddress.isEmpty || _isLoading) return;

    try {
      _isLoading = true;
      if (isInitial) {
        _nextToken = null;
        state = const AsyncValue.loading();
      }

      final response = await ref.read(algorandServiceProvider).getTransactions(
            publicAddress,
            limit: 10,
            nextToken: _nextToken,
          );

      _nextToken = response.nextToken;
      final newTransactions = response.transactions;

      final currentTransactions = state.value ?? [];
      final uniqueTransactions = [
        ...currentTransactions,
        ...newTransactions.where((t) => !currentTransactions.contains(t)),
      ];

      if (mounted) {
        state = AsyncValue.data(uniqueTransactions);
      }
    } catch (e) {
      if (mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    } finally {
      _isLoading = false;
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

      final contacts = ref.read(contactsListProvider).contacts;
      final transactionItems =
          await _buildTransactionItems(response.transactions, contacts);

      return PaginatedTransactionItems(
        items: transactionItems,
        nextToken: response.nextToken,
      );
    } catch (_) {
      return PaginatedTransactionItems(items: [], nextToken: null);
    }
  }

  Future<List<TransactionItem>> _buildTransactionItems(
      List<Transaction> transactions, List<Contact> contacts) async {
    List<TransactionItem> transactionItems = [];

    for (final transaction in transactions) {
      final direction = _getTransactionDirection(transaction);
      final otherPartyAddress = _getOtherPartyAddress(transaction, direction);
      final displayAddress = _getDisplayAddress(contacts, otherPartyAddress);

      final note = utf8.decode(base64.decode(transaction.note ?? ''));
      final amount = _getTransactionAmount(transaction);
      final assetName = await _getAssetName(transaction);

      transactionItems.add(TransactionItem(
        transaction: transaction,
        direction: direction,
        otherPartyAddress: displayAddress,
        amount: amount,
        note: note,
        type: transaction.type,
        assetName: assetName,
      ));
    }

    return transactionItems;
  }

  TransactionDirection _getTransactionDirection(Transaction transaction) {
    if (transaction.type == 'pay' || transaction.type == 'axfer') {
      final sender = transaction.sender.toLowerCase();
      final receiver = transaction.paymentTransaction?.receiver.toLowerCase() ??
          transaction.assetTransferTransaction?.receiver.toLowerCase() ??
          '';

      if (sender.isEmpty || receiver.isEmpty) {
        debugPrint('Transaction missing sender or receiver: $transaction');
        return TransactionDirection.unknown;
      }

      if (sender == publicAddress.toLowerCase() &&
          receiver != publicAddress.toLowerCase()) {
        return TransactionDirection.outgoing;
      } else if (receiver == publicAddress.toLowerCase() &&
          sender != publicAddress.toLowerCase()) {
        return TransactionDirection.incoming;
      }
    } else {
      debugPrint('Unhandled transaction type: ${transaction.type}');
    }

    debugPrint('Unknown transaction direction for transaction: $transaction');
    return TransactionDirection.unknown;
  }

  String _getOtherPartyAddress(
      Transaction transaction, TransactionDirection direction) {
    return direction == TransactionDirection.outgoing
        ? transaction.paymentTransaction?.receiver.toString() ??
            transaction.assetTransferTransaction?.receiver.toString() ??
            ''
        : transaction.sender;
  }

  String _getDisplayAddress(List<Contact> contacts, String address) {
    return contacts
            .firstWhereOrNull((contact) => contact.publicKey == address)
            ?.name ??
        address;
  }

  String _getTransactionAmount(Transaction transaction) {
    if (transaction.assetTransferTransaction != null) {
      final assetAmount = transaction.assetTransferTransaction!.amount;
      final assetAmountMicro = Algo.fromMicroAlgos(assetAmount);
      debugPrint('Asset transfer amount: $assetAmount');
      return assetAmountMicro.toString();
    } else {
      final microAlgoAmount = transaction.paymentTransaction?.amount ?? 0;
      final algoAmount = Algo.fromMicroAlgos(microAlgoAmount);
      debugPrint('MicroAlgo amount: $microAlgoAmount');
      debugPrint('Algo amount: $algoAmount');
      return algoAmount.toString();
    }
  }

  Future<String?> _getAssetName(Transaction transaction) async {
    final assetId = transaction.assetTransferTransaction?.assetId;
    if (assetId != null) {
      final asset =
          await ref.read(algorandServiceProvider).getAssetById(assetId);
      return asset.params.name;
    }
    return null;
  }

  void reset() {
    _nextToken = null;
    _isLoading = false;
    state = const AsyncValue.data([]);
  }
}
