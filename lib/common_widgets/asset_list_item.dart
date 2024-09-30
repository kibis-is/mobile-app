import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/settings/appearance/providers/dark_mode_provider.dart';
import 'package:kibisis/models/combined_asset.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;
    return Stack(
      children: [
        Material(
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
                title: isWideScreen
                    ? Text(asset.params.name ??
                        'Unknown') // No Hero in landscape mode
                    : Hero(
                        // Use Hero in portrait mode for navigation
                        tag: '${asset.index}-name',
                        child: EllipsizedText(
                          asset.params.name ?? 'Unknown',
                          style: context.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                subtitle: isWideScreen
                    ? Text(_getFormattedAmount()) // No Hero in landscape mode
                    : Hero(
                        tag: '${asset.index}-amount',
                        child: EllipsizedText(
                          _getFormattedAmount(),
                          style: context.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                trailing: _buildTrailing(context),
                onTap:
                    (onPressed == null) ? () => debugPrint('true') : onPressed),
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

  Widget _buildAssetIcon(
      BuildContext context, WidgetRef ref, bool isFrozenDefault) {
    ref.watch(isDarkModeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;
    return Hero(
      tag: isWideScreen ? '' : '${asset.index}-icon',
      child: Container(
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
      ),
    );
  }

  Widget _buildTrailing(BuildContext context) {
    return Container(
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
    return NumberShortener.shortenNumber(asset.amount.toDouble());
  }
}
