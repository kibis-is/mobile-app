import 'dart:convert';

import 'package:algorand_dart/algorand_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kibisis/common_widgets/custom_pull_to_refresh.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/dashboard/providers/transactions_provider.dart';
import 'package:kibisis/features/dashboard/widgets/transaction_item.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/algorand_provider.dart';
import 'package:kibisis/utils/refresh_account_data.dart';
import 'package:kibisis/utils/theme_extensions.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

class ActivityTab extends ConsumerWidget {
  const ActivityTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final RefreshController refreshController =
        RefreshController(initialRefresh: false);

    final publicAddress = ref.watch(accountProvider
        .select((account) => account.account?.publicAddress ?? ''));
    final transactionsAsyncValue = ref.watch(transactionsProvider);

    return CustomPullToRefresh(
      refreshController: refreshController,
      onRefresh: () async {
        await ref
            .read(transactionsProvider.notifier)
            .getTransactions(publicAddress);
        refreshController.refreshCompleted();
      },
      child: transactionsAsyncValue.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return _buildEmptyTransactions(context, ref);
          }
          return _buildTransactionsList(
              context, ref, transactions, publicAddress);
        },
        loading: () => _buildLoadingTransactions(context),
        error: (error, stack) => _buildEmptyTransactions(context, ref),
      ),
    );
  }

  Widget _buildEmptyTransactions(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: SvgPicture.asset('assets/images/empty.svg',
                semanticsLabel: 'No Assets Found'),
          ),
          const SizedBox(height: kScreenPadding / 2),
          Text('No Transactions Found', style: context.textTheme.titleMedium),
          const SizedBox(height: kScreenPadding / 2),
          Text(
            'You have not made any transactions.',
            style: context.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: kScreenPadding),
          TextButton(
            onPressed: () {
              invalidateProviders(ref);
            },
            child: const Text('Retry'),
          ),
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

  Future<List<TransactionItem>> _buildTransactionItems(
      List<Transaction> transactions,
      String publicAddress,
      WidgetRef ref) async {
    final transactionItems = <TransactionItem>[];

    for (final transaction in transactions) {
      final isOutgoing = transaction.sender == publicAddress;
      final otherPartyAddress = isOutgoing
          ? transaction.paymentTransaction?.receiver.toString() ?? ''
          : transaction.sender;
      final amountInAlgos = transaction.paymentTransaction != null
          ? Algo.fromMicroAlgos(transaction.paymentTransaction!.amount)
          : 0.0;
      final note = utf8.decode(base64.decode(transaction.note ?? ''));
      final type = transaction.type;
      final assetId = transaction.assetTransferTransaction?.assetId;
      final assetAmount = transaction.assetTransferTransaction?.amount ?? 0;
      final otherPartyAddressAsset =
          transaction.assetTransferTransaction?.receiver ?? 'Unknown';

      switch (type) {
        case 'axfer':
          final asset = await ref
              .read(algorandServiceProvider)
              .getAssetById(assetId ?? -1);
          transactionItems.add(TransactionItem(
            transaction: transaction,
            isOutgoing: isOutgoing,
            otherPartyAddress: otherPartyAddressAsset,
            note: note,
            amount: assetAmount.toString(),
            type: type,
            assetName: asset.params.name ?? '',
          ));
          break;

        case 'pay':
          transactionItems.add(TransactionItem(
            transaction: transaction,
            isOutgoing: isOutgoing,
            otherPartyAddress: otherPartyAddress,
            amount: amountInAlgos.toString(),
            note: note,
            type: type,
          ));
          break;

        case 'appl':
          transactionItems.add(TransactionItem(
            transaction: transaction,
            isOutgoing: isOutgoing,
            otherPartyAddress: otherPartyAddress,
            amount: isOutgoing ? 'Outgoing' : 'Incoming',
            note: note,
            type: type,
            assetName: 'App Call',
          ));
          break;

        default:
          debugPrint('Unknown transaction type: $type');
          break;
      }
    }

    return transactionItems;
  }

  Widget _buildTransactionsList(BuildContext context, WidgetRef ref,
      List<Transaction> transactions, String publicAddress) {
    return FutureBuilder<List<TransactionItem>>(
      future: _buildTransactionItems(transactions, publicAddress, ref),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingTransactions(context);
        } else if (snapshot.hasError) {
          return const Center(
              child: Text('Failed to load transaction details'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyTransactions(context, ref);
        } else {
          return ListView.separated(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return snapshot.data![index];
            },
            separatorBuilder: (context, index) => const SizedBox(
              height: kScreenPadding / 2,
            ),
          );
        }
      },
    );
  }
}
