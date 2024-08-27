import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_chip.dart';
import 'package:kibisis/common_widgets/flexible_listtile.dart';
import 'package:kibisis/common_widgets/frozen_box_decoration.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/settings/appearance/providers/dark_mode_provider.dart';
import 'package:kibisis/models/combined_asset.dart';
import 'package:kibisis/providers/active_asset_provider.dart';
import 'package:kibisis/routing/named_routes.dart';
import 'package:kibisis/theme/color_palette.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/number_shortener.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class AssetListItem extends ConsumerWidget {
  const AssetListItem({
    super.key,
    required this.asset,
    this.mode,
    this.onPressed,
  });

  final CombinedAsset asset;
  final AssetScreenMode? mode;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        Hero(
          tag: asset.index.toString(),
          child: Material(
            child: Container(
              decoration: asset.params.defaultFrozen ?? false
                  ? frozenBoxDecoration(context)
                  : BoxDecoration(
                      color: context.colorScheme.surface,
                      borderRadius: BorderRadius.circular(kWidgetRadius),
                    ),
              child: FlexibleListTile(
                leading: _buildAssetIcon(
                    context, ref, asset.params.defaultFrozen ?? false),
                title: EllipsizedText(
                  asset.params.name ?? 'Unknown',
                  style: context.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: EllipsizedText(
                  asset.params.unitName ?? 'Unknown',
                  style: context.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.onSurface),
                ),
                trailing: _buildAssetAmount(context),
                onTap: (onPressed == null && mode == AssetScreenMode.add)
                    ? null
                    : () => _handleOnPressed(context, ref),
              ),
            ),
          ),
        ),
        if (asset.params.defaultFrozen ?? false)
          Positioned(
            top: kScreenPadding / 2,
            right: kScreenPadding / 2,
            child: AppIcons.icon(
              icon: AppIcons.freeze,
              size: AppIcons.small,
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  void _handleOnPressed(BuildContext context, WidgetRef ref) {
    ref.read(activeAssetProvider.notifier).setActiveAsset(asset);
    if (mode == AssetScreenMode.view) {
      context.goNamed(
        viewAssetRouteName,
        pathParameters: {
          'mode': 'view',
        },
      );
    } else if (mode == AssetScreenMode.add) {
      context.pushNamed(
        viewAssetRouteName,
        pathParameters: {
          'mode': 'add',
        },
      );
    }
  }

  Widget _buildAssetIcon(
      BuildContext context, WidgetRef ref, bool isFrozenDefault) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    return Container(
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isFrozenDefault
              ? isDarkMode
                  ? ColorPalette.darkThemeFrozenColor
                  : ColorPalette.lightThemeFrozenColor
              : context.colorScheme.primary),
      child: Padding(
        padding: const EdgeInsets.all(kScreenPadding / 3),
        child: AppIcons.icon(
            icon: AppIcons.voiCircleIcon,
            color: context.colorScheme.onPrimary,
            size: AppIcons.xlarge),
      ),
    );
  }

  String _getAssetTypeLabel(AssetType assetType) {
    switch (assetType) {
      case AssetType.arc200:
        return 'ARC0200';
      case AssetType.standard:
      default:
        return 'ASA';
    }
  }

  Widget _buildAssetAmount(BuildContext context) {
    return SizedBox(
      child: (onPressed == null && mode == AssetScreenMode.add)
          ? Text('Owned',
              style: context.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold))
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      NumberShortener.formatAssetTotal(asset.params.total),
                      style: context.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: kScreenPadding / 2),
                    CustomChip(
                      label: _getAssetTypeLabel(asset.assetType),
                      backgroundColor: asset.assetType == AssetType.arc200
                          ? ColorPalette.chipVanilla
                          : ColorPalette.cardGradientMediumBlue,
                      labelColor: asset.assetType == AssetType.arc200
                          ? ColorPalette.darkThemeRaisinBlack
                          : ColorPalette.darkThemeAntiflashWhite,
                      borderRadius: const BorderRadius.all(
                          Radius.circular(kWidgetRadius)),
                    ),
                  ],
                ),
                AppIcons.icon(icon: AppIcons.arrowRight),
              ],
            ),
    );
  }
}
