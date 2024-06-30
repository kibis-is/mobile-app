import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_appbar.dart';
import 'package:kibisis/common_widgets/custom_bottom_sheet.dart';
import 'package:kibisis/common_widgets/custom_dropdown.dart';
import 'package:kibisis/common_widgets/custom_floating_action_button.dart';
import 'package:kibisis/common_widgets/initialising_animation.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/dashboard/widgets/dashboard_info_panel.dart';
import 'package:kibisis/features/dashboard/widgets/dashboard_tab_controller.dart';
import 'package:kibisis/features/dashboard/widgets/network_select.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/assets_provider.dart';
import 'package:kibisis/providers/balance_provider.dart';
import 'package:kibisis/providers/minimum_balance_provider.dart';
import 'package:kibisis/providers/network_provider.dart';
import 'package:kibisis/providers/active_account_provider.dart';
import 'package:kibisis/providers/storage_provider.dart';
import 'package:kibisis/routing/named_routes.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  static String title = 'Dashboard';
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final networks = networkOptions;
    final activeAccountId = ref.watch(activeAccountProvider);
    final storageService = ref.watch(storageProvider);
    final accountStateFuture =
        _getAccountStateFuture(storageService, activeAccountId);
    final accountState = ref.watch(accountProvider);
    final assets = ref.watch(assetsProvider);

    List<String> tabs = ['Assets', 'Activity'];

    Widget buildFloatingActionButton() {
      return Hero(
        tag: 'fab',
        child: CustomFloatingActionButton(
          key: const ValueKey('fab'),
          icon: AppIcons.send,
          onPressed: () => context.goNamed(
            sendTransactionRouteName,
            pathParameters: {
              'mode': 'payment',
            },
          ),
        ),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(context, ref, networks, accountState),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
        child: Column(
          children: [
            const SizedBox(height: kScreenPadding),
            _buildDashboardInfoPanel(
                context, ref, networks, accountStateFuture, accountState),
            const SizedBox(height: kScreenPadding),
            Expanded(
              child: DashboardTabController(tabs: tabs),
            ),
            _buildBottomNavigationBar(context),
          ],
        ),
      ),
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.bounceIn,
        switchOutCurve: Curves.easeOut,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: const Offset(0, 0),
            ).animate(animation),
            child: child,
          );
        },
        child: assets.when(
          data: (assetList) => buildFloatingActionButton(),
          loading: () => const SizedBox.shrink(key: ValueKey('loading')),
          error: (err, stack) => buildFloatingActionButton(),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Future<String?> _getAccountStateFuture(
      StorageService storageService, String? activeAccountId) {
    return storageService.getAccountData(activeAccountId ?? '', 'publicKey');
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref,
      List<SelectItem> networks, AccountState accountState) {
    return SplitAppBar(
      leadingWidget: _buildBalanceWidget(context, ref, networks, accountState),
      actionWidget: _buildNetworkSelectButton(context, networks, ref),
    );
  }

  Widget _buildBalanceWidget(BuildContext context, WidgetRef ref,
      List<SelectItem> networks, AccountState accountState) {
    final balanceAsync = ref.watch(balanceNotifierProvider);
    return Row(
      children: [
        balanceAsync.when(
          data: (balance) => Row(
            children: [
              EllipsizedText(
                type: EllipsisType.end,
                ellipsis: '...',
                balance.toStringAsFixed(2),
                style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.primary),
              ),
              SvgPicture.asset(
                'assets/images/${networks[0].icon}.svg',
                semanticsLabel: networks[0].name,
                height: 12,
                colorFilter: ColorFilter.mode(
                    context.colorScheme.primary, BlendMode.srcATop),
              ),
              IconButton(
                icon: AppIcons.icon(icon: AppIcons.info, size: AppIcons.small),
                color: context.colorScheme.onBackground,
                iconSize: kScreenPadding,
                onPressed: () {
                  customBottomSheet(
                      context: context,
                      singleWidget: Text(
                        'Minimum balance is ${ref.watch(minimumBalanceProvider).toStringAsFixed(2)} VOI. Based on the account configuration, this is the minimum balance needed to keep the account open.',
                        softWrap: true,
                        style: context.textTheme.bodyMedium,
                      ),
                      header: "Info",
                      onPressed: (SelectItem item) {});
                },
              ),
            ],
          ),
          loading: () =>
              const AnimatedDots(), // Show animated dots while waiting
          error: (error, stack) => const Text('Error'),
        ),
      ],
    );
  }

  Widget _buildNetworkSelectButton(
      BuildContext context, List<SelectItem> networks, WidgetRef ref) {
    return MaterialButton(
      hoverColor: context.colorScheme.surface,
      color: context.colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kScreenPadding / 2),
      ),
      onPressed: networks.length > 1
          ? () {
              customBottomSheet(
                  context: context,
                  header: "Select Network",
                  items: networks,
                  hasButton: false,
                  buttonText: "Add Network",
                  buttonOnPressed: () {
                    GoRouter.of(context).go('/addAsset');
                  },
                  onPressed: (SelectItem selectedNetwork) {
                    ref
                        .read(networkProvider.notifier)
                        .setNetwork(selectedNetwork);
                  });
            }
          : null,
      child: NetworkSelect(networkCount: networks.length),
    );
  }

  Widget _buildDashboardInfoPanel(
      BuildContext context,
      WidgetRef ref,
      List<SelectItem> networks,
      Future<String?> accountStateFuture,
      AccountState accountState) {
    return FutureBuilder<String?>(
      future: accountStateFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Text('Error fetching account data');
        } else if (snapshot.hasData && snapshot.data != null) {
          final publicKey = snapshot.data!;
          return DashboardInfoPanel(
            networks: networks,
            accountState: accountState,
            publicKey: publicKey,
          );
        } else {
          return const Text('No account data available');
        }
      },
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon:
                  AppIcons.icon(icon: AppIcons.settings, size: AppIcons.medium),
              color: context.colorScheme.onBackground,
              onPressed: () => GoRouter.of(context).go('/settings'),
            ),
            IconButton(
              icon: AppIcons.icon(icon: AppIcons.wallet, size: AppIcons.medium),
              color: context.colorScheme.onBackground,
              onPressed: () => GoRouter.of(context).push('/wallets'),
            ),
          ],
        ),
      ],
    );
  }
}
