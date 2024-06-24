import 'package:algorand_dart/algorand_dart.dart';
import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/common_widgets/frozen_box_decoration.dart';
import 'package:kibisis/common_widgets/top_snack_bar.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/settings/appearance/providers/dark_mode_provider.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/active_asset_provider.dart';
import 'package:kibisis/providers/algorand_provider.dart';
import 'package:kibisis/providers/assets_provider.dart';
import 'package:kibisis/providers/loading_provider.dart';
import 'package:kibisis/routing/named_routes.dart';
import 'package:kibisis/theme/color_palette.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/copy_to_clipboard.dart';
import 'package:kibisis/utils/number_shortener.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class ViewAssetScreen extends ConsumerWidget {
  final AssetScreenMode mode;

  const ViewAssetScreen({
    super.key,
    this.mode = AssetScreenMode.view,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(activeAssetProvider);
    return Scaffold(
      appBar: AppBar(
        title:
            Text(mode == AssetScreenMode.view ? 'Asset Details' : 'Add Asset'),
      ),
      body: const AssetDetailsView(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
            left: kScreenPadding,
            right: kScreenPadding,
            bottom: kScreenPadding / 2),
        child: CustomButton(
          text: mode == AssetScreenMode.view ? 'Send' : 'Add',
          isFullWidth: true,
          onPressed: () async {
            switch (mode) {
              case AssetScreenMode.view:
                context.pushNamed(
                  sendTransactionRouteName,
                  pathParameters: {
                    'mode': 'asset',
                  },
                );
                break;
              case AssetScreenMode.add:
                ref.read(loadingProvider.notifier).startLoading();
                final algorandService = ref.read(algorandServiceProvider);
                final account = ref.read(accountProvider).account;
                final activeAsset = ref.read(activeAssetProvider);

                if (account != null && activeAsset != null) {
                  try {
                    await algorandService.optInAsset(
                        activeAsset.index, account);
                    ref.invalidate(assetsProvider);

                    if (!context.mounted) return;
                    GoRouter.of(context).go('/');
                    showCustomSnackBar(
                      context: context,
                      snackType: SnackType.success,
                      message: 'Asset successfully opted in',
                    );
                  } catch (e) {
                    debugPrint('Failed to opt-in to asset: $e');
                    showCustomSnackBar(
                      context: context,
                      snackType: SnackType.error,
                      message: 'Failed to opt-in to asset: $e',
                    );
                    ref.read(loadingProvider.notifier).stopLoading();
                  }
                } else {
                  debugPrint('Account or active asset is null');
                  showCustomSnackBar(
                    context: context,
                    snackType: SnackType.error,
                    message: 'Account or active asset is null',
                  );
                }
                ref.read(loadingProvider.notifier).stopLoading();
                break;
            }
          },
        ),
      ),
    );
  }
}

// Rest of your classes (AssetDetailsView, AssetHeader, AssetControls, etc.) remain unchanged.

class AssetDetailsView extends ConsumerWidget {
  const AssetDetailsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAsset = ref.watch(activeAssetProvider);
    final accountState = ref.read(accountProvider);
    final canShowFreezeButton =
        accountState.account?.publicAddress == activeAsset?.params.freeze;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(kScreenPadding),
      child: Column(
        children: [
          const AssetHeader(),
          if (canShowFreezeButton) const AssetControls(),
          const AssetExpansionToggle(),
        ],
      ),
    );
  }
}

