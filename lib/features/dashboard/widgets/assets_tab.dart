import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_bottom_sheet.dart';
import 'package:kibisis/common_widgets/custom_pull_to_refresh.dart';
import 'package:kibisis/common_widgets/custom_text_field.dart';
import 'package:kibisis/features/dashboard/providers/asset_filter_provider.dart';
import 'package:kibisis/features/dashboard/providers/show_frozen_assets.dart';
import 'package:kibisis/models/combined_asset.dart';
import 'package:kibisis/models/select_item.dart';
import 'package:kibisis/routing/named_routes.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:kibisis/common_widgets/asset_list_item.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/assets_provider.dart';
import 'package:kibisis/utils/app_icons.dart';
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

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: false);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assetsAsync = ref.watch(assetsProvider);
    final filterController = ref.watch(assetsFilterControllerProvider);
    final filterNotifier = ref.watch(assetsFilterControllerProvider.notifier);

    return Column(
      children: [
        _buildSearchBar(context, filterController, filterNotifier),
        const SizedBox(height: kScreenPadding / 4),
        Expanded(
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

  Widget _buildSearchBar(BuildContext context, TextEditingController controller,
      AssetsFilterController notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
      child: Row(
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
              controller: controller,
              labelText: 'Filter',
              onChanged: (value) {
                ref.read(assetsProvider.notifier).setFilter(value);
              },
              autoCorrect: false,
              suffixIcon: AppIcons.cross,
              leadingIcon: AppIcons.search,
              onTrailingPressed: () {
                notifier.reset(); // Reset the text field
                ref.read(assetsProvider.notifier).setFilter('');
              },
              isSmall: true,
            ),
          ),
          const SizedBox(width: kScreenPadding / 2),
          IconButton(
            onPressed: () => context.goNamed(addAssetRouteName),
            icon: const Icon(
              AppIcons.add,
              size: AppIcons.medium,
            ),
          ),
        ],
      ),
    );
  }

  void _onRefresh() {
    ref.invalidate(assetsProvider);
    _refreshController.refreshCompleted();
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

  Widget _buildAssetsList(BuildContext context, List<CombinedAsset> assets) {
    return ListView.builder(
      itemCount: assets.length + 1,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        if (index == assets.length) {
          return const SizedBox(height: 100);
        }
        return AssetListItem(asset: assets[index], mode: AssetScreenMode.view);
      },
    );
  }

  Widget _buildEmptyAssets(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('No Assets Found', style: context.textTheme.titleSmall),
          const SizedBox(height: kScreenPadding / 2),
          Text('You have not added any assets.',
              style: context.textTheme.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: kScreenPadding),
          TextButton(
            onPressed: () {
              _onRefresh();
            },
            child: const Text('Retry'),
          ),
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

  List<SelectItem> sortOptions = [
    SelectItem(
        name: "Sort by Index",
        value: "index",
        icon: Icons.format_list_numbered),
    SelectItem(name: "Sort by Name", value: "name", icon: Icons.sort_by_alpha),
  ];
}
