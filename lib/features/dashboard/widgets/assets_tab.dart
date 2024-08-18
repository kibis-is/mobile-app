import 'package:algorand_dart/algorand_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_bottom_sheet.dart';
import 'package:kibisis/common_widgets/custom_pull_to_refresh.dart';
import 'package:kibisis/common_widgets/custom_text_field.dart';
import 'package:kibisis/features/dashboard/providers/show_frozen_assets.dart';
import 'package:kibisis/models/select_item.dart';
import 'package:kibisis/routing/named_routes.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:kibisis/common_widgets/asset_list_item.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/assets_provider.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/refresh_account_data.dart';
import 'package:kibisis/utils/theme_extensions.dart';
import 'package:shimmer/shimmer.dart';

final sortingProvider = StateProvider<Sorting>((ref) => Sorting.assetId);

enum Sorting { assetId, name }

class AssetsTab extends ConsumerStatefulWidget {
  const AssetsTab({super.key});

  @override
  ConsumerState<AssetsTab> createState() => _AssetsTabState();
}

class _AssetsTabState extends ConsumerState<AssetsTab> {
  late final RefreshController _refreshController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController filterController = TextEditingController();

  void _onRefresh() {
    invalidateProviders(ref);
    ref.read(assetsProvider.notifier).fetchAssets();
    _refreshController.refreshCompleted();
  }

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    filterController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assetsAsync = ref.watch(assetsProvider);

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverAppBar(
          titleSpacing: 0,
          floating: true,
          snap: true,
          title: _buildSearchBar(context),
        ),
        SliverFillRemaining(
          child: CustomPullToRefresh(
            refreshController: _refreshController,
            onRefresh: _onRefresh,
            child: assetsAsync.when(
              data: (assets) => assets.isEmpty
                  ? _buildEmptyAssets(context, ref)
                  : _buildAssetsList(context, assets),
              loading: () => _buildLoadingAssets(context),
              error: (error, stack) => _buildEmptyAssets(context, ref),
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
          onPressed: _showFilterDialog,
          icon: Icon(
            AppIcons.importAccount,
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
              ref.read(assetsProvider.notifier).setFilter(value);
            },
            autoCorrect: false,
            suffixIcon: AppIcons.cross,
            leadingIcon: AppIcons.search,
            onTrailingPressed: () => filterController.clear(),
            isSmall: true,
          ),
        ),
        const SizedBox(width: kScreenPadding / 2),
        IconButton(
          onPressed: () => context.goNamed(addAssetRouteName),
          icon: Icon(
            AppIcons.add,
            color: context.colorScheme.primary,
            size: AppIcons.medium,
          ),
        ),
      ],
    );
  }

  void _showFilterDialog() {
    customBottomSheet(
      context: context,
      header: "Sort and Filter Assets",
      items: sortOptions,
      onPressed: (SelectItem item) {
        Sorting newSorting = Sorting.values.firstWhere(
            (s) => s.toString().split('.').last == item.value,
            orElse: () => Sorting.assetId);
        ref.read(sortingProvider.notifier).state = newSorting;
        _sortAssets(newSorting);
      },
      singleWidget: Consumer(
        builder: (context, ref, child) {
          final showFrozen = ref.watch(showFrozenAssetsProvider);
          return CheckboxListTile(
            tileColor: Colors.transparent,
            selectedTileColor: Colors.transparent,
            title: const Text("Show Frozen Assets"),
            value: showFrozen,
            onChanged: (bool? value) {
              if (value != null) {
                ref
                    .read(showFrozenAssetsProvider.notifier)
                    .setShowFrozenAssets(value);
                _filterAssets(value);
              }
            },
          );
        },
      ),
    );
  }

  void _sortAssets(Sorting sorting) {
    final assetsNotifier = ref.read(assetsProvider.notifier);
    assetsNotifier.sortAssets(sorting);
  }

  void _filterAssets(bool showFrozen) {
    ref.read(assetsProvider.notifier).setShowFrozen(showFrozen);
  }

  Widget _buildAssetsList(BuildContext context, List<Asset> assets) {
    return ListView.separated(
      itemCount: assets.length,
      shrinkWrap: true,
      itemBuilder: (context, index) =>
          AssetListItem(asset: assets[index], mode: AssetScreenMode.view),
      separatorBuilder: (_, __) => const SizedBox(height: kScreenPadding / 2),
    );
  }

  Widget _buildEmptyAssets(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: SvgPicture.asset('assets/images/empty.svg',
                semanticsLabel: 'No Assets Found'),
          ),
          const SizedBox(height: kScreenPadding / 2),
          Text('No Assets Found', style: context.textTheme.titleMedium),
          const SizedBox(height: kScreenPadding / 2),
          Text('You have not added any assets.',
              style: context.textTheme.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: kScreenPadding),
          TextButton(
            onPressed: () {
              invalidateProviders(ref);
            },
            child: const Text('Retry'),
          ),
          const SizedBox(height: kScreenPadding),
        ],
      ),
    );
  }

  Widget _buildLoadingAssets(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.colorScheme.background,
      highlightColor: Colors.grey.shade100,
      period: const Duration(milliseconds: 2000),
      child: ListView.separated(
        itemCount: 3,
        itemBuilder: (context, index) => ListTile(
          leading: const CircleAvatar(),
          title: Container(
              width: double.infinity,
              height: kScreenPadding,
              color: context.colorScheme.surface),
          subtitle: Container(
              width: double.infinity,
              height: kScreenPadding,
              color: context.colorScheme.surface),
        ),
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(height: kScreenPadding / 2),
      ),
    );
  }
}

List<SelectItem> sortOptions = [
  SelectItem(
      name: "Sort by Index", value: "index", icon: Icons.format_list_numbered),
  SelectItem(name: "Sort by Name", value: "name", icon: Icons.sort_by_alpha),
];