class AssetHeader extends ConsumerWidget {
  const AssetHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAsset = ref.watch(activeAssetProvider);
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(kScreenPadding),
          decoration: activeAsset?.params.defaultFrozen ?? false
              ? frozenBoxDecoration(context)
              : BoxDecoration(
                  color: context.colorScheme.surface,
                  borderRadius: BorderRadius.circular(kWidgetRadius),
                ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(kScreenPadding),
                decoration: const BoxDecoration(
                  color: ColorPalette.voiPurple,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  '${AppIcons.svgBasePath}${AppIcons.voiIcon}.svg', // Use string interpolation correctly
                  width: 50,
                  height: 50,
                  semanticsLabel: 'VOI Logo',
                  colorFilter:
                      const ColorFilter.mode(Colors.white, BlendMode.srcATop),
                ),
              ),
              const SizedBox(height: kScreenPadding),
              Text(
                activeAsset?.params.name ?? 'Unnamed Asset',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          top: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: kScreenPadding / 2, vertical: kScreenPadding),
            child: Row(
              children: [
                Chip(
                    padding: const EdgeInsets.all(kScreenPadding / 4),
                    label: Text(
                      'ASA',
                      style: context.textTheme.displaySmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: ref.watch(isDarkModeProvider)
                        ? ColorPalette.cardGradientMediumBlue
                        : Colors.lightBlue[100]),
              ],
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: kScreenPadding / 2, vertical: kScreenPadding),
            child: Row(
              children: [
                Text(
                  activeAsset?.index.toString() ?? '',
                  style: context.textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                InkWell(
                  onTap: () => copyToClipboard(
                      context, activeAsset?.index.toString() ?? ''),
                  child: Padding(
                    padding: const EdgeInsets.only(left: kScreenPadding),
                    child: AppIcons.icon(
                        icon: AppIcons.copy, size: AppIcons.small),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (activeAsset?.params.defaultFrozen ?? false)
          Positioned(
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: kScreenPadding / 2, vertical: kScreenPadding),
              child: AppIcons.icon(icon: AppIcons.freeze, size: AppIcons.small),
            ),
          ),
      ],
    );
  }
}

class AssetControls extends ConsumerStatefulWidget {
  const AssetControls({super.key});

  @override
  AssetControlsState createState() => AssetControlsState();
}

class AssetControlsState extends ConsumerState<AssetControls> {
  void _showSnackBar({required String message, required SnackType snackType}) {
    showCustomSnackBar(
      context: context,
      snackType: snackType,
      message: message,
    );
  }

  Future<void> _toggleFreezeAsset(BuildContext context, WidgetRef ref) async {
    final isLoading = ref.watch(loadingProvider.notifier);
    isLoading.startLoading();
    final activeAsset = ref.read(activeAssetProvider);
    final accountState = ref.read(accountProvider);
    final algorandService = ref.read(algorandServiceProvider);

    if (activeAsset != null && accountState.account != null) {
      final frozen = activeAsset.params.defaultFrozen ?? false;
      try {
        await algorandService.toggleFreezeAsset(
          assetId: activeAsset.index,
          account: accountState.account!,
          freeze: !frozen,
        );

        final updatedAsset = Asset(
          index: activeAsset.index,
          createdAtRound: activeAsset.createdAtRound,
          deleted: activeAsset.deleted,
          destroyedAtRound: activeAsset.destroyedAtRound,
          params: AssetParameters(
            defaultFrozen: frozen,
            decimals: activeAsset.params.decimals,
            creator: activeAsset.params.creator,
            total: activeAsset.params.total,
          ),
        );

        ref.read(activeAssetProvider.notifier).setActiveAsset(updatedAsset);

        if (context.mounted) {
          _showSnackBar(
            message: !frozen ? 'Asset frozen' : 'Asset unfrozen',
            snackType: SnackType.success,
          );
        }
      } on AlgorandException catch (e) {
        final prunedMessage = _extractErrorMessage(e.message);
        if (context.mounted) {
          _showSnackBar(
            message: prunedMessage,
            snackType: SnackType.error,
          );
        }
      } catch (e) {
        if (context.mounted) {
          _showSnackBar(
            message:
                frozen ? 'Failed to freeze asset' : 'Failed to unfreeze asset',
            snackType: SnackType.error,
          );
        }
      } finally {
        isLoading.stopLoading();
      }
    }
  }

  String _extractErrorMessage(String errorMessage) {
    List<String> keywords = [
      'freeze not allowed',
    ];

    for (String keyword in keywords) {
      if (errorMessage.contains(keyword)) {
        // Make the first letter a capital.
        return keyword[0].toUpperCase() + keyword.substring(1);
      }
    }

    return 'An error occurred';
  }

