import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_list_tile.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/temporary_account_provider.dart';
import 'package:kibisis/routing/named_routes.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/barcode_scanner.dart';
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
            if (kDebugMode)
              Column(
                children: [
                  const SizedBox(
                    height: kScreenPadding,
                  ),
                  CustomListTile(
                    title: "Import Hardcoded URI",
                    subtitle:
                        'Import accounts from a hardcoded URI for testing.',
                    leadingIcon: AppIcons.importAccount,
                    trailingIcon: AppIcons.arrowRight,
                    onTap: _importFromHardcodedUri,
                  ),
                ],
              ),
          ],
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

  void _importFromHardcodedUri() {
    QRCodeScannerLogic(
      context: context,
      ref: ref,
      scanMode: ScanMode.privateKey,
      accountFlow: widget.accountFlow,
    ).handleMockBarcode(
      'avm://account/import?name=Personal&privatekey=tup_v36uHxIi1_N1acL-9FtO44FCbyPpsDj-EhS4GEA=&name=Test%20Account%201&privatekey=P0sSlStDoAFlEM1MJYkGkKvw9gsn42nDKrs0n5h029o=&name=Test%20Account%202&privatekey=IF6oOAuJWbq__Ak8-hVZb9TSm5JfCUXBq9dq4yKPGbk=',
    );
  }
}
