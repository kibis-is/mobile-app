import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:kibisis/common_widgets/custom_floating_action_button.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/accounts_list_provider.dart';
import 'package:kibisis/providers/active_account_provider.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/theme/color_palette.dart';
import 'package:kibisis/utils/refresh_account_data.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class AccountListScreen extends ConsumerStatefulWidget {
  static String title = 'Select Account';
  const AccountListScreen({super.key});

  @override
  AccountListScreenState createState() => AccountListScreenState();
}

class AccountListScreenState extends ConsumerState<AccountListScreen> {
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
        child: _buildBody(context, accountsListState),
      ),
      floatingActionButton: CustomFloatingActionButton(
        icon: Icons.add,
        onPressed: _navigateToAddAccount,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(
                bottom: kBottomNavigationBarHeight), // Add padding here
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final account = accounts[index];
              final accountName = account['accountName'] ?? 'Unnamed Account';
              final publicKey = account['publicKey'] ?? 'No Public Key';

              return _buildAccountItem(
                  context, account, accountName, publicKey);
            },
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(height: kScreenPadding);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAccountItem(BuildContext context, Map<String, dynamic> account,
      String accountName, String publicKey) {
    return InkWell(
      child: Material(
        elevation: 6.0,
        borderRadius: BorderRadius.circular(kScreenPadding),
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
                colors: [Colors.transparent, Colors.white.withOpacity(0.5)],
              ),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(kScreenPadding),
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
              _buildEditButton(context, account['accountId']!, accountName),
              const SizedBox(height: kScreenPadding),
              _buildLogo(),
              const SizedBox(height: kScreenPadding / 2),
              _buildAccountName(context, accountName),
              const SizedBox(height: kScreenPadding / 2),
              _buildPublicKey(context, publicKey),
              _buildAccountBalance(context),
            ],
          ),
        ),
      ),
      onTap: () async {
        debugPrint('Tapped account Public Key: $publicKey');
        await _handleAccountSelection(account['accountId']!);
      },
    );
  }

  Widget _buildEditButton(
      BuildContext context, String accountId, String accountName) {
    return Container(
      padding:
          const EdgeInsets.only(left: kScreenPadding, bottom: kScreenPadding),
      alignment: Alignment.centerRight,
      child: IconButton(
        icon:
            const Icon(Icons.edit, color: ColorPalette.darkThemeAntiflashWhite),
        onPressed: () {
          _navigateToEditAccount(accountId, accountName);
        },
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

  Widget _buildAccountName(BuildContext context, String accountName) {
    return Text(accountName,
        style: context.textTheme.titleLarge
            ?.copyWith(fontWeight: FontWeight.bold)
            .copyWith(
              color: ColorPalette.darkThemeAntiflashWhite,
            ));
  }

  Widget _buildPublicKey(BuildContext context, String publicKey) {
    return EllipsizedText(
      type: EllipsisType.middle,
      ellipsis: '...',
      publicKey,
      style: context.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: ColorPalette.darkThemeAntiflashWhite,
      ),
    );
  }

  Widget _buildAccountBalance(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '0.0',
            style: context.textTheme.bodyLarge?.copyWith(
              color: ColorPalette.darkThemeKeppel,
              fontWeight: FontWeight.bold,
            ),
          ),
          SvgPicture.asset(
            'assets/images/voi-asset-icon.svg',
            colorFilter: ColorFilter.mode(
                context.colorScheme.secondary, BlendMode.srcATop),
            height: kScreenPadding,
          ),
        ],
      ),
    );
  }

  Future<void> _handleAccountSelection(String accountId) async {
    _navigateToHome();

    debugPrint('Setting active account ID: $accountId');

    await ref.read(activeAccountProvider.notifier).setActiveAccount(accountId);
    ref.invalidate(accountProvider);
    await ref.read(accountProvider.notifier).loadAccountFromPrivateKey();

    if (mounted) {
      invalidateProviders(ref);
    }
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