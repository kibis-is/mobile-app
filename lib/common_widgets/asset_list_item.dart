import 'package:algorand_dart/algorand_dart.dart';
import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/frozen_box_decoration.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/settings/appearance/providers/dark_mode_provider.dart';
import 'package:kibisis/providers/active_asset_provider.dart';
import 'package:kibisis/routing/named_routes.dart';
import 'package:kibisis/theme/color_palette.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class AssetListItem extends ConsumerWidget {
  const AssetListItem({
    super.key,
    required this.asset,
    this.mode,
    this.onPressed,
  });

  final Asset asset;
  final AssetScreenMode? mode;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Material(
          child: Container(
            decoration: asset.params.defaultFrozen ?? false
                ? frozenBoxDecoration(context)
                : BoxDecoration(
                    color: context.colorScheme.surface,
                    borderRadius: BorderRadius.circular(kWidgetRadius),
                  ),
            child: ListTile(
              tileColor: Colors.transparent,
              horizontalTitleGap: kScreenPadding * 2,
              leading: _buildAssetIcon(
                  context, ref, asset.params.defaultFrozen ?? false),
              title: EllipsizedText(
                asset.params.name ?? 'Unknown',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: EllipsizedText(
                asset.params.unitName ?? 'Unknown',
                style: context.textTheme.titleSmall?.copyWith(
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
        if (asset.params.defaultFrozen ?? false)
          Padding(
            padding: const EdgeInsets.all(kScreenPadding / 2),
            child: AppIcons.icon(
                icon: AppIcons.freeze,
                size: AppIcons.small,
                color: context.colorScheme.onSurfaceVariant),
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
        border: Border.all(
            width: 3,
            color: isFrozenDefault
                ? isDarkMode
                    ? ColorPalette.darkThemeFrozenColor
                    : ColorPalette.lightThemeFrozenColor
                : context.colorScheme.primary),
      ),
      child: Padding(
        padding: const EdgeInsets.all(kScreenPadding / 3),
        child: AppIcons.icon(
            icon: AppIcons.asset,
            color: isFrozenDefault
                ? isDarkMode
                    ? ColorPalette.darkThemeFrozenColor
                    : ColorPalette.lightThemeFrozenColor
                : context.colorScheme.primary,
            size: AppIcons.large),
      ),
    );
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
                AppIcons.icon(icon: AppIcons.arrowRight),
              ],
            ),
    );
  }
}
