import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/active_asset_provider.dart';
import 'package:kibisis/providers/assets_provider.dart';
import 'package:kibisis/providers/storage_provider.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/common_widgets/confirmation_dialog.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'view_asset_body.dart';

class ViewAssetScreen extends ConsumerStatefulWidget {
  final AssetScreenMode mode;
  final bool isPanelMode;

  const ViewAssetScreen({
    super.key,
    this.mode = AssetScreenMode.view,
    this.isPanelMode = false,
  });

  @override
  ViewAssetScreenState createState() => ViewAssetScreenState();
}

class ViewAssetScreenState extends ConsumerState<ViewAssetScreen> {
  @override
  Widget build(BuildContext context) {
    final activeAsset = ref.watch(activeAssetProvider);
    if (activeAsset == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
              widget.mode == AssetScreenMode.view ? 'View Asset' : 'Add Asset'),
        ),
        body: const Center(
          child: Text('No asset available to display.'),
        ),
      );
    }

    final isArc200FromStorage =
        activeAsset.assetType == AssetType.arc200 && activeAsset.amount == 0;

    final actions = [
      if (isArc200FromStorage)
        IconButton(
          icon: AppIcons.icon(icon: AppIcons.delete),
          tooltip: 'Opt-out',
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => const ConfirmationDialog(
                title: 'Opt Out of Asset?',
                content:
                    'Are you sure you want to opt out of this ARC-0200 asset?',
                yesText: 'Opt Out',
                noText: 'Cancel',
              ),
            );

            if (confirmed == true) {
              final accountId =
                  await ref.read(accountProvider.notifier).getAccountId();
              if (accountId != null) {
                await ref
                    .read(storageProvider)
                    .unfollowArc200Asset(accountId, activeAsset.index);
                ref.invalidate(assetsProvider);
                if (context.mounted) {
                  GoRouter.of(context).pop();
                }
              }
            }
          },
        ),
    ];

    if (!widget.isPanelMode) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
              widget.mode == AssetScreenMode.view ? 'View Asset' : 'Add Asset'),
          actions: actions,
        ),
        body: ViewAssetBody(asset: activeAsset),
      );
    }

    return ViewAssetBody(
      asset: activeAsset,
      actions: actions,
    );
  }
}
