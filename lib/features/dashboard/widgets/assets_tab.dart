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
import 'package:kibisis/generated/l10n.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

final sortingProvider = StateProvider<Sorting>((ref) => Sorting.assetId);

enum Sorting { assetId, name }

class AssetsTab extends ConsumerStatefulWidget {
  const AssetsTab({super.key});

  @override
  ConsumerState<AssetsTab> createState() => _AssetsTabState();
}

class _AssetsTabState extends ConsumerState<AssetsTab> {
  late final RefreshController _wideScreenRefreshController;
  late final RefreshController _narrowScreenRefreshController;
  late TextEditingController filterController;

  @override
  void initState() {
    super.initState();
    _wideScreenRefreshController = RefreshController(initialRefresh: false);
    _narrowScreenRefreshController = RefreshController(initialRefresh: false);
    filterController = TextEditingController(text: _getFilterText());
    _loadShowFrozenAssets();
  }

  @override
  void dispose() {
    _wideScreenRefreshController.dispose();
    _narrowScreenRefreshController.dispose();
    filterController.dispose();
    super.dispose();
  }

  void _loadShowFrozenAssets() async {
    final prefs = await SharedPreferences.getInstance();
    final showFrozen = prefs.getBool('showFrozenAssets') ?? false;
    ref.read(showFrozenAssetsProvider.notifier).setShowFrozenAssets(showFrozen);
  }

