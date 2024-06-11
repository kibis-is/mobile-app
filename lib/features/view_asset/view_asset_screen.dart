import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/models/detailed_asset.dart';
import 'package:kibisis/providers/algorand_provider.dart';
import 'package:kibisis/routing/named_routes.dart';
import 'package:kibisis/theme/color_palette.dart';
import 'package:kibisis/utils/copy_to_clipboard.dart';
import 'package:kibisis/utils/number_shortener.dart';
import 'package:kibisis/utils/theme_extensions.dart';
// For clipboard functionality

final assetDetailsProvider =
    FutureProvider.family<DetailedAsset, String>((ref, assetId) async {
  return await ref.read(algorandServiceProvider).getDetailedAsset(assetId);
});

final viewMoreProvider = StateProvider<bool>((ref) => false);

class ViewAssetScreen extends ConsumerWidget {
  final String assetId;

  const ViewAssetScreen({super.key, required this.assetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetDetails = ref.watch(assetDetailsProvider(assetId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asset Details'),
      ),
      body: assetDetails.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Text('Error: $e'),
        data: (asset) {
          return buildAssetDetails(asset, ref, context);
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
            left: kScreenPadding,
            right: kScreenPadding,
            bottom: kScreenPadding / 2),
        child: CustomButton(
          text: 'Send',
          isFullWidth: true,
          onPressed: () => context.pushNamed(
            sendTransactionWithAssetIdRouteName,
            pathParameters: {
              'mode': 'asset',
              'assetId': assetId,
            },
          ),
        ),
      ),
    );
  }

  Widget buildAssetDetails(
      DetailedAsset asset, WidgetRef ref, BuildContext context) {
    final isExpanded = ref.watch(viewMoreProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(kScreenPadding),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(kScreenPadding),
                decoration: BoxDecoration(
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
                        colorFilter: const ColorFilter.mode(
                            Colors.white, BlendMode.srcATop),
                      ),
                    ),
                    const SizedBox(height: kScreenPadding),
                    Text(
                      asset.name ?? 'Unnamed Asset',
                      style: context.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
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
                        backgroundColor: ColorPalette.cardGradientMediumBlue,
                      )
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
                        asset.assetId.toString(),
                        style: context.textTheme.bodySmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      InkWell(
                        onTap: () =>
                            copyToClipboard(context, asset.assetId.toString()),
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
              if (asset.isFrozen) ...[
                const Positioned(
                  right: 0,
                  bottom: 0,
                  child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: kScreenPadding / 2,
                          vertical: kScreenPadding),
                      child: Icon(
                        Icons.ac_unit,
                      )),
                ),
              ],
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: kScreenPadding / 2,
              ),
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
                    const SizedBox(
                      width: kScreenPadding,
                    ),
                    const Icon(
                      Icons.arrow_drop_down,
                    ),
                  ],
                ),
              ),
              if (isExpanded) ...[
                const SizedBox(
                  height: kScreenPadding,
                ),
                AssetDetail(
                  text: 'Decimals',
                  value: asset.decimals.toString(),
                ),
                const SizedBox(
                  height: kScreenPadding,
                ),
                AssetDetail(
                  text: 'Total Supply',
                  value: NumberShortener.format(
                      double.parse(asset.totalSupply.toString())),
                ),
                const SizedBox(
                  height: kScreenPadding,
                ),
                AssetDetail(
                  text: 'Default Frozen',
                  value: (asset.defaultFrozen ?? false) ? 'Yes' : 'No',
                ),
                const SizedBox(
                  height: kScreenPadding,
                ),
                AssetDetail(
                  text: 'Creator Account',
                  value: asset.creator ?? 'Not available',
                  useEllipsis: true,
                ),
                const SizedBox(
                  height: kScreenPadding,
                ),
                AssetDetail(
                  text: 'Clawback Account',
                  value: asset.clawback ?? 'Not available',
                  useEllipsis: true,
                ),
                const SizedBox(
                  height: kScreenPadding,
                ),
                AssetDetail(
                  text: 'Freeze Account',
                  value: asset.freeze ?? 'Not available',
                  useEllipsis: true,
                ),
                const SizedBox(
                  height: kScreenPadding,
                ),
                AssetDetail(
                  text: 'Manager Account',
                  value: asset.manager ?? 'Not available',
                  useEllipsis: true,
                ),
                const SizedBox(
                  height: kScreenPadding,
                ),
                AssetDetail(
                  text: 'Reserve Account',
                  value: asset.reserve ?? 'Not available',
                  useEllipsis: true,
                ),
              ],
            ],
          ),
        ],
      ),
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
        Text(
          text,
          style: context.textTheme.bodySmall,
        ),
        const SizedBox(width: kScreenPadding / 2),
        Expanded(
          child: useEllipsis
              ? EllipsizedText(
                  value,
                  ellipsis: '...',
                  type: EllipsisType.middle,
                  textAlign: TextAlign.right,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                )
              : Text(
                  value,
                  textAlign: TextAlign.right,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        const SizedBox(height: kScreenPadding * 2),
      ],
    );
  }
}
