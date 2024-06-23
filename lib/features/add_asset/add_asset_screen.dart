import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/common_widgets/asset_list_item.dart';
import 'package:kibisis/common_widgets/custom_text_field.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/add_asset/search_provider.dart';
import 'package:kibisis/providers/assets_provider.dart';
import 'package:kibisis/utils/theme_extensions.dart';

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
        child: Column(
          children: [
            const SizedBox(height: kScreenPadding),
            Text(
              "Enter an assetID, name, asset, or symbol ID (for ARC-200).",
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: kScreenPadding),
            CustomTextField(
              controller: accountController,
              labelText: 'Search Query',
              onChanged: (value) {
                searchNotifier.searchAssets(value);
              },
            ),
            const SizedBox(height: kScreenPadding),
            const AssetList(),
            const SizedBox(height: kScreenPadding),
          ],
        ),
      ),
    );
  }
}

class AssetList extends ConsumerWidget {
  const AssetList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchProvider);
    final ownedAssets = ref.watch(assetsProvider);

    return Expanded(
      child: searchState.when(
        data: (assets) {
          if (assets.isEmpty) {
            return const Center(
              child: Text('No assets found.'),
            );
          }

          return ListView.builder(
            itemCount: assets.length,
            itemBuilder: (context, index) {
              final asset = assets[index];
              final isOwned = ownedAssets.maybeWhen(
                data: (assets) =>
                    assets.any((ownedAsset) => ownedAsset.index == asset.index),
                orElse: () => false,
              );
              return AssetListItem(
                  asset: asset,
                  mode: AssetScreenMode.add,
                  onPressed: isOwned ? null : () {});
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
