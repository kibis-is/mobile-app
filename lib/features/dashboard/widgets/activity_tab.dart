import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:kibisis/common_widgets/custom_pull_to_refresh.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/dashboard/providers/transactions_provider.dart';
import 'package:kibisis/features/dashboard/widgets/transaction_item.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/utils/theme_extensions.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ActivityTab extends ConsumerStatefulWidget {
  const ActivityTab({super.key});

  @override
  ConsumerState<ActivityTab> createState() => _ActivityTabState();
}

class _ActivityTabState extends ConsumerState<ActivityTab> {
  static const _pageSize = 5;
  late final RefreshController _refreshController;
  // Change the page key type to String? to use nextToken
  final PagingController<String?, TransactionItem> _pagingController =
      PagingController(firstPageKey: null);

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: false);
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  void _onRefresh() {
    ref.invalidate(transactionsProvider);
    _pagingController.refresh();
    _refreshController.refreshCompleted();
  }

  Future<void> _fetchPage(String? pageKey) async {
    try {
      final publicAddress = ref.read(accountProvider).account?.address ?? '';

      // Fetch the items and the nextToken
      final result = await ref
          .read(transactionsProvider.notifier)
          .getPaginatedTransactions(publicAddress, pageKey, _pageSize);

      final newItems = result.items;
      final nextPageKey = result.nextToken;

      final isLastPage = nextPageKey == null || newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        // Use nextToken as the next page key
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPullToRefresh(
        refreshController: _refreshController,
        onRefresh: _onRefresh,
        child: PagedListView<String?, TransactionItem>(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<TransactionItem>(
            itemBuilder: (context, item, index) => item,
            firstPageErrorIndicatorBuilder: (context) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No Transactions Found',
                    style: context.textTheme.titleSmall,
                  ),
                  const SizedBox(height: kScreenPadding / 2),
                  Text(
                    'You have not made any transactions.',
                    style: context.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: kScreenPadding),
                  TextButton(
                    onPressed: _onRefresh,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            newPageErrorIndicatorBuilder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
            firstPageProgressIndicatorBuilder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
            // Add the missing empty list indicator
            noItemsFoundIndicatorBuilder: (context) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No Transactions Available',
                    style: context.textTheme.titleSmall,
                  ),
                  const SizedBox(height: kScreenPadding / 2),
                  Text(
                    'There are no items in your transaction history.',
                    style: context.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
