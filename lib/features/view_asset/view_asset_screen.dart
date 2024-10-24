import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/models/combined_asset.dart';
import 'package:kibisis/providers/active_asset_provider.dart';
import 'view_asset_body.dart';

class ViewAssetScreen extends ConsumerStatefulWidget {
  final AssetScreenMode mode;
  final CombinedAsset? asset;
  final bool isPanelMode;

  const ViewAssetScreen({
    super.key,
    this.mode = AssetScreenMode.view,
    this.asset,
    this.isPanelMode = false,
  });

  @override
  ViewAssetScreenState createState() => ViewAssetScreenState();
}

class ViewAssetScreenState extends ConsumerState<ViewAssetScreen> {
  @override
  Widget build(BuildContext context) {
    final activeAsset = widget.asset ?? ref.watch(activeAssetProvider);
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

    if (!widget.isPanelMode) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
              widget.mode == AssetScreenMode.view ? 'View Asset' : 'Add Asset'),
        ),
        body: ViewAssetBody(asset: activeAsset),
      );
    }
    return ViewAssetBody(asset: activeAsset);
  }
}
