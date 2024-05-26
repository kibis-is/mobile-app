import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/common_widgets/custom_text_field.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/accounts_list_provider.dart';
import 'package:kibisis/providers/active_account_provider.dart';
import 'package:kibisis/utils/complete_account_setup.dart';

class NameAccountScreen extends ConsumerStatefulWidget {
  final AccountFlow accountFlow;
  final String? initialAccountName;
  final String? accountId;

  const NameAccountScreen({
    super.key,
    required this.accountFlow,
    this.initialAccountName,
    this.accountId,
  });

  @override
  NameAccountScreenState createState() => NameAccountScreenState();
}

class NameAccountScreenState extends ConsumerState<NameAccountScreen> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController accountNameController;

  @override
  void initState() {
    super.initState();
    accountNameController = TextEditingController(
      text: widget.initialAccountName ?? '',
    );
  }

  @override
  void dispose() {
    accountNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.accountFlow == AccountFlow.edit
            ? 'Edit Account'
            : 'Name Account'),
        actions: [
          if (widget.accountFlow == AccountFlow.edit)
            Consumer(
              builder: (context, ref, child) {
                final accountsList = ref.watch(accountsListProvider);
                if (accountsList.accounts.length > 1) {
                  return IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await _deleteAccount(widget.accountId!);
                    },
                  );
                }
                return Container();
              },
            ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(kScreenPadding),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: kScreenPadding),
                        Text(
                          widget.accountFlow == AccountFlow.edit
                              ? 'Edit your account name'
                              : 'Name your account',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: kScreenPadding),
                        Text(
                          widget.accountFlow == AccountFlow.edit
                              ? 'You can change your account name below.'
                              : 'Give your account a nickname. Don’t worry, you can change this later.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: kScreenPadding),
                        CustomTextField(
                          controller: accountNameController,
                          labelText: 'Account Name',
                          onChanged: (value) {},
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                        ),
                        const Spacer(),
                        CustomButton(
                          text: widget.accountFlow == AccountFlow.edit
                              ? 'Save'
                              : 'Create',
                          isFullWidth: true,
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              if (widget.accountFlow == AccountFlow.edit) {
                                await _updateAccountName();
                              } else {
                                await _handleAccountCreation();
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleAccountCreation() async {
    final accountName = accountNameController.text;
    await ref
        .read(accountProvider.notifier)
        .finalizeAccountCreation(accountName);
    _navigateToHome();
  }

  Future<void> _updateAccountName() async {
    final accountName = accountNameController.text;
    await ref.read(accountProvider.notifier).setAccountName(accountName);

    // Get the active account ID
    final accountId = ref.read(activeAccountProvider);
    if (accountId == null) {
      throw Exception('No active account ID found');
    }

    // Update the account name using the accounts list provider
    await ref
        .read(accountsListProvider.notifier)
        .updateAccountName(accountId, accountName);

    // Complete the account setup
    await completeAccountSetup(ref, accountName, widget.accountFlow);

    // Navigate to home or appropriate screen
    _navigateToHome();
  }

  Future<void> _deleteAccount(String accountId) async {
    try {
      await ref.read(accountProvider.notifier).deleteAccount(accountId);
      if (!mounted) return;
      _navigateToWallets();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete account: $e')),
      );
    }
  }

  void _navigateToHome() {
    if (!mounted) return;
    GoRouter.of(context).go('/');
  }

  void _navigateToWallets() {
    if (!mounted) return;
    GoRouter.of(context).go('/wallets');
  }
}
