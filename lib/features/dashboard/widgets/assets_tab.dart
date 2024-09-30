import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_bottom_sheet.dart';
import 'package:kibisis/common_widgets/custom_pull_to_refresh.dart';
import 'package:kibisis/common_widgets/custom_text_field.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/dashboard/providers/asset_filter_provider.dart';
import 'package:kibisis/features/dashboard/providers/show_frozen_assets.dart';
import 'package:kibisis/features/view_asset/view_asset_screen.dart';
import 'package:kibisis/models/combined_asset.dart';
import 'package:kibisis/models/select_item.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/active_asset_provider.dart';
import 'package:kibisis/providers/assets_provider.dart';
import 'package:kibisis/routing/named_routes.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/media_query_helper.dart';
import 'package:kibisis/utils/theme_extensions.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:kibisis/common_widgets/asset_list_item.dart';
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
  CombinedAsset? _selectedAsset;
  late TextEditingController filterController;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: false);

    final publicAddress = ref.read(accountProvider).account?.publicAddress;

    if (publicAddress != null && publicAddress.isNotEmpty) {
      filterController = TextEditingController(
        text: ref.read(assetsProvider(publicAddress).notifier).filterText,
      );
    } else {
      filterController = TextEditingController(text: '');
    }
  }

  @override
  void dispose() {
    _refreshController.dispose();
    filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final publicAddress = ref.watch(accountProvider).account?.publicAddress;
    final assetsAsync = ref.watch(assetsProvider(publicAddress));

    final mediaQueryHelper = MediaQueryHelper(context);
    final flex = mediaQueryHelper.getDynamicFlex();
    final assetsFilterController =
        ref.watch(assetsFilterControllerProvider.notifier);

    return mediaQueryHelper.isWideScreen()
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: flex[0],
                child: Column(
                  children: [
                    _buildSearchBar(assetsFilterController),
                    Expanded(
                      child: CustomPullToRefresh(
                        refreshController: _refreshController,
                        onRefresh: _onRefresh,
                        child: assetsAsync.when(
                          data: (assets) => _buildAssetsList(assets),
                          loading: () => _buildLoadingAssets(),
                          error: (error, stack) => _buildEmptyAssets(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: flex[1],
                child: _selectedAsset != null
                    ? ViewAssetScreen(
                        asset: _selectedAsset!,
                        isPanelMode: true,
                      )
                    : const Center(
                        child: Text('Select an asset to view details'),
                      ),
              ),
            ],
          )
        : assetsAsync.when(
            data: (assets) => _buildAssetsList(assets),
            loading: () => _buildLoadingAssets(),
            error: (error, stack) =>
                const Center(child: Text('Error loading assets')),
          );
  }

  Widget _buildSearchBar(AssetsFilterController assetsFilterController) {
    return Padding(
      padding: const EdgeInsets.only(
          left: kScreenPadding / 2,
          right: kScreenPadding / 2,
          top: kScreenPadding / 2),
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
          Expanded(
            child: CustomTextField(
              controller: filterController,
              labelText: 'Filter',
              onChanged: (value) {
                final publicAddress =
                    ref.read(accountProvider).account?.publicAddress;

                if (publicAddress != null && publicAddress.isNotEmpty) {
                  ref
                      .read(assetsProvider(publicAddress).notifier)
                      .setFilter(value);
                } else {
                  debugPrint('Public address is not available');
                }
              },
              autoCorrect: false,
              suffixIcon:
                  filterController.text.isNotEmpty ? AppIcons.cross : null,
              leadingIcon: AppIcons.search,
              onTrailingPressed: () {
                filterController.clear();
                final publicAddress =
                    ref.read(accountProvider).account?.publicAddress;

                if (publicAddress != null && publicAddress.isNotEmpty) {
                  ref
                      .read(assetsProvider(publicAddress).notifier)
                      .setFilter('');
                } else {
                  debugPrint('Public address is not available');
                }
              },
              isSmall: true,
            ),
          ),
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
            checkboxShape: const CircleBorder(),
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
    final publicAddress = ref.read(accountProvider).account?.publicAddress;

    if (publicAddress != null && publicAddress.isNotEmpty) {
      final assetsNotifier = ref.read(assetsProvider(publicAddress).notifier);
      assetsNotifier.sortAssets(sorting);
    } else {
      // Handle the case where publicAddress is null or empty
      debugPrint('Public address is not available');
    }
  }

  void _filterAssets(bool showFrozen) {
    final publicAddress = ref.read(accountProvider).account?.publicAddress;

    if (publicAddress != null && publicAddress.isNotEmpty) {
      ref
          .read(assetsProvider(publicAddress).notifier)
          .setShowFrozen(showFrozen);
    } else {
      // Handle the case where publicAddress is null or empty
      debugPrint('Public address is not available');
    }
  }

  Widget _buildAssetsList(List<CombinedAsset> assets) {
    if (assets.isEmpty) {
      return _buildEmptyAssets();
    }

    return ListView.builder(
      itemCount: assets.length,
      itemBuilder: (context, index) {
        final asset = assets[index];
        final isWideScreen = MediaQuery.of(context).size.width > 600;

        return AssetListItem(
          asset: asset,
          onPressed: () {
            debugPrint(isWideScreen ? 'Landscape mode' : 'Portrait mode');

            if (isWideScreen) {
              setState(() {
                _selectedAsset = asset;
              });
            } else {
              ref.read(activeAssetProvider.notifier).setActiveAsset(asset);
              context.goNamed(
                viewAssetRouteName,
                pathParameters: {'mode': 'view'},
                extra: asset,
              );
            }
          },
        );
      },
    );
  }

  Widget _buildEmptyAssets() {
    final publicAddress = ref.read(accountProvider).account?.publicAddress;
    bool isFilterActive = false;

    if (publicAddress != null && publicAddress.isNotEmpty) {
      isFilterActive = ref
          .read(assetsProvider(publicAddress).notifier)
          .filterText
          .isNotEmpty;
    } else {
      debugPrint('Public address is not available');
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isFilterActive
                ? 'No Assets Found for the Filter'
                : 'No Assets Found',
            style: context.textTheme.titleSmall,
          ),
          const SizedBox(height: kScreenPadding / 2),
          Text(
            isFilterActive
                ? 'Try clearing the filter to see all assets.'
                : 'You have not added any assets.',
            style: context.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: kScreenPadding),
          TextButton(
            onPressed: isFilterActive
                ? () {
                    final publicAddress =
                        ref.read(accountProvider).account?.publicAddress;
                    ref
                        .read(assetsProvider(publicAddress).notifier)
                        .setFilter('');
                    if (publicAddress != null && publicAddress.isNotEmpty) {
                      ref
                          .read(assetsProvider(publicAddress).notifier)
                          .setFilter('');
                      filterController.clear();
                    } else {
                      debugPrint('Public address is not available');
                    }
                  }
                : _onRefresh,
            child: Text(isFilterActive ? 'Clear Filter' : 'Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingAssets() {
    return Shimmer.fromColors(
      baseColor: context.colorScheme.background,
      highlightColor: context.colorScheme.onSurfaceVariant,
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
