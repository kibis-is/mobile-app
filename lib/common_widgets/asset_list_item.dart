import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/frozen_box_decoration.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/models/detailed_asset.dart';
import 'package:kibisis/providers/active_asset_provider.dart';
import 'package:kibisis/theme/color_palette.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class AssetListItem extends ConsumerWidget {
  const AssetListItem({
    super.key,
    required this.asset,
  });

  final DetailedAsset asset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Material(
          child: Container(
            decoration: frozenBoxDecoration(context),
            child: ListTile(
              tileColor: Colors.transparent,
              horizontalTitleGap: kScreenPadding * 2,
              leading: _buildAssetIcon(),
              title: Text(asset.name ?? 'Unknown',
                  style: context.textTheme.titleMedium!
                      .copyWith(fontWeight: FontWeight.bold)),
              subtitle: Text(asset.unitName ?? 'Unknown',
                  style: context.textTheme.titleSmall!
                      .copyWith(color: context.colorScheme.onSurface)),
              trailing: _buildAssetAmount(context),
              onTap: () {
                ref.read(activeAssetProvider.notifier).setActiveAsset(asset);
                GoRouter.of(context).go('/viewAsset/');
              },
            ),
          ),
        ),
        asset.isFrozen
            ? const Padding(
                padding: EdgeInsets.all(kScreenPadding / 2),
                child: Icon(Icons.ac_unit, size: kScreenPadding),
              )
            : Container(),
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
