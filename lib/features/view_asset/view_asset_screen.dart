import 'package:algorand_dart/algorand_dart.dart';
import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/dashboard/widgets/qr_dialog.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/algorand_provider.dart';
import 'package:kibisis/routing/named_routes.dart';
import 'package:kibisis/utils/theme_extensions.dart';

final assetDetailsProvider =
    FutureProvider.family<Asset, String>((ref, assetId) async {
  return await ref.read(algorandServiceProvider).getAssetDetails(assetId);
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (asset) {
          return _buildAssetDetails(asset);
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context, publicKey),
    );
  }

  Widget _buildAssetDetails(Asset asset) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(kScreenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: kScreenPadding),
          AssetDetail(
            text: 'Asset Name',
            value: asset.params.name ?? 'Unnamed Asset',
          ),
          AssetDetail(
            text: 'Asset ID',
            value: asset.index.toString(),
          ),
          const AssetDetail(
            text: 'Type',
            value: '-',
          ),
          AssetDetail(
            text: 'Decimals',
            value: asset.params.decimals.toString(),
          ),
          AssetDetail(
            text: 'Total Supply',
            value: asset.params.total.toString(),
          ),
          AssetDetail(
            text: 'Default Frozen',
            value: asset.params.defaultFrozen == true ? "Yes" : "No",
          ),
          AssetDetail(
            text: 'Creator Account',
            value: asset.params.creator,
            useEllipsis: true,
          ),
          AssetDetail(
            text: 'Clawback Account',
            value: asset.params.clawback ?? 'Not available',
            useEllipsis: true,
          ),
          AssetDetail(
            text: 'Freeze Account',
            value: asset.params.freeze ?? 'Not available',
            useEllipsis: true,
          ),
          AssetDetail(
            text: 'Manager Account',
            value: asset.params.manager ?? 'Not available',
            useEllipsis: true,
          ),
          AssetDetail(
            text: 'Reserve Account',
            value: asset.params.reserve ?? 'Not available',
            useEllipsis: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, String publicKey) {
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
