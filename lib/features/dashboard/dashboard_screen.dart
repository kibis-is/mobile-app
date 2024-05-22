import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_appbar.dart';
import 'package:kibisis/common_widgets/custom_bottom_sheet.dart';
import 'package:kibisis/common_widgets/initialising_animation.dart';
import 'package:kibisis/models/asset.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/dashboard/widgets/dashboard_info_panel.dart';
import 'package:kibisis/features/dashboard/widgets/dashboard_tab_controller.dart';
import 'package:kibisis/features/dashboard/widgets/network_select.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/algorand_provider.dart';
import 'package:kibisis/providers/network_provider.dart';

class DashboardScreen extends ConsumerWidget {
  static String title = 'Dashboard';
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networks = ref.watch(networkProvider).getNetworks();
    List<MockAsset> assets = [
      MockAsset(
          name: "USDC",
          subtitle: 'Test Data 1',
          image: 'assets/images/usd-coin-logo.svg',
          value: 0),
      MockAsset(
          name: "USDC",
          subtitle: 'Test Data 2',
          image: 'assets/images/usd-coin-logo.svg',
          value: 0),
    ];

    List<String> tabs = ['Assets', 'NTFs', 'Activity'];

    final accountState = ref.watch(accountProvider);

    final algorandService = ref.watch(algorandServiceProvider);

    return Scaffold(
      appBar: SplitAppBar(
        leadingWidget: Row(
          children: [
            Text('Balance:', style: Theme.of(context).textTheme.bodySmall),
            FutureBuilder<String>(
              future: algorandService
                  .getAccountBalance(accountState.account?.publicAddress ?? ''),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AnimatedDots(); // Show animated dots while waiting
                } else if (snapshot.hasError) {
                  return const Text('Error'); // Handle the error case
                } else if (snapshot.hasData) {
                  return Text(
                    snapshot.data!,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(fontWeight: FontWeight.bold),
                  );
                } else {
                  return const Text(
                      'No Data'); // Handle the case where there's no data
                }
              },
            ),
            SvgPicture.asset(
              networks[0].icon,
              semanticsLabel: networks[0].name,
              height: 12,
              colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.onBackground,
                  BlendMode.srcATop),
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              color: Theme.of(context).colorScheme.primary,
              iconSize: kScreenPadding,
              onPressed: () {
                customBottomSheet(
                    context: context, items: [], header: "Info", isIcon: true);
              },
            ),
          ],
        ),
        actionWidget: MaterialButton(
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
                buttonOnPressed: () => GoRouter.of(context).go('/addAsset'));
          },
          child: NetworkSelect(networks: networks),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
        child: Column(
          children: [
            const SizedBox(
              height: kScreenPadding,
            ),
            DashboardInfoPanel(networks: networks, accountState: accountState),
            const SizedBox(
              height: kScreenPadding,
            ),
            Expanded(
              child: DashboardTabController(tabs: tabs, assets: assets),
            ),
            const SizedBox(
              height: kScreenPadding,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () => GoRouter.of(context).go('/settings'),
                ),
                IconButton(
                  icon: const Icon(Icons.account_balance_wallet),
                  onPressed: () => GoRouter.of(context).push('/wallets'),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