  String _getFilterText() {
    final publicAddress = ref.read(accountProvider).account?.address;
    return publicAddress != null && publicAddress.isNotEmpty
        ? ref.read(assetsProvider(publicAddress).notifier).filterText
        : '';
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryHelper = MediaQueryHelper(context);
    final publicAddress = _getPublicAddress();
    final assetsAsync = ref.watch(assetsProvider(publicAddress));
    final assetsFilterController =
        ref.watch(assetsFilterControllerProvider.notifier);

    final activeAsset = ref.watch(activeAssetProvider);

    return mediaQueryHelper.isWideScreen()
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: mediaQueryHelper.getDynamicFlex()[0],
                child: _buildWideScreenSearchAndAssetList(
                  assetsFilterController: assetsFilterController,
                  assetsAsync: assetsAsync,
                ),
              ),
              Expanded(
                flex: mediaQueryHelper.getDynamicFlex()[1],
                child: activeAsset != null
                    ? const ViewAssetScreen(
                        isPanelMode: true,
                      )
                    : const Center(
                        child: Text('Select an asset to view details'),
                      ),
              ),
            ],
          )
        : _buildNarrowScreenSearchAndAssetList(
            assetsFilterController: assetsFilterController,
            assetsAsync: assetsAsync,
          );
  }

  Widget _buildWideScreenSearchAndAssetList({
    required AssetsFilterController assetsFilterController,
    required AsyncValue<List<CombinedAsset>> assetsAsync,
  }) {
    return Column(
      children: [
        _buildSearchBar(assetsFilterController),
        Expanded(
          child: CustomPullToRefresh(
            refreshController: _wideScreenRefreshController,
            onRefresh: _onWideScreenRefresh,
            child: assetsAsync.when(
              data: (assets) => _buildAssetsList(assets),
              loading: _buildLoadingAssets,
              error: (_, __) => Center(
                child: Text(S.of(context).errorLoadingAssets),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowScreenSearchAndAssetList({
    required AssetsFilterController assetsFilterController,
    required AsyncValue<List<CombinedAsset>> assetsAsync,
  }) {
    return Column(
      children: [
        _buildSearchBar(assetsFilterController),
        Expanded(
          child: CustomPullToRefresh(
            refreshController: _narrowScreenRefreshController,
            onRefresh: _onNarrowScreenRefresh,
            child: assetsAsync.when(
              data: (assets) => _buildAssetsList(assets),
              loading: _buildLoadingAssets,
              error: (_, __) =>
                  const Center(child: Text('Error loading assets')),
            ),
          ),
        ),
      ],
    );
  }

  String _getPublicAddress() {
    return ref.watch(accountProvider).account?.address ?? '';
  }

  void _onWideScreenRefresh() {
    ref.invalidate(assetsProvider);
    _wideScreenRefreshController.refreshCompleted();
  }

  void _onNarrowScreenRefresh() {
    ref.invalidate(assetsProvider);
    _narrowScreenRefreshController.refreshCompleted();
  }

  Widget _buildSearchBar(AssetsFilterController assetsFilterController) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: kScreenPadding / 2, vertical: kScreenPadding / 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildFilterButton(),
          _buildFilterTextField(),
          _buildAddAssetButton(),
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    return IconButton(
      color: context.colorScheme.surface,
      onPressed: _showFilterDialog,
      icon: Icon(
        AppIcons.importAccount,
        color: context.colorScheme.onBackground,
        size: AppIcons.medium,
      ),
    );
  }

  Widget _buildFilterTextField() {
    return Expanded(
      child: CustomTextField(
        controller: filterController,
        labelText: 'Filter',
        onChanged: _handleFilterChange,
        autoCorrect: false,
        suffixIcon: filterController.text.isNotEmpty ? AppIcons.cross : null,
        leadingIcon: AppIcons.search,
        onTrailingPressed: _clearFilter,
        isSmall: true,
      ),
    );
  }

  void _handleFilterChange(String value) {
    final publicAddress = _getPublicAddress();
    if (publicAddress.isNotEmpty) {
      ref.read(assetsProvider(publicAddress).notifier).setFilter(value);
    } else {
      debugPrint('Public address is not available');
    }
  }

  void _clearFilter() {
    filterController.clear();
    _handleFilterChange('');
  }

  Widget _buildAddAssetButton() {
    return FutureBuilder<bool>(
      future: ref.read(accountProvider.notifier).hasPrivateKey(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        if (snapshot.hasData && snapshot.data == true) {
          return IconButton(
            onPressed: () => context.goNamed(addAssetRouteName),
            icon: const Icon(AppIcons.add, size: AppIcons.medium),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showFilterDialog() {
    customBottomSheet(
      context: context,
      header: S.of(context).sortAndFilter,
      items: sortOptions,
      onPressed: (SelectItem item) {
        final newSorting = Sorting.values.firstWhere(
            (s) => s.toString().split('.').last == item.value,
            orElse: () => Sorting.assetId);
        ref.read(sortingProvider.notifier).state = newSorting;
        _sortAssets(newSorting);
      },
      singleWidget: Consumer(
        builder: (context, ref, _) {
          final showFrozen = ref.watch(showFrozenAssetsProvider);
          return CheckboxListTile(
            title: Text(S.of(context).showFrozenAssets),
            tileColor: Colors.transparent,
            value: showFrozen,
            checkboxShape: const CircleBorder(),
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
    final publicAddress = _getPublicAddress();
    if (publicAddress.isNotEmpty) {
      ref.read(assetsProvider(publicAddress).notifier).sortAssets(sorting);
    } else {
      debugPrint('Public address is not available');
    }
  }

  void _filterAssets(bool showFrozen) async {
    final publicAddress = _getPublicAddress();
    if (publicAddress.isNotEmpty) {
      ref
          .read(assetsProvider(publicAddress).notifier)
          .setShowFrozen(showFrozen);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('showFrozenAssets', showFrozen);
    } else {
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
            ref.read(activeAssetProvider.notifier).setActiveAsset(asset);
            if (!isWideScreen) {
              context.goNamed(
                viewAssetRouteName,
                extra: asset,
              );
            }
          },
        );
      },
    );
  }

  Widget _buildEmptyAssets() {
    final isFilterActive = _getPublicAddress().isNotEmpty &&
        ref
            .read(assetsProvider(_getPublicAddress()).notifier)
            .filterText
            .isNotEmpty;

    final isWideScreen = MediaQuery.of(context).size.width > 600;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isFilterActive
                ? S.of(context).noAssetsForFilter
                : S.of(context).noAssets,
            style: context.textTheme.titleSmall,
          ),
          const SizedBox(height: kScreenPadding / 2),
          Text(
            isFilterActive
                ? S.of(context).tryClearingFilter
                : S.of(context).noAssetsAdded,
            style: context.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: kScreenPadding),
          TextButton(
            onPressed:
                isFilterActive ? _clearFilter : () => _onRefresh(isWideScreen),
            child: Text(isFilterActive
                ? S.of(context).clearFilter
                : S.of(context).retry),
          ),
        ],
      ),
    );
  }

  void _onRefresh(bool isWideScreen) {
    if (isWideScreen) {
      _wideScreenRefreshController.requestRefresh();
    } else {
      _narrowScreenRefreshController.requestRefresh();
    }
  }

  Widget _buildLoadingAssets() {
    return Shimmer.fromColors(
      baseColor: context.colorScheme.background,
      highlightColor: context.colorScheme.onSurfaceVariant,
      period: const Duration(milliseconds: 2000),
      child: ListView.separated(
        itemCount: 3,
        itemBuilder: (_, __) => ListTile(
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
        separatorBuilder: (_, __) => const SizedBox(height: kScreenPadding / 2),
      ),
    );
  }

  List<SelectItem> get sortOptions => [
        SelectItem(
            name: "Sort by Index",
            value: "index",
            icon: Icons.format_list_numbered),
        SelectItem(
            name: "Sort by Name", value: "name", icon: Icons.sort_by_alpha),
      ];
}
