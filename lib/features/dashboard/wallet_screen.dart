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

class WalletsScreen extends ConsumerStatefulWidget {
  static String title = 'Wallets';
  const WalletsScreen({super.key});

  @override
  WalletsScreenState createState() => WalletsScreenState();
}

class WalletsScreenState extends ConsumerState<WalletsScreen> {
  @override
  Widget build(BuildContext context) {
    final accountsList = ref.watch(accountsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select an Account'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
        child: accountsList.when(
          data: (accounts) {
            if (accounts.isEmpty) {
              return const Center(child: Text('No accounts found'));
            }

            // Debugging: Print accounts list size
            debugPrint('Number of accounts: ${accounts.length}');

            return ListView.separated(
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final account = accounts[index];
                final accountName = account['accountName'] ?? 'Unnamed Account';
                final accountId = account['accountId'] ?? '';

                // Debugging: Print each account as it is rendered
                debugPrint(
                    'Rendering account: $accountName with ID: $accountId');

                return InkWell(
                  child: Container(
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        opacity: 0.2,
                        image: AssetImage('assets/images/voi-logo.png'),
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
                      borderRadius: BorderRadius.circular(kScreenPadding),
                      gradient: const LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        colors: [
                          ColorPalette.cardGradientPurpleB,
                          ColorPalette.cardGradientPurpleA,
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
                            icon: const Icon(Icons.edit),
                            onPressed: () {},
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
                            borderRadius:
                                BorderRadius.circular(kScreenPadding / 4),
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
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: kScreenPadding / 2),
                        Text(
                          accountId,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: kScreenPadding / 2),
                      ],
                    ),
                  ),
                  onTap: () async {
                    debugPrint('Tapped account ID: $accountId');
                    await _handleAccountSelection(accountId);
                  },
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(height: kScreenPadding);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                GoRouter.of(context).push('/addAccount/');
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

  void _navigateToHome() {
    if (!mounted) return;
    GoRouter.of(context).go('/');
  }
}
