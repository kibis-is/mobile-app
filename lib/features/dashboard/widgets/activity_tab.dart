import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:kibisis/features/dashboard/providers/transactions_provider.dart';
import 'package:kibisis/features/dashboard/widgets/transaction_item.dart';
import 'package:kibisis/providers/account_provider.dart';

class ActivityTab extends ConsumerStatefulWidget {
  const ActivityTab({super.key});

  @override
  ConsumerState<ActivityTab> createState() => _ActivityTabState();
}

class _ActivityTabState extends ConsumerState<ActivityTab> {
  static const _pageSize = 5;

  // Change the page key type to String? to use nextToken
  final PagingController<String?, TransactionItem> _pagingController =
      PagingController(firstPageKey: null);

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PagedListView<String?, TransactionItem>(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<TransactionItem>(
        itemBuilder: (context, item, index) => item,
        firstPageErrorIndicatorBuilder: (context) => const Center(
          child: Text('Failed to load transactions. Please try again.'),
        ),
        newPageErrorIndicatorBuilder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
        firstPageProgressIndicatorBuilder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
