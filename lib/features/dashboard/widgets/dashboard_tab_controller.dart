import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/common_widgets/custom_tab_bar.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/dashboard/widgets/activity_tab.dart';
import 'package:kibisis/features/dashboard/widgets/assets_tab.dart';

class DashboardTabController extends ConsumerWidget {
  const DashboardTabController({
    super.key,
    required this.tabs,
  });

  final List<String> tabs;

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
            const Expanded(
              child: TabBarView(
                children: [
                  AssetsTab(),
                  //TODO: Implement NFTs
                  // NftTab(),
                  ActivityTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
