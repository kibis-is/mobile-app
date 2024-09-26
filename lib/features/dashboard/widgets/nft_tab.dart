import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/common_widgets/custom_pull_to_refresh.dart';
import 'package:kibisis/common_widgets/custom_text_field.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/dashboard/providers/nft_filter_provider.dart';
import 'package:kibisis/features/dashboard/widgets/nft_grid.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/nft_provider.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/theme_extensions.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

class NftTab extends ConsumerStatefulWidget {
  const NftTab({super.key});

  @override
  NftTabState createState() => NftTabState();
}

class NftTabState extends ConsumerState<NftTab> {
  late final RefreshController _refreshController;
  late TextEditingController filterController;
  NftViewType viewType = NftViewType.grid;
  final ScrollController _scrollController = ScrollController();
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: false);
    filterController = TextEditingController(
      text: ref.read(nftNotifierProvider.notifier).filterText,
    );
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !isLoadingMore) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          ref.read(nftNotifierProvider.notifier).loadMoreNFTs(limit: 2);
        });
      }
    });
  }

  void _onRefresh() async {
    ref.invalidate(nftNotifierProvider);
    final publicAddress = ref.read(
        accountProvider.select((state) => state.account?.publicAddress ?? ''));
    if (publicAddress.isNotEmpty) {
      await ref
          .read(nftNotifierProvider.notifier)
          .fetchNFTs(isInitialLoad: true, limit: 2);
    }
    _refreshController.refreshCompleted();
  }

  void _toggleNftView() {
    setState(() {
      viewType =
          viewType == NftViewType.grid ? NftViewType.card : NftViewType.card;
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    filterController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nftState = ref.watch(nftNotifierProvider);
    ref.watch(nftFilterControllerProvider);

    return Column(
      children: [
        const SizedBox(height: kScreenPadding / 2),
        _buildSearchBar(),
        const SizedBox(height: kScreenPadding / 4),
        Expanded(
          child: CustomPullToRefresh(
            refreshController: _refreshController,
            onRefresh: _onRefresh,
            child: nftState.when(
              data: (nfts) => nfts.isEmpty
                  ? _buildEmptyNfts()
                  : NftGridOrCard(
                      nfts: nfts,
                      viewType: viewType,
                      controller: _scrollController,
                    ),
              loading: () => _buildLoadingNfts(),
              error: (error, stack) => _buildEmptyNfts(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kScreenPadding / 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            color: context.colorScheme.surface,
            onPressed: _toggleNftView,
            icon: Icon(
              viewType == NftViewType.grid ? AppIcons.card : AppIcons.grid,
              color: context.colorScheme.onBackground,
              size: AppIcons.medium,
            ),
          ),
          Expanded(
            child: CustomTextField(
              controller: filterController, // Use the member variable
              labelText: 'Filter',
              onChanged: (value) {
                ref.read(nftNotifierProvider.notifier).setFilter(value);
              },
              autoCorrect: false,
              suffixIcon:
                  filterController.text.isNotEmpty ? AppIcons.cross : null,
              leadingIcon: AppIcons.search,
              onTrailingPressed: () {
                filterController.clear();
                ref.read(nftNotifierProvider.notifier).setFilter('');
              },
              isSmall: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingNfts() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: viewType == NftViewType.grid ? 3 : 1,
        childAspectRatio: 1.0,
      ),
      itemCount: 12,
      shrinkWrap: true, // Prevents unbounded height error
      physics: const NeverScrollableScrollPhysics(), // Parent handles scrolling
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: context.colorScheme.surface,
        highlightColor: context.colorScheme.onSurfaceVariant,
        child: Container(
          color: context.colorScheme.surface,
        ),
      ),
    );
  }

  Widget _buildEmptyNfts() {
    final isFilterActive =
        ref.read(nftNotifierProvider.notifier).filterText.isNotEmpty;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isFilterActive ? 'No NFTs Found for the Filter' : 'No NFTs Found',
            style: context.textTheme.titleSmall,
          ),
          const SizedBox(height: kScreenPadding / 2),
          Text(
            isFilterActive
                ? 'Try clearing the filter to see all NFTs.'
                : 'You have not added any NFTs.',
            style: context.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: kScreenPadding),
          TextButton(
            onPressed: isFilterActive
                ? () {
                    // Clear the filter when the button is pressed
                    ref.read(nftNotifierProvider.notifier).setFilter('');
                    filterController.clear(); // Also clear the text field
                  }
                : _onRefresh, // Retry the API call if there's no filter
            child: Text(isFilterActive ? 'Clear Filter' : 'Retry'),
          ),
        ],
      ),
    );
  }
}
