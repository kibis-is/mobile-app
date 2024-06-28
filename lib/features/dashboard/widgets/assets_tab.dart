import 'package:algorand_dart/algorand_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/routing/named_routes.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:kibisis/common_widgets/asset_list_item.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/assets_provider.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/refresh_account_data.dart';
import 'package:kibisis/utils/theme_extensions.dart';
import 'package:shimmer/shimmer.dart';

class AssetsTab extends ConsumerStatefulWidget {
  const AssetsTab({super.key});

  @override
  ConsumerState<AssetsTab> createState() => _AssetsTabState();
}

class _AssetsTabState extends ConsumerState<AssetsTab> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() {
    // Your refresh logic here, e.g., fetching new data and marking the refresh as complete
    ref.read(assetsProvider.notifier).fetchAssets();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final assetsAsync = ref.watch(assetsProvider);

    return Column(
      children: [
        _buildAddAssetButton(context),
        const SizedBox(height: kScreenPadding),
        Expanded(
          child: SmartRefresher(
            enablePullDown: true,
            controller: _refreshController,
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

  Widget _buildAddAssetButton(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: TextButton(
        style: ButtonStyle(
          side: MaterialStateProperty.all(
              BorderSide(color: context.colorScheme.primary)),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kWidgetRadius))),
        ),
        onPressed: () => context.goNamed(addAssetRouteName),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add Asset'),
            AppIcons.icon(
                icon: AppIcons.add,
                size: AppIcons.small,
                color: context.colorScheme.primary),
          ],
        ),
      ),
    );
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
            width: 100,
            height: 100,
            child: SvgPicture.asset('assets/images/empty.svg',
                semanticsLabel: 'No Assets Found'),
          ),
          const SizedBox(height: kScreenPadding / 2),
          Text('No Assets Found', style: context.textTheme.titleMedium),
          const SizedBox(height: kScreenPadding / 2),
          Text('You have not added any assets. Try adding one now.',
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
