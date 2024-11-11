import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_list_tile.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/generated/l10n.dart';
import 'package:kibisis/providers/temporary_account_provider.dart';
import 'package:kibisis/routing/named_routes.dart';
import 'package:kibisis/utils/app_icons.dart';

class AddAccountBody extends ConsumerWidget {
  final AccountFlow accountFlow;

  const AddAccountBody({super.key, required this.accountFlow});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: kScreenPadding),
          CustomListTile(
            title: S.current.createNewAccount,
            subtitle: S.current.createNewAccountSubtitle,
            leadingIcon: AppIcons.addAccount,
            trailingIcon: AppIcons.arrowRight,
            onTap: () => _onCreateAccount(context, ref),
          ),
          const SizedBox(height: kScreenPadding),
          CustomListTile(
            title: S.current.importViaSeed,
            subtitle: S.current.importViaSeedSubtitle,
            leadingIcon: AppIcons.importAccount,
            trailingIcon: AppIcons.arrowRight,
            onTap: () {
              GoRouter.of(context).push(
                accountFlow == AccountFlow.setup
                    ? '/setup/setupImportSeed'
                    : '/addAccount/addAccountImportSeed',
              );
            },
          ),
          if (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS)
            Column(
              children: [
                const SizedBox(height: kScreenPadding),
                CustomListTile(
                  title: S.current.importViaQrCode,
                  subtitle: S.current.importViaQrCodeSubtitle,
                  leadingIcon: AppIcons.scan,
                  trailingIcon: AppIcons.arrowRight,
                  onTap: () => _navigateToImportViaQr(context),
                ),
              ],
            ),
          Column(
            children: [
              const SizedBox(height: kScreenPadding),
              CustomListTile(
                title: S.current.importViaPrivateKey,
                subtitle: S.current.importViaPrivateKeySubtitle,
                leadingIcon: AppIcons.key,
                trailingIcon: AppIcons.arrowRight,
                onTap: () => _importViaPrivateKey(context),
              ),
            ],
          ),
          CustomListTile(
            title: S.current.addWatch,
            subtitle: S.current.addWatchSubtitle,
            leadingIcon: AppIcons.watch,
            trailingIcon: AppIcons.arrowRight,
            onTap: () => _addWatchAccount(context),
          ),
        ],
      ),
    );
  }

  Future<void> _createNewAccount(WidgetRef ref) async {
    await ref.read(temporaryAccountProvider.notifier).createTemporaryAccount();
  }

  void _onCreateAccount(BuildContext context, WidgetRef ref) {
    _createNewAccount(ref).then((_) {
      _navigateToCopySeed(context);
    }).catchError((error) {
      debugPrint("Error creating account: $error");
    });
  }

  void _navigateToImportViaQr(BuildContext context) {
    GoRouter.of(context).push(
      accountFlow == AccountFlow.setup
          ? '/setup/$setupImportQrRouteName'
          : '/addAccount/$mainImportQrRouteName',
    );
  }

  void _navigateToCopySeed(BuildContext context) {
    GoRouter.of(context).push(
      accountFlow == AccountFlow.setup
          ? '/setup/setupCopySeed'
          : '/addAccount/addAccountCopySeed',
    );
  }

  void _importViaPrivateKey(BuildContext context) {
    GoRouter.of(context).push(
      accountFlow == AccountFlow.setup
          ? '/setup/$setupPrivateKeyRouteName'
          : '/addAccount/$mainPrivateKeyRouteName',
    );
  }

  void _addWatchAccount(BuildContext context) {
    GoRouter.of(context).push(
      accountFlow == AccountFlow.setup
          ? '/setup/$setupAddWatchAccountRouteName'
          : '/addAccount/$mainAddWatchAccountRouteName',
    );
  }
}
