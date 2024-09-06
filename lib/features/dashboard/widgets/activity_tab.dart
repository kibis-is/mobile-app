import 'dart:convert'; // Required for decoding notes
import 'package:algorand_dart/algorand_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/common_widgets/custom_pull_to_refresh.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/dashboard/providers/transactions_provider.dart';
import 'package:kibisis/features/dashboard/widgets/transaction_item.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/algorand_provider.dart';
import 'package:kibisis/utils/theme_extensions.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

class ActivityTab extends ConsumerStatefulWidget {
  const ActivityTab({super.key});

  @override
  ConsumerState<ActivityTab> createState() => _ActivityTabState();
}

class _ActivityTabState extends ConsumerState<ActivityTab> {
  late final RefreshController _refreshController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: false);
  }

  void _onRefresh() async {
    ref.invalidate(transactionsProvider);
    final publicAddress =
        ref.read(accountProvider).account?.publicAddress ?? '';
    await ref
        .read(transactionsProvider.notifier)
        .getTransactions(publicAddress);
    _refreshController.refreshCompleted();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsyncValue = ref.watch(transactionsProvider);

    return Column(
      children: [
        const SizedBox(height: kScreenPadding / 4),
        Expanded(
          child: CustomPullToRefresh(
            refreshController: _refreshController,
            onRefresh: _onRefresh,
            child: transactionsAsyncValue.when(
              data: (transactions) {
                if (transactions.isEmpty) {
                  return _buildEmptyTransactions(context, ref);
                }
                return _buildTransactionsList(context, ref, transactions);
              },
              loading: () => _buildLoadingTransactions(context),
              error: (error, stack) => _buildEmptyTransactions(context, ref),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyTransactions(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('No Transactions Found', style: context.textTheme.titleSmall),
          const SizedBox(height: kScreenPadding / 2),
          Text('You have not made any transactions.',
              style: context.textTheme.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: kScreenPadding),
          TextButton(
            onPressed: () {
              _onRefresh();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingTransactions(BuildContext context) {
    return ListView.builder(
      itemCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: context.colorScheme.background,
        highlightColor: Colors.grey.shade100,
        child: ListTile(
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
            assetName: 'App Interaction',
          ));
          break;

        default:
          debugPrint('Unknown transaction type: $type');
          break;
      }
    }

    return transactionItems;
  }

  Widget _buildTransactionsList(
      BuildContext context, WidgetRef ref, List<Transaction> transactions) {
    final publicAddress =
        ref.read(accountProvider).account?.publicAddress ?? '';

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
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  snapshot.data![index],
                ],
              );
            },
          );
        }
      },
    );
  }
}
