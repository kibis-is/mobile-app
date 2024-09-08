import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/settings/appearance/providers/dark_mode_provider.dart';
import 'package:kibisis/models/combined_asset.dart';
import 'package:kibisis/providers/active_asset_provider.dart';
import 'package:kibisis/routing/named_routes.dart';
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
    ref.watch(isDarkModeProvider);
    return Stack(
      children: [
        Hero(
          tag: asset.index.toString(),
          child: Material(
            child: Container(
              decoration: BoxDecoration(
                color: context.colorScheme.background,
                border: Border.symmetric(
                  horizontal:
                      BorderSide(width: 1, color: context.colorScheme.surface),
                ),
              ),
              child: ListTile(
                leading: _buildAssetIcon(
                    context, ref, asset.params.defaultFrozen ?? false),
                title: EllipsizedText(
                  asset.params.name ?? 'Unknown',
                  style: context.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: EllipsizedText(
                  mode == AssetScreenMode.add ? '' : _getFormattedAmount(),
                  style: context.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: _buildTrailing(context),
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
    ref.watch(isDarkModeProvider);
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colorScheme.primary,
      ),
      child: Padding(
        padding: const EdgeInsets.all(kScreenPadding / 3),
        child: AppIcons.icon(
            icon: AppIcons.voiCircleIcon,
            color: context.colorScheme.onPrimary,
            size: AppIcons.xlarge),
      ),
    );
  }

  Widget _buildTrailing(BuildContext context) {
    return SizedBox(
      child: (onPressed == null && mode == AssetScreenMode.add)
          ? Text(
              'Owned',
              style: context.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            )
          : AppIcons.icon(icon: AppIcons.arrowRight),
    );
  }

  String _getFormattedAmount() {
    return NumberShortener.formatAssetTotal(asset.amount);
  }
}
