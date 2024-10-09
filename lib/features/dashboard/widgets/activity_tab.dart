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
import 'package:shimmer/shimmer.dart';

class ActivityTab extends ConsumerStatefulWidget {
  const ActivityTab({super.key});

  @override
  ConsumerState<ActivityTab> createState() => _ActivityTabState();
}

class _ActivityTabState extends ConsumerState<ActivityTab> {
  static const _pageSize = 5;
  late final RefreshController _refreshController;
  final PagingController<String?, TransactionItem> _pagingController =
      PagingController(firstPageKey: null);
  String? _previousPublicAddress;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: false);
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void _onRefresh() {
    final publicAddress = ref.read(accountProvider).account?.address ?? '';
    ref.invalidate(transactionsProvider(publicAddress));
    _pagingController.refresh();
    _refreshController.refreshCompleted();
  }

  Future<void> _fetchPage(String? pageKey) async {
    try {
      final publicAddress = _previousPublicAddress ?? '';
      final result = await ref
          .read(transactionsProvider(publicAddress).notifier)
          .getPaginatedTransactions(pageKey, _pageSize);
      if (!mounted) return;
      final newItems = result.items;
      final nextPageKey = result.nextToken;

      final isLastPage = nextPageKey == null || newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final publicAddress = ref.watch(accountProvider).account?.address ?? '';
    if (_previousPublicAddress != publicAddress) {
      _previousPublicAddress = publicAddress;
      _pagingController.refresh();
    }

    final transactionsAsync = ref.watch(transactionsProvider(publicAddress));

    return CustomPullToRefresh(
      refreshController: _refreshController,
      onRefresh: _onRefresh,
      child: transactionsAsync.when(
        data: (transactions) => _buildTransactionList(),
        loading: () => _buildShimmerLoading(context),
        error: (error, _) => _buildCenteredMessage(
          context,
          title: 'Error loading transactions',
          subtitle: error.toString(),
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    return PagedListView<String?, TransactionItem>(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<TransactionItem>(
        itemBuilder: (context, item, index) => item,
        firstPageErrorIndicatorBuilder: (context) => _buildCenteredMessage(
          context,
          title: 'No Transactions Found',
          subtitle: 'You have not made any transactions.',
          showRetryButton: true,
        ),
        newPageErrorIndicatorBuilder: (context) =>
            _buildShimmerLoading(context),
        firstPageProgressIndicatorBuilder: (context) =>
            _buildShimmerLoading(context),
        newPageProgressIndicatorBuilder: (context) =>
            _buildShimmerLoading(context),
        noItemsFoundIndicatorBuilder: (context) => _buildCenteredMessage(
          context,
          title: 'No Transactions Found',
          subtitle: 'You have not made any transactions.',
          showRetryButton: true,
        ),
        noMoreItemsIndicatorBuilder: (context) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Center(
            child: Text(
              'No more transactions.',
              style: context.textTheme.bodyMedium,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenteredMessage(
    BuildContext context, {
    required String title,
    required String subtitle,
    bool showRetryButton = false,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: context.textTheme.titleSmall,
          ),
          const SizedBox(height: kScreenPadding / 2),
          Text(
            subtitle,
            style: context.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          if (showRetryButton) ...[
            const SizedBox(height: kScreenPadding),
            TextButton(
              onPressed: _onRefresh,
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.colorScheme.background,
      highlightColor: context.colorScheme.onSurfaceVariant,
      period: const Duration(milliseconds: 2000),
      child: Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: kScreenPadding / 2),
            child: ListTile(
              leading: const CircleAvatar(),
              title: Container(
                width: double.infinity,
                height: kScreenPadding,
                color: context.colorScheme.surface,
              ),
              subtitle: Container(
                width: double.infinity,
                height: kScreenPadding,
                color: context.colorScheme.surface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
