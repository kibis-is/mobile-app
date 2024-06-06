import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/common_widgets/custom_tab_bar.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/dashboard/widgets/activity_tab.dart';
import 'package:kibisis/features/dashboard/widgets/assets_tab.dart';
import 'package:kibisis/models/detailed_asset.dart';

class DashboardTabController extends ConsumerWidget {
  const DashboardTabController({
    super.key,
    required this.tabs,
    required this.assets,
  });

  final List<String> tabs;
  final List<DetailedAsset> assets;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: tabs.length,
      child: Container(
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTabBar(
              tabs: tabs,
            ),
            const SizedBox(
              height: kScreenPadding,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  AssetsTab(assets: assets),
                  const Center(
                    child: Text('No NFTs'),
                  ),
                  const ActivityTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
