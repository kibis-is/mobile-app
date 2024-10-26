import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/setup_account/add_account/add_account_body.dart';
import 'package:kibisis/providers/accounts_list_provider.dart';
import 'package:kibisis/providers/loading_provider.dart';
import 'package:kibisis/providers/setup_complete_provider.dart';
import 'package:kibisis/theme/color_palette.dart';
import 'package:kibisis/utils/account_selection.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/media_query_helper.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class AccountListScreen extends ConsumerStatefulWidget {
  static String title = 'Select Account';
  const AccountListScreen({super.key});

  @override
  AccountListScreenState createState() => AccountListScreenState();
}

class AccountListScreenState extends ConsumerState<AccountListScreen> {
  Map<String, dynamic>? selectedAccount;

  @override
  Widget build(BuildContext context) {
    final mediaQueryHelper = MediaQueryHelper(context);
    final accountsListState = ref.watch(accountsListProvider);
    final isSetupComplete = ref.watch(setupCompleteProvider);
    final flex = mediaQueryHelper.getDynamicFlex();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Account'),
        automaticallyImplyLeading: false,
      ),
      body: mediaQueryHelper.isWideScreen()
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: flex[0],
                  child: Padding(
                    padding: const EdgeInsets.all(kScreenPadding),
                    child: _buildBody(context, accountsListState),
                  ),
                ),
                Expanded(
                  flex: flex[1],
                  child: AddAccountBody(
                    accountFlow: isSetupComplete
                        ? AccountFlow.addNew
                        : AccountFlow.setup,
                  ),
                ),
              ],
            )
          : Padding(
              padding: const EdgeInsets.all(kScreenPadding),
              child: _buildBody(context, accountsListState),
            ),
      floatingActionButton: mediaQueryHelper.isWideScreen()
          ? null
          : FloatingActionButton(
              onPressed: _navigateToAddAccount,
              shape: const CircleBorder(),
              backgroundColor: context.colorScheme.secondary,
              child: const Icon(AppIcons.add),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildBody(BuildContext context, AccountsListState accountsListState) {
    if (accountsListState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (accountsListState.error != null) {
      return Center(child: Text('Error: ${accountsListState.error}'));
    } else if (accountsListState.accounts.isEmpty) {
      return const Center(child: Text('No accounts found'));
    } else {
      return _buildAccountsList(context, accountsListState.accounts);
    }
  }

  Widget _buildAccountsList(
      BuildContext context, List<Map<String, dynamic>> accounts) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: kBottomNavigationBarHeight),
      itemCount: accounts.length,
      itemBuilder: (context, index) {
        final account = accounts[index];
        return _buildAccountItem(context, account);
      },
      separatorBuilder: (context, index) =>
          const SizedBox(height: kScreenPadding),
    );
  }

  Widget _buildAccountItem(BuildContext context, Map<String, dynamic> account) {
    final accountName = account['accountName'] ?? 'Unnamed Account';
    final publicKey = account['publicKey'] ?? 'No Public Key';
    final privateKeyAccounts = ref.watch(privateKeyAccountsProvider);

    return privateKeyAccounts.when(
      data: (accountsWithPrivateKey) {
        final isWatchAccount = !accountsWithPrivateKey.any((privateAccount) =>
            privateAccount['accountId'] == account['accountId']);

        debugPrint(
            'Account ID: ${account['accountId']}, isWatchAccount: $isWatchAccount');

        return InkWell(
          child: Material(
            elevation: 6.0,
            borderRadius: BorderRadius.circular(kScreenPadding),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0.0, 0.5],
                  colors: isWatchAccount
                      ? [
                          ColorPalette.cardGradientLightBlue,
                          ColorPalette.cardGradientMediumBlue,
                        ]
                      : [
                          ColorPalette.cardGradientPurpleA,
                          ColorPalette.cardGradientPurpleB,
                        ],
                ),
                image: isWatchAccount
                    ? null
                    : const DecorationImage(
                        opacity: 0.2,
                        image: AssetImage('assets/images/voi-logo.png'),
                        fit: BoxFit.cover,
                      ),
                border: GradientBoxBorder(
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [Colors.transparent, Colors.white.withOpacity(0.5)],
                  ),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(kScreenPadding),
              ),
              padding: const EdgeInsets.all(kScreenPadding),
              child: Stack(
                children: [
                  if (isWatchAccount)
                    Positioned.fill(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          double size = constraints.biggest.shortestSide;
                          return Center(
                            child: Icon(
                              AppIcons.watch,
                              color: Colors.white.withOpacity(0.2),
                              size: size,
                            ),
                          );
                        },
                      ),
                    ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEditButton(
                          context, account['accountId']!, accountName),
                      const SizedBox(height: kScreenPadding / 2),
                      _buildLogo(),
                      const SizedBox(height: kScreenPadding / 2),
                      _buildAccountName(
                          context, accountName, account['accountId']!),
                      const SizedBox(height: kScreenPadding / 2),
                      _buildPublicKey(context, publicKey),
                      const SizedBox(height: kScreenPadding),
                    ],
                  ),
                ],
              ),
            ),
          ),
          onTap: () {
            ref
                .read(loadingProvider.notifier)
                .startLoading(message: 'Loading Account');
            final accountHandler = AccountHandler(ref);

            accountHandler
                .handleAccountSelection(account['accountId'])
                .then((_) {
              GoRouter.of(context).go('/');
            }).catchError((e) {
              debugPrint('Error handling account selection: ${e.toString()}');
              ref.read(loadingProvider.notifier).stopLoading();
            });
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, stack) => const Center(child: Text('Error loading accounts')),
    );
  }

  Widget _buildEditButton(
      BuildContext context, String accountId, String accountName) {
    return Container(
      padding:
          const EdgeInsets.only(left: kScreenPadding, bottom: kScreenPadding),
      alignment: Alignment.centerRight,
      child: IconButton(
        icon: AppIcons.icon(
            icon: AppIcons.edit, size: AppIcons.medium, color: Colors.white),
        onPressed: () =>
            _navigateToEditAccount(context, accountId, accountName),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [Color(0xFFBFBFBF), Color(0xFF767676), Color(0xFFCFCFCF)],
        ),
        border: const GradientBoxBorder(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [Color(0xFFB5B5B5), Color(0xFFD7D7D7), Color(0xFFFFFFFF)],
          ),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(kScreenPadding / 4),
      ),
      width: kScreenPadding * 3,
      height: kScreenPadding * 2,
      child: SvgPicture.asset(
        'assets/images/kibisis-logo-light.svg',
        semanticsLabel: 'Kibisis Logo',
        fit: BoxFit.fitHeight,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcATop),
      ),
    );
  }

  Widget _buildAccountName(
      BuildContext context, String accountName, String accountId) {
    return Hero(
      tag: 'account-name-$accountId',
      child: EllipsizedText(accountName,
          style: context.textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold)
              .copyWith(color: Colors.white)),
    );
  }

  Widget _buildPublicKey(BuildContext context, String publicKey) {
    return Hero(
      tag: publicKey,
      child: EllipsizedText(
        type: EllipsisType.middle,
        ellipsis: '...',
        publicKey,
        style: context.textTheme.titleSmall
            ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  void _navigateToEditAccount(
      BuildContext context, String accountId, String accountName) {
    GoRouter.of(context)
        .push('/editAccount/$accountId', extra: {'accountName': accountName});
  }

  void _navigateToAddAccount() {
    if (!mounted) return;
    GoRouter.of(context).push('/addAccount/');
  }
}
