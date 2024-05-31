import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/accounts_list_provider.dart';
import 'package:kibisis/providers/active_account_provider.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/theme/color_palette.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class WalletsScreen extends ConsumerStatefulWidget {
  static String title = 'Wallets';
  const WalletsScreen({super.key});

  @override
  WalletsScreenState createState() => WalletsScreenState();
}

class WalletsScreenState extends ConsumerState<WalletsScreen> {
  @override
  Widget build(BuildContext context) {
    final accountsListState = ref.watch(accountsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Account'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
        child: accountsListState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : accountsListState.error != null
                ? Center(child: Text('Error: ${accountsListState.error}'))
                : accountsListState.accounts.isEmpty
                    ? const Center(child: Text('No accounts found'))
                    : ListView.separated(
                        itemCount: accountsListState.accounts.length,
                        itemBuilder: (context, index) {
                          final account = accountsListState.accounts[index];
                          final accountName =
                              account['accountName'] ?? 'Unnamed Account';
                          final publicKey =
                              account['publicKey'] ?? 'No Public Key';

                          debugPrint(
                              'Rendering account: $accountName with Public Key: $publicKey');

                          return InkWell(
                            child: Container(
                              decoration: BoxDecoration(
                                image: const DecorationImage(
                                  opacity: 0.2,
                                  image:
                                      AssetImage('assets/images/voi-logo.png'),
                                  fit: BoxFit.cover,
                                ),
                                border: GradientBoxBorder(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomLeft,
                                    end: Alignment.topRight,
                                    colors: [
                                      Colors.transparent,
                                      Colors.white.withOpacity(0.5)
                                    ],
                                  ),
                                  width: 1,
                                ),
                                borderRadius:
                                    BorderRadius.circular(kScreenPadding),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  stops: [0.0, 0.5],
                                  colors: [
                                    ColorPalette.cardGradientTurquoiseA,
                                    ColorPalette.cardGradientPurpleB,
                                  ],
                                ),
                              ),
                              padding: const EdgeInsets.all(kScreenPadding),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                      icon: Icon(Icons.edit,
                                          color:
                                              context.colorScheme.onSecondary),
                                      onPressed: () {
                                        _navigateToEditAccount(
                                            account['accountId']!, accountName);
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: kScreenPadding),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.bottomLeft,
                                        end: Alignment.topRight,
                                        colors: [
                                          Color(0xFFBFBFBF),
                                          Color(0xFF767676),
                                          Color(0xFFCFCFCF)
                                        ],
                                      ),
                                      border: const GradientBoxBorder(
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomLeft,
                                          end: Alignment.topRight,
                                          colors: [
                                            Color(0xFFB5B5B5),
                                            Color(0xFFD7D7D7),
                                            Color(0xFFFFFFFF)
                                          ],
                                        ),
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          kScreenPadding / 4),
                                    ),
                                    width: 32,
                                    height: 24,
                                    child: SvgPicture.asset(
                                      'assets/images/kibisis-logo-light.svg',
                                      semanticsLabel: 'Kibisis Logo',
                                      fit: BoxFit.fitHeight,
                                      colorFilter: const ColorFilter.mode(
                                          Colors.white, BlendMode.srcATop),
                                    ),
                                  ),
                                  const SizedBox(height: kScreenPadding / 2),
                                  Text(
                                    accountName,
                                    style: context.textTheme.titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: kScreenPadding / 2),
                                  EllipsizedText(
                                    type: EllipsisType.middle,
                                    ellipsis: '...',
                                    publicKey,
                                    style:
                                        context.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.centerRight,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text('0.0',
                                            style: context.textTheme.bodyLarge
                                                ?.copyWith(
                                                    color: context
                                                        .colorScheme.secondary,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                        SvgPicture.asset(
                                          'assets/images/voi-asset-icon.svg',
                                          colorFilter: ColorFilter.mode(
                                              context.colorScheme.secondary,
                                              BlendMode.srcATop),
                                          height: 16,
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            onTap: () async {
                              debugPrint(
                                  'Tapped account Public Key: $publicKey');
                              await _handleAccountSelection(
                                  account['accountId']!);
                            },
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return const SizedBox(height: kScreenPadding);
                        },
                      ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                _navigateToAddAccount();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAccountSelection(String accountId) async {
    debugPrint('Setting active account ID: $accountId');
    await ref.read(activeAccountProvider.notifier).setActiveAccount(accountId);
    await ref.read(accountProvider.notifier).loadAccountFromPrivateKey();
    if (!mounted) return;
    debugPrint('Selected account ID: $accountId');
    _navigateToHome();
  }

  void _navigateToEditAccount(String accountId, String accountName) {
    GoRouter.of(context)
        .push('/editAccount/$accountId', extra: {'accountName': accountName});
  }

  void _navigateToHome() {
    if (!mounted) return;
    GoRouter.of(context).go('/');
  }

  void _navigateToAddAccount() {
    if (!mounted) return;
    GoRouter.of(context).push('/addAccount/');
  }
}
