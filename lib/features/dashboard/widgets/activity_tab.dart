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
  static const _pageSize = 5; // Set page size as an integer
  final PagingController<int, TransactionItem> _pagingController =
      PagingController(firstPageKey: 0); // pageKey is an integer

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey); // Fetch the next page when needed
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final publicAddress =
          ref.read(accountProvider).account?.publicAddress ?? '';

      // Fetch the paginated transactions from the provider
      final newItems = await ref
          .read(transactionsProvider.notifier)
          .getPaginatedTransactions(publicAddress, pageKey,
              _pageSize); // Ensure the limit is an integer

      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length; // pageKey is an int
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void dispose() {
    _pagingController.dispose(); // Dispose the paging controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PagedListView<int, TransactionItem>(
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
