import 'package:algorand_dart/algorand_dart.dart';
import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/common_widgets/frozen_box_decoration.dart';
import 'package:kibisis/common_widgets/top_snack_bar.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/settings/appearance/providers/dark_mode_provider.dart';
import 'package:kibisis/features/view_asset/providers/view_asset_provider.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/active_asset_provider.dart';
import 'package:kibisis/providers/algorand_provider.dart';
import 'package:kibisis/providers/loading_provider.dart';
import 'package:kibisis/routing/named_routes.dart';
import 'package:kibisis/theme/color_palette.dart';
import 'package:kibisis/utils/copy_to_clipboard.dart';
import 'package:kibisis/utils/number_shortener.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class ViewAssetScreen extends ConsumerWidget {
  const ViewAssetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(activeAssetProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asset Details'),
      ),
      body: const AssetDetailsView(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
            left: kScreenPadding,
            right: kScreenPadding,
            bottom: kScreenPadding / 2),
        child: CustomButton(
          text: 'Send',
          isFullWidth: true,
          onPressed: () => context.pushNamed(
            sendTransactionRouteName,
            pathParameters: {
              'mode': 'asset',
            },
          ),
        ),
      ),
    );
  }
}

class AssetDetailsView extends ConsumerWidget {
  const AssetDetailsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpanded = ref.watch(viewMoreProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(kScreenPadding),
      child: Column(
        children: [
          const AssetHeader(),
          const AssetControls(),
          AssetExpansionToggle(isExpanded: isExpanded),
          if (isExpanded) const AssetDetailsList(),
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
          decoration: activeAsset?.isFrozen ?? false
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
                  width: 50,
                  height: 50,
                  'assets/images/voi-asset-icon.svg',
                  semanticsLabel: 'VOI Logo',
                  colorFilter:
                      const ColorFilter.mode(Colors.white, BlendMode.srcATop),
                ),
              ),
              const SizedBox(height: kScreenPadding),
              Text(
                activeAsset?.name ?? 'Unnamed Asset',
                style: context.textTheme.titleLarge?.copyWith(
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
                  activeAsset?.assetId.toString() ?? '',
                  style: context.textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                InkWell(
                  onTap: () => copyToClipboard(
                      context, activeAsset?.assetId.toString() ?? ''),
                  child: Padding(
                    padding: const EdgeInsets.only(left: kScreenPadding),
                    child: Icon(
                      Icons.copy,
                      color: context.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (activeAsset?.isFrozen ?? false)
          const Positioned(
            right: 0,
            bottom: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: kScreenPadding / 2, vertical: kScreenPadding),
              child: Icon(Icons.ac_unit),
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
      try {
        await algorandService.toggleFreezeAsset(
          assetId: activeAsset.assetId,
          account: accountState.account!,
          freeze: !activeAsset.isFrozen,
        );

        ref.read(activeAssetProvider.notifier).setActiveAsset(
              activeAsset.copyWith(
                isFrozen: !activeAsset.isFrozen,
              ),
            );

        if (context.mounted) {
          _showSnackBar(
            message: activeAsset.isFrozen ? 'Asset frozen' : 'Asset unfrozen',
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
            message: activeAsset.isFrozen
                ? 'Failed to freeze asset'
                : 'Failed to unfreeze asset',
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
    final accountState = ref.watch(accountProvider);

    final canShowFreezeButton =
        accountState.account?.publicAddress == activeAsset?.freeze;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kScreenPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (canShowFreezeButton)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colorScheme.surface,
              ),
              child: IconButton(
                padding: const EdgeInsets.all(kScreenPadding),
                icon: Icon(
                  Icons.ac_unit_rounded,
                  color: activeAsset?.isFrozen ?? false
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

class AssetExpansionToggle extends ConsumerWidget {
  final bool isExpanded;

  const AssetExpansionToggle({super.key, required this.isExpanded});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: kScreenPadding / 2),
        InkWell(
          onTap: () {
            ref.read(viewMoreProvider.notifier).state = !isExpanded;
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
              const Icon(Icons.arrow_drop_down),
            ],
          ),
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
            text: 'Decimals', value: activeAsset?.decimals.toString() ?? '0'),
        const SizedBox(height: kScreenPadding),
        AssetDetail(
          text: 'Total Supply',
          value: NumberShortener.format(
              double.parse(activeAsset?.totalSupply.toString() ?? '0')),
        ),
        const SizedBox(height: kScreenPadding),
        AssetDetail(
          text: 'Default Frozen',
          value: (activeAsset?.defaultFrozen ?? false) ? 'Yes' : 'No',
        ),
        const SizedBox(height: kScreenPadding),
        AssetDetail(
            text: 'Creator Account',
            value: activeAsset?.creator ?? 'Not available',
            useEllipsis: true),
        const SizedBox(height: kScreenPadding),
        AssetDetail(
            text: 'Clawback Account',
            value: activeAsset?.clawback ?? 'Not available',
            useEllipsis: true),
        const SizedBox(height: kScreenPadding),
        AssetDetail(
            text: 'Freeze Account',
            value: activeAsset?.freeze ?? 'Not available',
            useEllipsis: true),
        const SizedBox(height: kScreenPadding),
        AssetDetail(
            text: 'Manager Account',
            value: activeAsset?.manager ?? 'Not available',
            useEllipsis: true),
        const SizedBox(height: kScreenPadding),
        AssetDetail(
            text: 'Reserve Account',
            value: activeAsset?.reserve ?? 'Not available',
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
                  style: context.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                )
              : Text(
                  value,
                  textAlign: TextAlign.right,
                  style: context.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
        ),
        const SizedBox(height: kScreenPadding * 2),
      ],
    );
  }
}
