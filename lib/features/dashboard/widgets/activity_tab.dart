import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/dashboard/providers/transactions_provider.dart';
import 'package:kibisis/features/dashboard/widgets/transaction_item.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:algorand_dart/algorand_dart.dart';

class ExpandedTransactionState extends StateNotifier<Map<int, bool>> {
  ExpandedTransactionState() : super({});

  void toggleExpanded(int index) {
    state = {
      ...state,
      index: !(state[index] ?? false),
    };
  }
}

final expandedTransactionProvider =
    StateNotifierProvider<ExpandedTransactionState, Map<int, bool>>(
  (ref) => ExpandedTransactionState(),
);

class ActivityTab extends ConsumerWidget {
  const ActivityTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<String>(
      future: _getPublicAddress(ref),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Failed to load public address'));
        }
        final publicAddress = snapshot.data!;
        final transactionsAsyncValue =
            ref.watch(transactionsProvider(publicAddress));

        return transactionsAsyncValue.when(
          data: (transactions) {
            if (transactions.isEmpty) {
              return const Center(
                child: Text('No Transactions Found'),
              );
            }
            return ListView.separated(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                final isOutgoing = transaction.sender == publicAddress;
                final otherPartyAddress = isOutgoing
                    ? transaction.paymentTransaction?.receiver.toString() ?? ''
                    : transaction.sender;
                final amountInAlgos = transaction.paymentTransaction != null
                    ? Algo.fromMicroAlgos(
                        transaction.paymentTransaction!.amount)
                    : 0.0;

                return TransactionItem(
                  transaction: transaction,
                  isOutgoing: isOutgoing,
                  otherPartyAddress: otherPartyAddress,
                  amountInAlgos: amountInAlgos,
                );
              },
              separatorBuilder: (context, index) => const SizedBox(
                height: kScreenPadding / 2,
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) =>
              const Center(child: Text('Failed to load transactions')),
        );
      },
    );
  }

  Future<String> _getPublicAddress(WidgetRef ref) async {
    return await ref.watch(accountProvider.notifier).getPublicAddress();
  }
}
