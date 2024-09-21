import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_list_tile.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/temporary_account_provider.dart';
import 'package:kibisis/routing/named_routes.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class AddAccountScreen extends ConsumerStatefulWidget {
  static String title = "Add Account";
  final AccountFlow accountFlow;

  const AddAccountScreen({super.key, required this.accountFlow});

  @override
  AddAccountScreenState createState() => AddAccountScreenState();
}

class AddAccountScreenState extends ConsumerState<AddAccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AddAccountScreen.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(kScreenPadding),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You can either create a new account or import an existing account.',
                style: context.textTheme.bodySmall,
              ),
              const SizedBox(
                height: kScreenPadding,
              ),
              CustomListTile(
                title: "Create New Account",
                subtitle: 'You will be prompted to save a seed.',
                leadingIcon: AppIcons.addAccount,
                trailingIcon: AppIcons.arrowRight,
                onTap: () async {
                  await _createNewAccount(ref);
                },
              ),
              const SizedBox(
                height: kScreenPadding,
              ),
              CustomListTile(
                title: "Import Via Seed",
                subtitle: 'Import an existing account via seed phrase.',
                leadingIcon: AppIcons.importAccount,
                trailingIcon: AppIcons.arrowRight,
                onTap: () {
                  GoRouter.of(context).push(
                      widget.accountFlow == AccountFlow.setup
                          ? '/setup/setupImportSeed'
                          : '/addAccount/addAccountImportSeed');
                },
              ),
              if (defaultTargetPlatform == TargetPlatform.android ||
                  defaultTargetPlatform == TargetPlatform.iOS)
                Column(
                  children: [
                    const SizedBox(
                      height: kScreenPadding,
                    ),
                    CustomListTile(
                      title: "Import Via QR Code",
                      subtitle: 'Scan a QR code to import an existing account.',
                      leadingIcon: AppIcons.scan,
                      trailingIcon: AppIcons.arrowRight,
                      onTap: _navigateToImportViaQr,
                    ),
                  ],
                ),
              Column(
                children: [
                  const SizedBox(
                    height: kScreenPadding,
                  ),
                  CustomListTile(
                    title: "Import via Private Key",
                    subtitle: 'Import accounts from a private key.',
                    leadingIcon: AppIcons.key,
                    trailingIcon: AppIcons.arrowRight,
                    onTap: _importViaPrivateKey,
                  ),
                ],
              ),
              CustomListTile(
                title: "Add Watch",
                subtitle: "Add watch account to watch via public address.",
                leadingIcon: AppIcons.watch,
                trailingIcon: AppIcons.arrowRight,
                onTap: _addWatchAccount,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createNewAccount(WidgetRef ref) async {
    await ref.read(temporaryAccountProvider.notifier).createTemporaryAccount();
    _navigateToCopySeed();
  }

  void _navigateToImportViaQr() {
    GoRouter.of(context).push(widget.accountFlow == AccountFlow.setup
        ? '/setup/$setupImportQrRouteName'
        : '/addAccount/$mainImportQrRouteName');
  }

  void _navigateToCopySeed() {
    GoRouter.of(context).push(widget.accountFlow == AccountFlow.setup
        ? '/setup/setupCopySeed'
        : '/addAccount/addAccountCopySeed');
  }

  void _importViaPrivateKey() {
    GoRouter.of(context).push(widget.accountFlow == AccountFlow.setup
        ? '/setup/$setupPrivateKeyRouteName'
        : '/addAccount/$mainPrivateKeyRouteName');
  }

  void _addWatchAccount() {
    GoRouter.of(context).push(widget.accountFlow == AccountFlow.setup
        ? '/setup/$setupAddWatchAccountRouteName'
        : '/addAccount/$mainAddWatchAccountRouteName');
  }
}
