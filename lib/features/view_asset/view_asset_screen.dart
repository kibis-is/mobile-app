import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/dashboard/widgets/qr_dialog.dart';
import 'package:kibisis/models/detailed_asset.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/algorand_provider.dart';
import 'package:kibisis/routing/named_routes.dart';
import 'package:kibisis/utils/theme_extensions.dart';
// For clipboard functionality

final assetDetailsProvider =
    FutureProvider.family<DetailedAsset, String>((ref, assetId) async {
  return await ref.read(algorandServiceProvider).getDetailedAsset(assetId);
});

class ViewAssetScreen extends ConsumerWidget {
  final String assetId;

  const ViewAssetScreen({super.key, required this.assetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetDetails = ref.watch(assetDetailsProvider(assetId));
    final publicKey = ref.watch(accountProvider).account?.publicAddress ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asset Details'),
      ),
      body: assetDetails.when(
        loading: () => const CircularProgressIndicator(),
        error: (e, st) => Text('Error: $e'),
        data: (asset) {
          return buildAssetDetails(asset);
        },
      ),
      bottomNavigationBar: buildBottomNavigationBar(context, publicKey),
    );
  }

  Widget buildAssetDetails(DetailedAsset asset) {
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
          AssetDetail(
            text: 'Asset ID',
            value: asset.assetId.toString(),
          ),
          const AssetDetail(
            text: 'Type',
            value: '-',
          ),
          AssetDetail(
            text: 'Decimals',
            value: asset.decimals.toString(),
          ),
          AssetDetail(
            text: 'Total Supply',
            value: asset.totalSupply.toString(),
          ),
          AssetDetail(
            text: 'Default Frozen',
            value: asset.defaultFrozen == true ? "Yes" : "No",
          ),
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
      ),
    );
  }

  Widget buildBottomNavigationBar(BuildContext context, String publicKey) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () => context.pushNamed(
              sendTransactionWithAssetIdRouteName,
              pathParameters: {
                'mode': 'asset',
                'assetId': assetId,
              },
            ),
            child: const Text('Send'),
          ),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => QrDialog(
                  qrData: publicKey,
                ),
              );
            },
            child: const Text('Receive'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: context.textTheme.bodySmall,
        ),
        const SizedBox(width: kScreenPadding),
        useEllipsis
            ? EllipsizedText(
                value,
                ellipsis: '...',
                type: EllipsisType.middle,
                textAlign: TextAlign.left,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              )
            : Text(
                value,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
        const SizedBox(height: kScreenPadding * 2),
      ],
    );
  }
}
