import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/models/detailed_asset.dart';
import 'package:kibisis/theme/color_palette.dart';
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
            child: FittedBox(
              fit: BoxFit.contain,
              child: SvgPicture.asset(
                'assets/images/empty.svg',
                semanticsLabel: 'No Assets Found',
              ),
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

class AssetListItem extends StatelessWidget {
  const AssetListItem({
    super.key,
    required this.asset,
  });

  final DetailedAsset asset;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        asset.isFrozen
            ? const Padding(
                padding: EdgeInsets.all(kScreenPadding / 2),
                child: Icon(Icons.ac_unit, size: kScreenPadding),
              )
            : Container(),
        Material(
          child: ListTile(
            horizontalTitleGap: kScreenPadding * 2,
            leading: _buildAssetIcon(),
            title: Text(asset.name ?? 'Unknown',
                style: context.textTheme.titleMedium!
                    .copyWith(fontWeight: FontWeight.bold)),
            subtitle: Text(asset.unitName ?? 'Unknown',
                style: context.textTheme.titleSmall!
                    .copyWith(color: context.colorScheme.onSurface)),
            trailing: _buildAssetAmount(context),
            onTap: () => GoRouter.of(context).go('/viewAsset/${asset.assetId}'),
          ),
        ),
      ],
    );
  }

  Widget _buildAssetIcon() {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: ColorPalette.voiPurple,
      ),
      child: Padding(
        padding: const EdgeInsets.all(kScreenPadding),
        child: SvgPicture.asset(
          'assets/images/voi-asset-icon.svg',
          semanticsLabel: 'VOI Logo',
          width: kScreenPadding,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcATop),
        ),
      ),
    );
  }

  Widget _buildAssetAmount(BuildContext context) {
    return SizedBox(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            asset.amount.toString(),
            style: context.textTheme.titleSmall?.copyWith(
                color: context.colorScheme.secondary,
                fontWeight: FontWeight.bold),
          ),
          const Icon(Icons.arrow_forward_ios),
        ],
      ),
    );
  }
}
