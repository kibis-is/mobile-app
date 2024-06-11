import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/asset_list_item.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/models/detailed_asset.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class AssetsTab extends StatelessWidget {
  const AssetsTab({
    super.key,
    required this.assets,
  });

  final List<DetailedAsset> assets;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAddAssetButton(context),
        const SizedBox(height: kScreenPadding),
        Expanded(
          child: assets.isEmpty
              ? _buildEmptyAssets(context)
              : _buildAssetsList(context),
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

  Widget _buildEmptyAssets(BuildContext context) {
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
        ],
      ),
    );
  }

  Widget _buildAssetsList(BuildContext context) {
    return ListView.separated(
      itemCount: assets.length,
      shrinkWrap: true,
      itemBuilder: (context, index) => AssetListItem(asset: assets[index]),
      separatorBuilder: (_, __) => const SizedBox(height: kScreenPadding / 2),
    );
  }
}
