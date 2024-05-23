import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_list_tile.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/algorand_provider.dart';
import 'package:kibisis/providers/temporary_account_provider.dart';

class AddAccountScreen extends ConsumerStatefulWidget {
  static String title = "Add Account";
  final bool isSetupFlow;

  const AddAccountScreen({super.key, this.isSetupFlow = true});

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
              'You can either create a new account or import an existing account via seed.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(
              height: kScreenPadding,
            ),
            CustomListTile(
              title: "Create New Account",
              subtitle: 'You will be prompted to save a seed.',
              leadingIcon: Icons.person_add,
              trailingIcon: Icons.arrow_forward_ios_rounded,
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
              leadingIcon: Icons.import_export,
              trailingIcon: Icons.arrow_forward_ios_rounded,
              onTap: () {
                GoRouter.of(context).push(widget.isSetupFlow
                    ? '/setup/setupImportSeed'
                    : '/addAccount/addAccountImportSeed');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createNewAccount(WidgetRef ref) async {
    final algorand = ref.read(algorandProvider);
    await ref
        .read(temporaryAccountProvider.notifier)
        .createTemporaryAccount(algorand);
    _navigateToCopySeed();
  }

  void _navigateToCopySeed() {
    if (!mounted) return;
    GoRouter.of(context).push(widget.isSetupFlow
        ? '/setup/setupCopySeed'
        : '/addAccount/addAccountCopySeed');
  }
}
