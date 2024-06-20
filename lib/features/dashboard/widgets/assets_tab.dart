import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/common_widgets/asset_list_item.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/models/detailed_asset.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/assets_provider.dart';
import 'package:kibisis/utils/refresh_account_data.dart';
import 'package:shimmer/shimmer.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class AssetsTab extends ConsumerWidget {
  const AssetsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsAsync = ref.watch(assetsProvider);

    return Column(
      children: [
        _buildAddAssetButton(context),
        const SizedBox(height: kScreenPadding),
        Expanded(
          child: assetsAsync.when(
            data: (assets) => assets.isEmpty
                ? _buildEmptyAssets(context, ref)
                : _buildAssetsList(context, assets),
            loading: () => _buildLoadingAssets(context),
            error: (error, stack) => _buildEmptyAssets(context, ref),
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
        onPressed: () => GoRouter.of(context).go('/addAsset'),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add Asset'),
            Icon(Icons.add, color: context.colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyAssets(BuildContext context, WidgetRef ref) {
    return Center(
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
              semanticsLabel: 'No Assets Found',
            ),
          ),
          const SizedBox(height: kScreenPadding / 2),
          Text('No Assets Found', style: context.textTheme.titleMedium),
          const SizedBox(height: kScreenPadding / 2),
          Text('You have not added any assets. Try adding one now.',
              style: context.textTheme.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: kScreenPadding),
          TextButton(
            onPressed: () {
              final publicAddress =
                  ref.watch(accountProvider).account?.publicAddress ?? '';
              refreshAccountData(context, ref, publicAddress);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetsList(BuildContext context, List<DetailedAsset> assets) {
    return ListView.separated(
      itemCount: assets.length,
      shrinkWrap: true,
      itemBuilder: (context, index) => AssetListItem(asset: assets[index]),
      separatorBuilder: (_, __) => const SizedBox(height: kScreenPadding / 2),
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
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(height: kScreenPadding / 2);
        },
      ),
    );
  }
}
