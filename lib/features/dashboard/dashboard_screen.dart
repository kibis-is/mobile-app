import 'dart:io';

import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_appbar.dart';
import 'package:kibisis/common_widgets/custom_bottom_sheet.dart';
import 'package:kibisis/common_widgets/custom_fab_child.dart';
import 'package:kibisis/common_widgets/initialising_animation.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/dashboard/widgets/activity_tab.dart';
import 'package:kibisis/features/dashboard/widgets/assets_tab.dart';
import 'package:kibisis/features/dashboard/widgets/dashboard_info_panel.dart';
import 'package:kibisis/features/dashboard/widgets/network_select.dart';
import 'package:kibisis/features/dashboard/widgets/nft_tab.dart';
import 'package:kibisis/features/scan_qr/qr_code_scanner_logic.dart';
import 'package:kibisis/features/settings/appearance/providers/dark_mode_provider.dart';
import 'package:kibisis/models/select_item.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/balance_provider.dart';
import 'package:kibisis/providers/minimum_balance_provider.dart';
import 'package:kibisis/providers/network_provider.dart';
import 'package:kibisis/routing/named_routes.dart';
import 'package:kibisis/theme/color_palette.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/number_shortener.dart';
import 'package:kibisis/utils/theme_extensions.dart';
import 'package:vibration/vibration.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  static String title = 'Dashboard';
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;
  final _key = GlobalKey<ExpandableFabState>();
  final PageController _pageController = PageController();
  final List<Widget> _pages = const [AssetsTab(), NftTab(), ActivityTab()];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final networks = networkOptions;
    final accountState = ref.watch(accountProvider);
    final publicKey = accountState.account?.address;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBar(context, ref, networks, accountState),
      body: Column(
        children: [
          const SizedBox(height: kScreenPadding),
          _buildDashboardInfoPanel(
              context, ref, networks, publicKey, accountState),
          const SizedBox(height: kScreenPadding / 2),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (int index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: _pages,
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: ExpandableFab.location,
      bottomNavigationBar: _buildNavigationBar(),
    );
  }

  Widget _buildNavigationBar() {
    ref.watch(isDarkModeProvider);

    return NavigationBarTheme(
      data: NavigationBarThemeData(
        labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>((states) {
          if (states.contains(MaterialState.selected)) {
            return context.textTheme.labelMedium?.copyWith(
                    color: context.colorScheme.primary,
                    fontWeight: FontWeight.bold) ??
                const TextStyle();
          }
          return context.textTheme.labelMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold) ??
              const TextStyle();
        }),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: context.colorScheme.surface,
              width: 2,
            ),
          ),
        ),
        child: NavigationBar(
          elevation: 0,
          backgroundColor: context.colorScheme.background,
          selectedIndex: _currentIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _currentIndex = index;
            });
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          indicatorColor: Colors.transparent,
          indicatorShape: const CircleBorder(),
          height: 72,
          destinations: [
            NavigationDestination(
              icon: AppIcons.icon(
                  icon: AppIcons.voiIcon,
                  color: context.colorScheme.onSurfaceVariant,
                  size: AppIcons.small),
              label: 'Assets',
              selectedIcon: AppIcons.icon(
                  icon: AppIcons.voiIcon,
                  color: context.colorScheme.primary,
                  size: AppIcons.small),
            ),
            NavigationDestination(
              icon: AppIcons.icon(
                  icon: AppIcons.nft,
                  color: context.colorScheme.onSurfaceVariant,
                  size: AppIcons.small),
              label: 'NFTs',
              selectedIcon: AppIcons.icon(
                  icon: AppIcons.nft,
                  color: context.colorScheme.primary,
                  size: AppIcons.small),
            ),
            NavigationDestination(
              icon: AppIcons.icon(
                  icon: AppIcons.send,
                  color: context.colorScheme.onSurfaceVariant,
                  size: AppIcons.small),
              label: 'Activity',
              selectedIcon: AppIcons.icon(
                  icon: AppIcons.send,
                  color: context.colorScheme.primary,
                  size: AppIcons.small),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    ref.watch(isDarkModeProvider);

    return FutureBuilder<bool>(
      future: ref.read(accountProvider.notifier).hasPrivateKey(),
      builder: (context, snapshot) {
        final hasPrivateKey = snapshot.data ?? false;

        return ExpandableFab(
          key: _key,
          type: ExpandableFabType.up,
          distance: 70,
          pos: ExpandableFabPos.right,
          onOpen: () => _handleVibration(kHapticButtonPressDuration),
          overlayStyle: const ExpandableFabOverlayStyle(
            color: Colors.black54,
          ),
          openButtonBuilder: RotateFloatingActionButtonBuilder(
            child: const Icon(AppIcons.menu),
            fabSize: ExpandableFabSize.regular,
            foregroundColor: Colors.white,
            backgroundColor: context.colorScheme.secondary,
            shape: const CircleBorder(),
          ),
          closeButtonBuilder: FloatingActionButtonBuilder(
            size: 56,
            builder: (BuildContext context, void Function()? onPressed,
                Animation<double> progress) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(kWidgetRadius),
                ),
                child: IconButton(
                  onPressed: onPressed,
                  icon: const Icon(
                    AppIcons.cross,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          childrenOffset: const Offset(5, 0),
          children: [
            if (hasPrivateKey) // Show the send button if the account has a private key
              CustomFabChild(
                icon: AppIcons.send,
                backgroundColor: context.colorScheme.secondary,
                iconColor: Colors.white,
                borderRadius: 100,
                onPressed: () {
                  closeFab();
                  context.goNamed(
                    sendTransactionRouteName,
                    pathParameters: {'mode': 'payment'},
                  );
                },
              ),
            if (Platform.isAndroid || Platform.isIOS)
              CustomFabChild(
                borderRadius: 100,
                icon: AppIcons.scan,
                backgroundColor: ColorPalette.usdcAsset,
                iconColor: context.colorScheme.onPrimary,
                onPressed: () async {
                  closeFab();
                  final scannedData = await GoRouter.of(context)
                      .push('/qrScanner', extra: ScanMode.catchAll);
                  if (scannedData != null &&
                      scannedData is String &&
                      QRCodeScannerLogic().isPublicKeyFormat(scannedData)) {
                    if (!context.mounted) return;
                    GoRouter.of(context).goNamed(
                      sendTransactionRouteName,
                      pathParameters: {'mode': 'payment'},
                      extra: {'address': scannedData},
                    );
                  }
                },
              ),
            CustomFabChild(
              borderRadius: 100,
              icon: AppIcons.wallet,
              backgroundColor: context.colorScheme.primary,
              iconColor: context.colorScheme.onPrimary,
              onPressed: () {
                closeFab();
                GoRouter.of(context).push('/$accountListRouteName');
              },
            ),
            CustomFabChild(
              borderRadius: 100,
              icon: AppIcons.settings,
              backgroundColor: ColorPalette.orange,
              iconColor: context.colorScheme.onPrimary,
              onPressed: () {
                GoRouter.of(context).push('/$settingsRouteName');
                closeFab();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleVibration(int duration) async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: duration);
    }
  }

  void closeFab() {
    final state = _key.currentState;
    if (state != null) {
      if (state.isOpen) {
        state.toggle();
      }
    }
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
        balanceAsync.when(
          data: (balance) => Row(
            children: [
              EllipsizedText(
                NumberShortener.shortenNumber(balance),
                style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: balance > 0
                        ? context.colorScheme.secondary
                        : context.colorScheme.onBackground),
              ),
              SvgPicture.asset(
                'assets/images/${networks[0].icon}.svg',
                semanticsLabel: networks[0].name,
                height: 12,
                colorFilter: ColorFilter.mode(
                    balance > 0
                        ? context.colorScheme.secondary
                        : context.colorScheme.onBackground,
                    BlendMode.srcATop),
              ),
              IconButton(
                icon: AppIcons.icon(
                    icon: AppIcons.info,
                    size: AppIcons.small,
                    color: context.colorScheme.onBackground),
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
          loading: () => const AnimatedDots(),
          error: (error, stack) => const Text('Error'),
        ),
      ],
    );
  }

  Widget _buildNetworkSelectButton(
      BuildContext context, List<SelectItem> networks, WidgetRef ref) {
    return MaterialButton(
      padding: EdgeInsets.zero,
      elevation: 0,
      shape: const CircleBorder(),
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

  Widget _buildDashboardInfoPanel(BuildContext context, WidgetRef ref,
      List<SelectItem> networks, String? publicKey, AccountState accountState) {
    if (publicKey == null) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return DashboardInfoPanel(
        networks: networks,
        accountState: accountState,
        publicKey: publicKey,
      );
    }
  }
}
