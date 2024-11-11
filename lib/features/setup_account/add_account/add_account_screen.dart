import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/setup_account/add_account/add_account_body.dart';
import 'package:kibisis/generated/l10n.dart';
import 'package:kibisis/providers/setup_complete_provider.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/media_query_helper.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class AddAccountScreen extends ConsumerStatefulWidget {
  static String title = S.current.addAccountTitle;
  final AccountFlow accountFlow;

  const AddAccountScreen({super.key, required this.accountFlow});

  @override
  AddAccountScreenState createState() => AddAccountScreenState();
}

class AddAccountScreenState extends ConsumerState<AddAccountScreen> {
  @override
  Widget build(BuildContext context) {
    final mediaQueryHelper = MediaQueryHelper(context);
    final isSetupComplete = ref.watch(setupCompleteProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AddAccountScreen.title),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: kScreenPadding, horizontal: kScreenPadding / 2),
              child: AddAccountBody(
                accountFlow:
                    isSetupComplete ? AccountFlow.addNew : AccountFlow.setup,
              ),
            ),
          ),
          if (mediaQueryHelper.isWideScreen() &&
              widget.accountFlow == AccountFlow.addNew)
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(kScreenPadding),
                child: AddAccountBody(
                  accountFlow:
                      isSetupComplete ? AccountFlow.addNew : AccountFlow.setup,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: !mediaQueryHelper.isWideScreen()
          ? FloatingActionButton(
              shape: const CircleBorder(),
              onPressed: _navigateToAddAccount,
              backgroundColor: context.colorScheme.secondary,
              foregroundColor: Colors.white,
              child: const Icon(AppIcons.add),
            )
          : null,
    );
  }

  void _navigateToAddAccount() {
    GoRouter.of(context).push('/addAccount');
  }
}