  @override
  Widget build(BuildContext context) {
    final activeAsset = ref.watch(activeAssetProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kScreenPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colorScheme.surface,
            ),
            child: IconButton(
              padding: const EdgeInsets.all(kScreenPadding),
              icon: AppIcons.icon(
                icon: AppIcons.freeze,
                size: AppIcons.small,
                color: activeAsset?.params.defaultFrozen ?? false
                    ? context.colorScheme.primary
                    : context.colorScheme.onSurface,
              ),
              onPressed: () => _toggleFreezeAsset(context, ref),
            ),
          ),
        ],
      ),
    );
  }
}

final assetExpansionProvider = StateProvider<bool>((ref) => false);

class AssetExpansionToggle extends ConsumerWidget {
  const AssetExpansionToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpanded = ref.watch(assetExpansionProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: kScreenPadding / 2),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              ref.read(assetExpansionProvider.notifier).state = !isExpanded;
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isExpanded ? 'Less Information' : 'More Information',
                  style: context.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(width: kScreenPadding),
                isExpanded
                    ? AppIcons.icon(
                        icon: AppIcons.arrowDropup, size: AppIcons.large)
                    : AppIcons.icon(
                        icon: AppIcons.arrowDropdown, size: AppIcons.large),
              ],
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SizeTransition(
              sizeFactor: animation,
              axisAlignment: 0.0,
              child: child,
            );
          },
          child: isExpanded
              ? const AssetDetailsList(key: ValueKey(1))
              : const SizedBox(key: ValueKey(0)),
        ),
      ],
    );
  }
}

class AssetDetailsList extends ConsumerWidget {
  const AssetDetailsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAsset = ref.watch(activeAssetProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: kScreenPadding),
        AssetDetail(
            text: 'Decimals',
            value: activeAsset?.params.decimals.toString() ?? '0'),
        const SizedBox(height: kScreenPadding),
        AssetDetail(
          text: 'Total Supply',
          value: NumberShortener.format(
              double.parse(activeAsset?.params.total.toString() ?? '0')),
        ),
        const SizedBox(height: kScreenPadding),
        AssetDetail(
          text: 'Default Frozen',
          value: (activeAsset?.params.defaultFrozen ?? false) ? 'Yes' : 'No',
        ),
        const SizedBox(height: kScreenPadding),
        AssetDetail(
            text: 'Creator:',
            value: activeAsset?.params.creator ?? 'Not available',
            useEllipsis: true),
        const SizedBox(height: kScreenPadding),
        AssetDetail(
            text: 'Clawback:',
            value: activeAsset?.params.clawback ?? 'Not available',
            useEllipsis: true),
        const SizedBox(height: kScreenPadding),
        AssetDetail(
            text: 'Freeze:',
            value: activeAsset?.params.freeze ?? 'Not available',
            useEllipsis: true),
        const SizedBox(height: kScreenPadding),
        AssetDetail(
            text: 'Manager:',
            value: activeAsset?.params.manager ?? 'Not available',
            useEllipsis: true),
        const SizedBox(height: kScreenPadding),
        AssetDetail(
            text: 'Reserve:',
            value: activeAsset?.params.reserve ?? 'Not available',
            useEllipsis: true),
      ],
    );
  }
}

class AssetDetail extends StatelessWidget {
  final String text;
  final String value;
  final bool useEllipsis;

  const AssetDetail(
      {super.key,
      required this.text,
      required this.value,
      this.useEllipsis = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(text, style: context.textTheme.bodySmall),
        const SizedBox(width: kScreenPadding / 2),
        Expanded(
          child: useEllipsis
              ? EllipsizedText(
                  value,
                  ellipsis: '...',
                  type: EllipsisType.middle,
                  textAlign: TextAlign.right,
                  style: context.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                )
              : Text(
                  value,
                  textAlign: TextAlign.right,
                  style: context.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
        ),
        const SizedBox(height: kScreenPadding * 2),
      ],
    );
  }
}
