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
import 'package:kibisis/features/dashboard/providers/assets_fetched_provider.dart';
import 'package:kibisis/features/dashboard/widgets/dashboard_info_panel.dart';
import 'package:kibisis/features/dashboard/widgets/dashboard_tab_controller.dart';
import 'package:kibisis/features/dashboard/widgets/network_select.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/balance_provider.dart';
import 'package:kibisis/providers/network_provider.dart';
import 'package:kibisis/providers/active_account_provider.dart';
import 'package:kibisis/providers/storage_provider.dart';
import 'package:kibisis/routing/named_routes.dart';
import 'package:kibisis/utils/refresh_account_data.dart';
import 'package:kibisis/utils/theme_extensions.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  static String title = 'Dashboard';
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends ConsumerState<DashboardScreen> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _checkAndFetchAssets();
      _onRefresh();
    });
  }

  void _onRefresh() async {
    final accountState = ref.read(accountProvider);
    final publicAddress = accountState.account?.publicAddress ?? '';

    if (publicAddress.isNotEmpty) {
      if (mounted) {
        refreshAccountData(context, ref, publicAddress);
      }
      _refreshController.refreshCompleted();
    } else {
      _refreshController.refreshFailed();
    }
  }

  void _checkAndFetchAssets() {
    final accountState = ref.read(accountProvider);
    final publicAddress = accountState.account?.publicAddress ?? '';
    final assetsFetched = ref.read(accountDataFetchStatusProvider);

    if (publicAddress.isNotEmpty && !assetsFetched) {
      refreshAccountData(context, ref, publicAddress);
      ref.read(accountDataFetchStatusProvider.notifier).setFetched(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final networks = networkOptions;
    final activeAccountId = ref.watch(activeAccountProvider);
    final storageService = ref.watch(storageProvider);
    final accountStateFuture =
        _getAccountStateFuture(storageService, activeAccountId);
    final accountState = ref.watch(accountProvider);

    List<String> tabs = ['Assets', 'NFTs', 'Activity'];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndFetchAssets();
    });

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
              child: SmartRefresher(
                enablePullDown: true,
                enablePullUp: false,
                header: const WaterDropHeader(),
                controller: _refreshController,
                onRefresh: _onRefresh,
                child: DashboardTabController(tabs: tabs),
              ),
            ),
            _buildBottomNavigationBar(context),
          ],
        ),
      ),
      floatingActionButton: CustomFloatingActionButton(
        icon: Icons.send,
        onPressed: () => context.goNamed(
          sendTransactionRouteName,
          pathParameters: {
            'mode': 'payment',
          },
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
    final balanceAsync = ref.watch(balanceProvider);
    return Row(
      children: [
        Text('Balance:', style: context.textTheme.bodySmall),
        balanceAsync.when(
          data: (balance) {
            return Row(
              children: [
                Text(
                  balance,
                  style: context.textTheme.bodySmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.primary),
                ),
                SvgPicture.asset(
                  networks[0].icon,
                  semanticsLabel: networks[0].name,
                  height: 12,
                  colorFilter: ColorFilter.mode(
                      context.colorScheme.primary, BlendMode.srcATop),
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  color: context.colorScheme.onBackground,
                  iconSize: kScreenPadding,
                  onPressed: () {
                    customBottomSheet(
                        context: context,
                        items: [],
                        header: "Info",
                        isIcon: true,
                        onPressed: (SelectItem item) {});
                  },
                ),
              ],
            );
          },
          loading: () =>
              const AnimatedDots(), // Show animated dots while waiting
          error: (error, stack) => const Text('Error'), // Handle the error case
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
      child: const NetworkSelect(),
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
              icon: const Icon(Icons.settings),
              color: context.colorScheme.onBackground,
              onPressed: () => GoRouter.of(context).go('/settings'),
            ),
            IconButton(
              icon: const Icon(Icons.account_balance_wallet),
              color: context.colorScheme.onBackground,
              onPressed: () => GoRouter.of(context).push('/wallets'),
            ),
          ],
        ),
      ],
    );
  }
}
