import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:kibisis/common_widgets/custom_pull_to_refresh.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/dashboard/providers/transactions_provider.dart';
import 'package:kibisis/features/dashboard/widgets/transaction_item.dart';
import 'package:kibisis/generated/l10n.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/active_transaction_provider.dart';
import 'package:kibisis/providers/storage_provider.dart';
import 'package:kibisis/routing/named_routes.dart';
import 'package:kibisis/utils/media_query_helper.dart';
import 'package:kibisis/utils/number_shortener.dart';
import 'package:kibisis/utils/theme_extensions.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';
import 'package:kibisis/features/view_transaction/view_transaction_screen.dart';

class ActivityTab extends ConsumerStatefulWidget {
  const ActivityTab({super.key});

  @override
  ConsumerState<ActivityTab> createState() => _ActivityTabState();
}

class _ActivityTabState extends ConsumerState<ActivityTab> {
  static const _pageSize = 5;
  late RefreshController _wideScreenRefreshController;
  late RefreshController _narrowScreenRefreshController;
  final PagingController<String?, TransactionItem> _pagingController =
      PagingController(firstPageKey: null);
  String? _previousPublicAddress;
  bool? _isWideScreen;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  void _initializeControllers() {
    _wideScreenRefreshController = RefreshController(initialRefresh: false);
    _narrowScreenRefreshController = RefreshController(initialRefresh: false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    if (_isWideScreen != isWideScreen) {
      _isWideScreen = isWideScreen;
      _disposeControllers();
      _initializeControllers();
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    _pagingController.dispose();
    super.dispose();
  }

  void _disposeControllers() {
    _wideScreenRefreshController.dispose();
    _narrowScreenRefreshController.dispose();
  }

  void _onRefresh() {
    final publicAddress = ref.read(accountProvider).account?.address ?? '';
    ref.invalidate(transactionsProvider(publicAddress));
    _pagingController.refresh();
    if (_isWideScreen == true) {
      _wideScreenRefreshController.refreshCompleted();
    } else {
      _narrowScreenRefreshController.refreshCompleted();
    }
  }

  Future<void> _fetchPage(String? pageKey) async {
    try {
      final publicAddress = _previousPublicAddress ?? '';
      final storageService = ref.read(storageProvider);

      if (pageKey == null) {
        final lastViewedTimestamp =
            await storageService.getTransactionLastViewedTime(publicAddress);
        final lastViewedTime =
            DateTime.fromMillisecondsSinceEpoch(lastViewedTimestamp);

        final result = await ref
            .read(transactionsProvider(publicAddress).notifier)
            .getPaginatedTransactions(pageKey, _pageSize);
        if (!mounted) return;

        final newItems = result.items.map((item) {
          final transactionTime = DateTime.fromMillisecondsSinceEpoch(
              (item.transaction.roundTime ?? 0) * 1000);

          final isNew = transactionTime.isAfter(lastViewedTime);
          return item.copyWith(isNew: isNew);
        }).toList();

        final nextPageKey = result.nextToken;
        final isLastPage = nextPageKey == null || newItems.length < _pageSize;

        if (isLastPage) {
          _pagingController.appendLastPage(newItems);
        } else {
          _pagingController.appendPage(newItems, nextPageKey);
        }

        await storageService.setTransactionLastViewedTime(
          publicAddress,
          DateTime.now().millisecondsSinceEpoch,
        );
      } else {
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
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryHelper = MediaQueryHelper(context);
    final publicAddress = ref.watch(accountProvider).account?.address ?? '';
    if (_previousPublicAddress != publicAddress) {
      _previousPublicAddress = publicAddress;
      _pagingController.refresh();
    }

    final transactionsAsync = ref.watch(transactionsProvider(publicAddress));

    if (mediaQueryHelper.isWideScreen()) {
      final activeTransaction = ref.watch(activeTransactionProvider);
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: mediaQueryHelper.getDynamicFlex()[0],
            child: CustomPullToRefresh(
              refreshController: _wideScreenRefreshController,
              onRefresh: _onRefresh,
              child: transactionsAsync.when(
                data: (transactions) => _buildTransactionList(),
                loading: () => _buildShimmerLoading(context),
                error: (error, _) => _buildCenteredMessage(
                  context,
                  title: S.of(context).errorLoadingTransactions,
                  subtitle: error.toString(),
                ),
              ),
            ),
          ),
          Expanded(
            flex: mediaQueryHelper.getDynamicFlex()[1],
            child: activeTransaction != null
                ? const ViewTransactionScreen(
                    isPanelMode: true,
                  )
                : Center(
                    child: Text(S.of(context).selectTransactionPrompt),
                  ),
          ),
        ],
      );
    } else {
      return CustomPullToRefresh(
        refreshController: _narrowScreenRefreshController,
        onRefresh: _onRefresh,
        child: transactionsAsync.when(
          data: (transactions) => _buildTransactionList(),
          loading: () => _buildShimmerLoading(context),
          error: (error, _) => _buildCenteredMessage(
            context,
            title: S.of(context).errorLoadingTransactions,
            subtitle: error.toString(),
          ),
        ),
      );
    }
  }

  Widget _buildTransactionList() {
    return PagedListView<String?, TransactionItem>(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<TransactionItem>(
        itemBuilder: (context, item, index) {
          final mediaQueryHelper = MediaQueryHelper(context);
          return TransactionItem(
            transaction: item.transaction,
            direction: item.direction,
            otherPartyAddress: item.otherPartyAddress,
            amount: item.amount != null && double.tryParse(item.amount!) != null
                ? NumberFormatter.shortenNumber(double.parse(item.amount!))
                : '0',
            note: item.note,
            type: item.type,
            isNew: item.isNew,
            assetName: item.assetName,
            onPressed: () {
              ref
                  .read(activeTransactionProvider.notifier)
                  .setActiveTransaction(item.transaction);
              if (!mediaQueryHelper.isWideScreen()) {
                context.pushNamed(viewTransactionRouteName);
              }
            },
          );
        },
        firstPageErrorIndicatorBuilder: (context) => _buildCenteredMessage(
          context,
          title: S.of(context).noTransactionsFound,
          subtitle: S.of(context).noTransactionsMade,
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
          title: S.of(context).noTransactionsFound,
          subtitle: S.of(context).noTransactionsMade,
          showRetryButton: true,
        ),
        noMoreItemsIndicatorBuilder: (context) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Center(
            child: Text(
              S.of(context).noMoreTransactions,
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
              child: Text(S.of(context).retry),
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
