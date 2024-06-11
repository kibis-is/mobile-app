import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/models/detailed_asset.dart';
import 'package:kibisis/providers/algorand_provider.dart';
import 'package:kibisis/routing/named_routes.dart';
import 'package:kibisis/utils/copy_to_clipboard.dart';
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
    );
  }

  Widget buildAssetDetails(
      DetailedAsset asset, WidgetRef ref, BuildContext context) {
    final isExpanded = ref.watch(viewMoreProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(kScreenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: kScreenPadding,
          ),
          AssetDetail(
            text: 'Asset Name',
            value: asset.name ?? 'Unnamed Asset',
          ),
          Row(
            children: [
              Expanded(
                child: AssetDetail(
                  text: 'Asset ID',
                  value: asset.assetId.toString(),
                ),
              ),
              InkWell(
                  onTap: () =>
                      copyToClipboard(context, asset.assetId.toString()),
                  child: const Padding(
                    padding: EdgeInsets.only(left: kScreenPadding),
                    child: Icon(Icons.copy),
                  )),
            ],
          ),
          const AssetDetail(
            text: 'Type',
            value: '-',
          ),
          if (isExpanded) ...[
            AssetDetail(
              text: 'Creator Account',
              value: asset.creator ?? 'Not available',
              useEllipsis: true,
            ),
            AssetDetail(
              text: 'Clawback Account',
              value: asset.clawback ?? 'Not available',
              useEllipsis: true,
            ),
            AssetDetail(
              text: 'Freeze Account',
              value: asset.freeze ?? 'Not available',
              useEllipsis: true,
            ),
            AssetDetail(
              text: 'Manager Account',
              value: asset.manager ?? 'Not available',
              useEllipsis: true,
            ),
            AssetDetail(
              text: 'Reserve Account',
              value: asset.reserve ?? 'Not available',
              useEllipsis: true,
            ),
          ],
          TextButton(
            onPressed: () {
              ref.read(viewMoreProvider.notifier).state = !isExpanded;
            },
            child: Text(isExpanded ? 'View Less' : 'View More'),
          ),
          const SizedBox(
            height: kScreenPadding,
          ),
          CustomButton(
            text: 'Send',
            isFullWidth: true,
            onPressed: () => context.pushNamed(
              sendTransactionWithAssetIdRouteName,
              pathParameters: {
                'mode': 'asset',
                'assetId': asset.assetId.toString(),
              },
            ),
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
