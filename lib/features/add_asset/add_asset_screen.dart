import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/asset_list_item.dart';
import 'package:kibisis/common_widgets/custom_text_field.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/add_asset/search_provider.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/active_asset_provider.dart';
import 'package:kibisis/providers/assets_provider.dart';
import 'package:kibisis/routing/named_routes.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/theme_extensions.dart';
import 'package:shimmer/shimmer.dart';

class AddAssetScreen extends ConsumerWidget {
  static String title = 'Add Asset';
  AddAssetScreen({super.key});
  final accountController = TextEditingController(text: '');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchNotifier = ref.watch(searchProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        children: [
          const SizedBox(height: kScreenPadding),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
            child: Text(
              "Enter an assetID, name, asset, or symbol ID (for ARC-200).",
              style: context.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: kScreenPadding),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
            child: CustomTextField(
              controller: accountController,
              leadingIcon: AppIcons.search,
              labelText: 'Search Query',
              onChanged: (value) {
                searchNotifier.searchAssets(value);
              },
            ),
          ),
          const SizedBox(height: kScreenPadding),
          const AssetList(),
          const SizedBox(height: kScreenPadding),
        ],
      ),
    );
  }
}

class AssetList extends ConsumerWidget {
  const AssetList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchProvider);
    final publicAddress = ref.watch(accountProvider).account?.address ?? '';
    final ownedAssets = ref.watch(assetsProvider(publicAddress));

    return Expanded(
      child: searchState.when(
        data: (searchedAssets) {
          if (searchedAssets.isEmpty) {
            return const Center(
              child: Text('No assets found.'),
            );
          }

          return ownedAssets.maybeWhen(
            data: (ownedAssetsData) {
              return ListView.separated(
                itemCount: searchedAssets.length,
                itemBuilder: (context, index) {
                  final asset = searchedAssets[index];
                  final isOwned = ownedAssetsData
                      .any((ownedAsset) => ownedAsset.index == asset.index);
                  return AssetListItem(
                    asset: asset,
                    mode: isOwned ? AssetScreenMode.view : AssetScreenMode.add,
                    onPressed: () {
                      ref
                          .read(activeAssetProvider.notifier)
                          .setActiveAsset(asset);
                      context.pushNamed(viewAssetRouteName);
                    },
                  );
                },
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(height: kScreenPadding / 2),
              );
            },
            orElse: () {
              return const Center(child: CircularProgressIndicator());
            },
          );
        },
        loading: () {
          return _buildLoadingAssets(context);
        },
        error: (e, stack) {
          return const Center(child: Text('Sorry, there was an error.'));
        },
      ),
    );
  }

  Widget _buildLoadingAssets(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kScreenPadding / 2),
      child: Shimmer.fromColors(
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
          separatorBuilder: (_, __) =>
              const SizedBox(height: kScreenPadding / 2),
        ),
      ),
    );
  }
}
