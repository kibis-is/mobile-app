import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_bottom_sheet.dart';
import 'package:kibisis/common_widgets/models/asset.dart';
import 'package:kibisis/common_widgets/models/menu_item.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/dashboard/widgets/dashboard_info_panel.dart';
import 'package:kibisis/features/dashboard/widgets/dashboard_tab_controller.dart';
import 'package:kibisis/features/dashboard/widgets/network_select.dart';
import 'package:kibisis/features/dashboard/widgets/wallet_drawer.dart';

class Dashboard extends StatelessWidget {
  static String title = 'Dashboard';
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    //TODO: get real data for networks
    List<MenuItem> networks = [
      MenuItem(
        name: "Algorand",
        image: 'assets/images/algorand-logo.svg',
      ),
      MenuItem(
        name: "Optimism",
        image: 'assets/images/optimism-logo.svg',
      ),
    ];

    List<Asset> assets = [
      Asset(
          name: "USDC",
          subtitle: 'USDC',
          image: 'assets/images/usd-coin-logo.svg',
          value: 0),
      Asset(
          name: "USDC",
          subtitle: 'USDC',
          image: 'assets/images/usd-coin-logo.svg',
          value: 0),
    ];

    List<String> tabs = ['Assets', 'NTFS', 'Activity'];

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: kScreenPadding),
            child: MaterialButton(
              hoverColor: Theme.of(context).colorScheme.surface,
              color: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              onPressed: () {
                customBottomSheet(
                    context: context,
                    header: "Select Network",
                    items: networks,
                    hasButton: true,
                    buttonText: "Add Network",
                    onPressed: () => GoRouter.of(context).go('/addAsset'));
              },
              child: NetworkSelect(networks: networks),
            ),
          ),
        ],
      ),
      drawer: const WalletDrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
        child: Column(
          children: [
            const SizedBox(
              height: kScreenPadding,
            ),
            DashboardInfoPanel(networks: networks),
            const SizedBox(
              height: kScreenPadding,
            ),
            Expanded(
              child: DashboardTabController(tabs: tabs, assets: assets),
            ),
            const SizedBox(
              height: kScreenPadding,
            ),
          ],
        ),
      ),
    );
  }
}
