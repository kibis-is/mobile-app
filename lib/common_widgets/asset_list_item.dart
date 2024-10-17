import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/settings/appearance/providers/dark_mode_provider.dart';
import 'package:kibisis/models/combined_asset.dart';
import 'package:kibisis/providers/network_provider.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/media_query_helper.dart';
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
    final mediaQueryHelper = MediaQueryHelper(context);

    return Stack(
      children: [
        _buildListItem(context, ref, mediaQueryHelper),
        if (asset.params.defaultFrozen ?? false) _buildFrozenIcon(context),
      ],
    );
  }

  Widget _buildListItem(
      BuildContext context, WidgetRef ref, MediaQueryHelper mediaQueryHelper) {
    return Material(
      child: Container(
        decoration: _buildListItemDecoration(context),
        child: ListTile(
          leading: _buildAssetIcon(context, ref),
          title: _buildTitle(context, mediaQueryHelper),
          subtitle: _buildSubtitle(context, mediaQueryHelper),
          trailing: _buildTrailing(context),
          onTap: onPressed ?? () => debugPrint('Tapped asset item'),
        ),
      ),
    );
  }

  BoxDecoration _buildListItemDecoration(BuildContext context) {
    return BoxDecoration(
      color: context.colorScheme.background,
      border: Border.symmetric(
        horizontal: BorderSide(width: 1, color: context.colorScheme.surface),
      ),
    );
  }

  Widget _buildAssetIcon(BuildContext context, WidgetRef ref) {
    final mediaQueryHelper = MediaQueryHelper(context);
    final network = ref.watch(networkProvider);
    return Hero(
      tag: mediaQueryHelper.isWideScreen()
          ? 'wide-${asset.index}-icon'
          : '${asset.index}-icon',
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.colorScheme.primary,
        ),
        child: Padding(
          padding: const EdgeInsets.all(kScreenPadding / 3),
          child: AppIcons.icon(
            icon: network?.value.startsWith('network-voi') ?? false
                ? AppIcons.voiCircleIcon
                : AppIcons.algorandIcon,
            color: context.colorScheme.onPrimary,
            size: AppIcons.xlarge,
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, MediaQueryHelper mediaQueryHelper) {
    final titleStyle =
        context.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold);
    return mediaQueryHelper.isWideScreen()
        ? EllipsizedText(asset.params.name ?? 'Unknown', style: titleStyle)
        : Hero(
            tag: '${asset.index}-name',
            child: EllipsizedText(asset.params.name ?? 'Unknown',
                style: titleStyle),
          );
  }

  Widget _buildSubtitle(
      BuildContext context, MediaQueryHelper mediaQueryHelper) {
    final subtitleStyle =
        context.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold);
    return mediaQueryHelper.isWideScreen()
        ? EllipsizedText(_getFormattedAmount(), style: subtitleStyle)
        : Hero(
            tag: '${asset.index}-amount',
            child: EllipsizedText(_getFormattedAmount(), style: subtitleStyle),
          );
  }

  Widget _buildTrailing(BuildContext context) {
    return mode == AssetScreenMode.add && onPressed == null
        ? Text(
            'Already\nadded',
            style: context.textTheme.bodySmall,
            textAlign: TextAlign.right,
          )
        : AppIcons.icon(icon: AppIcons.arrowRight);
  }

  Widget _buildFrozenIcon(BuildContext context) {
    return Positioned(
      top: kScreenPadding / 2,
      right: kScreenPadding / 2,
      child: AppIcons.icon(
        icon: AppIcons.freeze,
        size: AppIcons.small,
        color: context.colorScheme.onSurfaceVariant,
      ),
    );
  }

  String _getFormattedAmount() {
    return NumberShortener.shortenNumber(asset.amount.toDouble());
  }
}
