import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_list_tile.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/account_provider.dart';

class AddAccountScreen extends ConsumerWidget {
  static String title = "Add Account";
  const AddAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
              onTap: () {
                ref.read(accountProvider.notifier).createAccount();
                GoRouter.of(context).push('/setup/copySeed');
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
                debugPrint('Import Via Seed.');
                GoRouter.of(context).push('/setup/importSeed');
              },
            ),
          ],
        ),
      ),
    );
  }
}
