import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/dashboard/providers/transactions_provider.dart';
import 'package:kibisis/features/dashboard/widgets/transaction_item.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:algorand_dart/algorand_dart.dart';
import 'package:kibisis/utils/theme_extensions.dart';

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
              return _buildEmptyTransactions(context);
            }
            return _buildTransactionsList(
                context, ref, transactions, publicAddress);
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

  Widget _buildEmptyTransactions(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width / 4,
              maxHeight: MediaQuery.of(context).size.height / 4,
            ),
            child: SvgPicture.asset(
              'assets/images/empty.svg',
              semanticsLabel: 'No Transactions Found',
            ),
          ),
          const SizedBox(height: kScreenPadding / 2),
          Text('No Transactions Found', style: context.textTheme.titleMedium),
          const SizedBox(height: kScreenPadding / 2),
          Text('You have not made any transactions. Try making one now.',
              style: context.textTheme.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: kScreenPadding),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(BuildContext context, WidgetRef ref,
      List<Transaction> transactions, String publicAddress) {
    return ListView.separated(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final isOutgoing = transaction.sender == publicAddress;
        final otherPartyAddress = isOutgoing
            ? transaction.paymentTransaction?.receiver.toString() ?? ''
            : transaction.sender;
        final amountInAlgos = transaction.paymentTransaction != null
            ? Algo.fromMicroAlgos(transaction.paymentTransaction!.amount)
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
  }
}
