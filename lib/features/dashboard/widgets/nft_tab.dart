import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/common_widgets/custom_pull_to_refresh.dart';
import 'package:kibisis/common_widgets/custom_text_field.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/dashboard/providers/nft_filter_provider.dart';
import 'package:kibisis/features/dashboard/widgets/nft_grid.dart';
import 'package:kibisis/generated/l10n.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/nft_provider.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/theme_extensions.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

    _loadViewType();

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

  void _loadViewType() async {
    final prefs = await SharedPreferences.getInstance();
    final savedViewType = prefs.getString('nftViewType');

    if (savedViewType != null) {
      setState(() {
        viewType = savedViewType == NftViewType.grid.toString()
            ? NftViewType.grid
            : NftViewType.card;
      });
    }
  }

  void _onRefresh() async {
    ref.invalidate(nftNotifierProvider);
    final publicAddress = ref
        .read(accountProvider.select((state) => state.account?.address ?? ''));
    if (publicAddress.isNotEmpty) {
      await ref
          .read(nftNotifierProvider.notifier)
          .fetchNFTs(isInitialLoad: true, limit: 2);
    }
    _refreshController.refreshCompleted();
  }

  void _toggleNftView() async {
    setState(() {
      viewType =
          viewType == NftViewType.grid ? NftViewType.card : NftViewType.grid;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nftViewType', viewType.toString());
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
              controller: filterController,
              labelText: S.of(context).filter,
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
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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
            isFilterActive
                ? S.of(context).noNftsForFilter
                : S.of(context).noNftsFound,
            style: context.textTheme.titleSmall,
          ),
          const SizedBox(height: kScreenPadding / 2),
          Text(
            isFilterActive
                ? S.of(context).tryClearingFilter
                : S.of(context).noNftsAdded,
            style: context.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: kScreenPadding),
          TextButton(
            onPressed: isFilterActive
                ? () {
                    ref.read(nftNotifierProvider.notifier).setFilter('');
                    filterController.clear();
                  }
                : _onRefresh,
            child: Text(isFilterActive
                ? S.of(context).clearFilter
                : S.of(context).retry),
          ),
        ],
      ),
    );
  }
}
