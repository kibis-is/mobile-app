import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/common_widgets/custom_pull_to_refresh.dart';
import 'package:kibisis/common_widgets/custom_text_field.dart';
import 'package:kibisis/constants/constants.dart';
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
  final TextEditingController filterController = TextEditingController();
  NftViewType viewType = NftViewType.grid;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: false);
  }

  void _onRefresh() async {
    ref.invalidate(nftNotifierProvider);
    final publicAddress = ref.read(
        accountProvider.select((state) => state.account?.publicAddress ?? ''));
    if (publicAddress.isNotEmpty) {
      await ref.read(nftNotifierProvider.notifier).fetchNFTs();
    }
    _refreshController.refreshCompleted();
  }

  void _toggleNftView() {
    setState(() {
      viewType =
          viewType == NftViewType.grid ? NftViewType.card : NftViewType.grid;
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nftState = ref.watch(nftNotifierProvider);

    return Column(
      children: [
        _buildSearchBar(context),
        const SizedBox(height: kScreenPadding / 4),
        Expanded(
          child: CustomPullToRefresh(
            refreshController: _refreshController,
            onRefresh: _onRefresh,
            child: CustomScrollView(
              slivers: [
                nftState.when(
                  data: (nfts) => nfts.isEmpty
                      ? _buildEmptyNfts(context)
                      : NftGridOrCard(nfts: nfts, viewType: viewType),
                  loading: () => _buildLoadingNfts(context),
                  error: (error, stack) => _buildEmptyNfts(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Row(
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
        const SizedBox(width: kScreenPadding / 2),
        Expanded(
          child: CustomTextField(
            controller: filterController,
            labelText: 'Filter',
            onChanged: (value) {
              ref.read(nftNotifierProvider.notifier).setFilter(value);
            },
            autoCorrect: false,
            suffixIcon: AppIcons.cross,
            leadingIcon: AppIcons.search,
            onTrailingPressed: () => filterController.clear(),
            isSmall: true,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingNfts(BuildContext context) {
    return SliverToBoxAdapter(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: viewType == NftViewType.grid ? 3 : 1,
          childAspectRatio: 1.0,
          mainAxisSpacing: kScreenPadding / 2,
          crossAxisSpacing: kScreenPadding / 2,
        ),
        itemCount: 12,
        shrinkWrap: true, // Prevents unbounded height error
        physics:
            const NeverScrollableScrollPhysics(), // Parent handles scrolling
        itemBuilder: (context, index) => Shimmer.fromColors(
          baseColor: context.colorScheme.surface,
          highlightColor: Colors.grey.shade100,
          child: Container(
            color: context.colorScheme.surface,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyNfts(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false, // Prevents the sliver from being scrollable
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment
              .center, // Centers the column's children vertically
          children: [
            Text('No NFTs Found', style: context.textTheme.titleSmall),
            const SizedBox(height: kScreenPadding / 2),
            Text('You have not added any NFTs.',
                style: context.textTheme.bodySmall,
                textAlign: TextAlign.center),
            const SizedBox(height: kScreenPadding),
            TextButton(
              onPressed: () {
                _onRefresh(); // Ensures the refresh action is triggered
              },
              child: const Text('Retry'), // Button to retry the fetch action
            ),
          ],
        ),
      ),
    );
  }
}
