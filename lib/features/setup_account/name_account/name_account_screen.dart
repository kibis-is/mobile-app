import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/confirmation_dialog.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/common_widgets/custom_text_field.dart';
import 'package:kibisis/common_widgets/top_snack_bar.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/generated/l10n.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/accounts_list_provider.dart';
import 'package:kibisis/providers/active_account_provider.dart';
import 'package:kibisis/providers/loading_provider.dart';
import 'package:kibisis/routing/named_routes.dart';
import 'package:kibisis/utils/account_setup.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/refresh_account_data.dart';
import 'package:kibisis/utils/theme_extensions.dart';

final hasSubmittedProvider = StateProvider.autoDispose<bool>((ref) => false);

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
        title: Text(_getAppBarTitle()),
        actions: [_buildDeleteAction()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(kScreenPadding),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: kScreenPadding),
              _buildDescription(context),
              const SizedBox(height: kScreenPadding),
              _buildAccountNameField(),
              const SizedBox(height: kScreenPadding),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildSubmitButton(),
    );
  }

  String _getAppBarTitle() {
    return widget.accountFlow == AccountFlow.edit
        ? S.current.editAccount
        : S.current.nameAccount;
  }

  Widget _buildDeleteAction() {
    if (widget.accountFlow != AccountFlow.edit) return Container();

    final accountsList = ref.watch(accountsListProvider);
    if (accountsList.accounts.length > 1) {
      return IconButton(
        icon: AppIcons.icon(icon: AppIcons.delete),
        onPressed: () => _confirmDeleteAccount(),
      );
    }
    return Container();
  }

  Future<void> _confirmDeleteAccount() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool confirm = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return ConfirmationDialog(
                yesText: S.of(context).delete,
                noText: S.of(context).cancel,
                content: S.of(context).confirmDeleteAccount,
              );
            },
          ) ??
          false;

      if (confirm) {
        await _deleteAccount(widget.accountId!);
      }
    });
  }

  Widget _buildHeader(BuildContext context) {
    return Text(
      widget.accountFlow == AccountFlow.edit
          ? S.of(context).editAccountNamePrompt
          : S.of(context).nameAccountPrompt,
      style: context.textTheme.bodyMedium?.copyWith(
        color: context.colorScheme.onSecondary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Text(
      widget.accountFlow == AccountFlow.edit
          ? S.of(context).editAccountDescription
          : S.of(context).nameAccountDescription,
      style: context.textTheme.bodySmall,
    );
  }

  Widget _buildAccountNameField() {
    return CustomTextField(
      maxLength: kMaxAccountNameLength,
      controller: accountNameController,
      labelText: S.of(context).accountName,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return S.of(context).pleaseEnterText;
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    final isLoading = ref.watch(loadingProvider).isLoading;
    final hasSubmitted = ref.watch(hasSubmittedProvider);

    return Padding(
      padding: const EdgeInsets.all(kScreenPadding),
      child: CustomButton(
        text: widget.accountFlow == AccountFlow.edit
            ? S.of(context).save
            : S.of(context).create,
        isFullWidth: true,
        onPressed: isLoading || hasSubmitted ? null : _handleSubmit,
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (formKey.currentState!.validate()) {
      ref.read(hasSubmittedProvider.notifier).state = true;

      try {
        await _handleAccountSubmission();
        _navigateHome();
      } catch (e) {
        _showError(e);
      } finally {
        ref.read(hasSubmittedProvider.notifier).state = false;
      }
    }
  }

  Future<void> _handleAccountSubmission() async {
    final ref = this.ref;
    ref.read(loadingProvider.notifier).startLoading(
          message: widget.accountFlow == AccountFlow.edit
              ? S.current.updatingAccount
              : S.current.creatingAccount,
          withProgressBar: widget.accountFlow != AccountFlow.edit,
        );

    try {
      if (widget.accountFlow == AccountFlow.edit) {
        await _updateAccountName();
      } else {
        await _createAccount();
      }
    } finally {
      ref.read(loadingProvider.notifier).stopLoading();
    }
  }

  Future<void> _updateAccountName() async {
    final accountName = accountNameController.text;
    final accountId = ref.watch(activeAccountProvider);
    if (accountId == null) {
      throw Exception('No active account ID found');
    }

    await ref.read(accountProvider.notifier).setAccountName(accountName);
    await ref
        .read(accountsListProvider.notifier)
        .updateAccountName(accountId, accountName);

    await AccountSetupUtility.completeAccountSetup(
      ref: ref,
      accountFlow: widget.accountFlow,
      accountName: accountName,
      setFinalState: true,
    );

    ref.read(accountsListProvider.notifier).loadAccounts();
    invalidateProviders(ref);
  }

  Future<void> _createAccount() async {
    await AccountSetupUtility.completeAccountSetup(
      ref: ref,
      accountFlow: widget.accountFlow,
      accountName: accountNameController.text,
      setFinalState: true,
    );

    invalidateProviders(ref);
  }

  Future<void> _deleteAccount(String accountId) async {
    try {
      await ref.read(accountProvider.notifier).deleteAccount(accountId);
      _navigateToAccountList();
    } catch (e) {
      _showError(e);
    }
  }

  void _navigateHome() {
    GoRouter.of(context).go('/');
  }

  void _navigateToAccountList() {
    GoRouter.of(context).go('/$accountListRouteName');
  }

  void _showError(dynamic error) {
    showCustomSnackBar(
      context: context,
      snackType: SnackType.error,
      message: '$error',
    );
    ref.read(hasSubmittedProvider.notifier).state = false;
  }
}
