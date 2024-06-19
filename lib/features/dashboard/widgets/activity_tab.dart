import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/dashboard/providers/transactions_provider.dart';
import 'package:kibisis/features/dashboard/widgets/transaction_item.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:algorand_dart/algorand_dart.dart';
import 'package:kibisis/utils/theme_extensions.dart';
import 'package:shimmer/shimmer.dart';

class ActivityTab extends ConsumerWidget {
  const ActivityTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publicAddress = ref.watch(accountProvider
        .select((account) => account.account?.publicAddress ?? ''));
    final transactionsAsyncValue = ref.watch(transactionsProvider);

    return transactionsAsyncValue.when(
      data: (transactions) {
        if (transactions.isEmpty) {
          return _buildEmptyTransactions(context);
        }
        return _buildTransactionsList(
            context, ref, transactions, publicAddress);
      },
      loading: () => _buildLoadingTransactions(context),
      error: (error, stack) =>
          const Center(child: Text('Failed to load transactions')),
    );
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

  Widget _buildLoadingTransactions(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.colorScheme.background,
      highlightColor: Colors.grey.shade100,
      period: const Duration(milliseconds: 2000),
      child: ListView.separated(
        itemCount: 3,
        itemBuilder: (context, index) => ListTile(
          leading: const CircleAvatar(),
          title: Container(
              width: double.infinity,
              height: kScreenPadding,
              color: context.colorScheme.surface),
          subtitle: Container(
              width: double.infinity,
              height: kScreenPadding,
              color: context.colorScheme.surface),
        ),
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(height: kScreenPadding / 2);
        },
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
        final note = utf8.decode(base64.decode(transaction.note ?? ''));

        return TransactionItem(
          transaction: transaction,
          isOutgoing: isOutgoing,
          otherPartyAddress: otherPartyAddress,
          amountInAlgos: amountInAlgos,
          note: note,
        );
      },
      separatorBuilder: (context, index) => const SizedBox(
        height: kScreenPadding / 2,
      ),
    );
  }
}
