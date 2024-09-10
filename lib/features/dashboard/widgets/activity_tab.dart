import 'dart:convert';
import 'package:algorand_dart/algorand_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: false);

    // Listen for when the user scrolls to the bottom to load more transactions
    _scrollController.addListener(() {
      if (_scrollController.position.extentAfter == 0 && !isLoadingMore) {
        _loadMoreTransactions();
      }
    });
  }

  Future<void> _onRefresh() async {
    ref.invalidate(transactionsProvider); // Invalidate the provider to refresh
    final publicAddress =
        ref.read(accountProvider).account?.publicAddress ?? '';
    await ref
        .read(transactionsProvider.notifier)
        .getTransactions(publicAddress, isInitial: true);
    _refreshController.refreshCompleted();
  }

  Future<void> _loadMoreTransactions() async {
    final transactionsNotifier = ref.read(transactionsProvider.notifier);

    if (transactionsNotifier.nextToken != null && !isLoadingMore) {
      setState(() {
        isLoadingMore = true;
      });

      final publicAddress =
          ref.read(accountProvider).account?.publicAddress ?? '';
      await transactionsNotifier.getTransactions(publicAddress);

      setState(() {
        isLoadingMore = false;
      });
    }
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
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (_scrollController.hasClients &&
                  scrollNotification.metrics.pixels >=
                      scrollNotification.metrics.maxScrollExtent -
                          100 && // Near bottom of the list
                  scrollNotification.metrics.axisDirection ==
                      AxisDirection.down && // Ensure scrolling down
                  !isLoadingMore) {
                // Ensure _loadMoreTransactions() is called after the current frame
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  _loadMoreTransactions();
                });
              }
              return false; // Allow other listeners to handle the event
            },
            child: CustomPullToRefresh(
              refreshController: _refreshController,
              onRefresh: _onRefresh,
              child: transactionsAsyncValue.when(
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return _buildEmptyTransactions(context, ref);
                  }
                  return _buildTransactionsList(
                      context, ref, transactions); // Display the list
                },
                loading: () =>
                    _buildLoadingShimmer(context), // Shimmer for initial load
                error: (error, stack) => _buildEmptyTransactions(context, ref),
              ),
            ),
          ),
        ),
        if (isLoadingMore)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  Widget _buildTransactionsList(
      BuildContext context, WidgetRef ref, List<Transaction> transactions) {
    final publicAddress =
        ref.read(accountProvider).account?.publicAddress ?? '';

    return FutureBuilder<List<TransactionItem>>(
      future: _buildTransactionItems(transactions, publicAddress, ref),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            transactions.isEmpty) {
          // Show shimmer only if no items have been loaded yet
          return _buildLoadingShimmer(context);
        } else if (snapshot.hasError) {
          return const Center(
              child: Text('Failed to load transaction details'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyTransactions(context, ref);
        } else {
          return ListView.builder(
            controller: _scrollController,
            shrinkWrap: true,
            itemCount: snapshot.data!.length +
                (isLoadingMore ? 3 : 0), // Add 3 for shimmer items
            itemBuilder: (context, index) {
              if (index < snapshot.data!.length) {
                return Column(
                  children: [
                    snapshot.data![index],
                  ],
                );
              } else {
                // Show shimmer for the newly loading items
                return Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: ListTile(
                    leading: const CircleAvatar(),
                    title: Container(
                      width: double.infinity,
                      height: 16.0,
                      color: Colors.white,
                    ),
                    subtitle: Container(
                      width: double.infinity,
                      height: 16.0,
                      color: Colors.white,
                    ),
                  ),
                );
              }
            },
          );
        }
      },
    );
  }

  Widget _buildLoadingShimmer(BuildContext context) {
    return ListView.builder(
      itemCount: 3, // Number of shimmer placeholders
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: ListTile(
            leading: const CircleAvatar(),
            title: Container(
              width: double.infinity,
              height: 16.0,
              color: Colors.white,
            ),
            subtitle: Container(
              width: double.infinity,
              height: 16.0,
              color: Colors.white,
            ),
          ),
        );
      },
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
}
