import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/features/dashboard/providers/transactions_provider.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:algorand_dart/algorand_dart.dart';

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
                final transactionDetails = _getTransactionDetails(transaction);
                return ListTile(
                  title: Text('Transaction ID: ${transaction.id}'),
                  subtitle: Text(transactionDetails),
                );
              },
              separatorBuilder: (context, index) => const Divider(),
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

  String _getTransactionDetails(Transaction transaction) {
    if (transaction.paymentTransaction != null) {
      return 'Amount: ${transaction.paymentTransaction!.amount} microAlgos';
    } else {
      return 'Transaction Type: ${transaction.type}';
    }
  }
}
