import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_pull_to_refresh.dart';
import 'package:kibisis/common_widgets/custom_text_field.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kibisis/models/nft.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/nft_provider.dart';
import 'package:kibisis/routing/named_routes.dart';
import 'package:kibisis/theme/color_palette.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/theme_extensions.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

enum NftViewType { grid, card }

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

    return CustomPullToRefresh(
      refreshController: _refreshController,
      onRefresh: _onRefresh,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            titleSpacing: 0,
            floating: true,
            snap: true,
            title: _buildSearchBar(context),
          ),
          nftState.when(
            data: (nfts) => nfts.isEmpty
                ? _buildEmptyNfts(context)
                : _buildNftGridOrCard(nfts),
            loading: () => _buildLoadingNfts(context),
            error: (error, stack) => _buildEmptyNfts(context),
          ),
        ],
      ),
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

  Widget _buildNftGridOrCard(List<NFT> nfts) {
    return SliverToBoxAdapter(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: viewType == NftViewType.grid ? 3 : 1,
          childAspectRatio: 1.0,
        ),
        itemCount: nfts.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final nft = nfts[index];
          return GestureDetector(
            onTap: () {
              context.pushNamed(
                viewNftRouteName,
                pathParameters: {'index': index.toString()},
              );
            },
            child: Card(
              margin: viewType == NftViewType.grid
                  ? const EdgeInsets.all(0)
                  : const EdgeInsets.only(bottom: kScreenPadding / 2),
              shape: RoundedRectangleBorder(
                borderRadius: viewType == NftViewType.grid
                    ? BorderRadius.circular(0)
                    : BorderRadius.circular(kWidgetRadius),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Image.network(
                    nft.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.center,
                          colors: [
                            Colors.black87,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(kScreenPadding / 2),
                      child: SizedBox(
                        width: double.infinity,
                        child: EllipsizedText(
                          nft.name,
                          style: context.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: ColorPalette.darkThemeWhite,
                            shadows: const [
                              Shadow(
                                offset: Offset(1.0, 1.0),
                                blurRadius: 2.0,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
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
    return SliverToBoxAdapter(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width / 4,
                maxHeight: MediaQuery.of(context).size.height / 4,
              ),
              child: SvgPicture.asset(
                'assets/images/empty.svg',
                semanticsLabel: 'No NFTs Found',
              ),
            ),
            const SizedBox(height: kScreenPadding / 2),
            Text('No NFTs Found', style: context.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
