import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/common_widgets/custom_text_field.dart';
import 'package:kibisis/common_widgets/top_snack_bar.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/setup_account/import_via_private_key/providers/private_key_error_provider.dart';
import 'package:kibisis/features/setup_account/import_via_private_key/providers/private_key_provider.dart';
import 'package:kibisis/features/setup_account/import_via_private_key/providers/suxxif_icon_visibility_provider.dart';
import 'package:kibisis/generated/l10n.dart';
import 'package:kibisis/providers/temporary_account_provider.dart';
import 'package:kibisis/utils/app_icons.dart';

class ImportPrivateKeyScreen extends ConsumerStatefulWidget {
  static String title = S.current.importPrivateKey;
  final AccountFlow accountFlow;

  const ImportPrivateKeyScreen({super.key, required this.accountFlow});

  @override
  ImportPrivateKeyScreenState createState() => ImportPrivateKeyScreenState();
}

class ImportPrivateKeyScreenState
    extends ConsumerState<ImportPrivateKeyScreen> {
  late TextEditingController privateKeyController;

  @override
  void initState() {
    super.initState();
    privateKeyController =
        TextEditingController(text: ref.read(privateKeyProvider).text);
  }

  @override
  void dispose() {
    privateKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showError = ref.watch(privateKeyErrorProvider);
    final isSuffixIconVisible = ref.watch(suffixIconVisibilityProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(ImportPrivateKeyScreen.title),
        actions: [
          IconButton(
            icon: AppIcons.icon(icon: AppIcons.paste),
            onPressed: () async {
              ClipboardData? clipData = await Clipboard.getData('text/plain');
              if (clipData != null) {
                privateKeyController.text = clipData.text ?? '';
                ref.read(privateKeyErrorProvider.notifier).hideError();
                ref.read(suffixIconVisibilityProvider.notifier).showIcon();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: kScreenPadding),
            CustomTextField(
              controller: privateKeyController,
              labelText: S.of(context).privateKey,
              errorText: showError ? S.of(context).invalidPrivateKey : null,
              suffixIcon: isSuffixIconVisible ? AppIcons.cross : null,
              leadingIcon: AppIcons.importAccount,
              autoCorrect: false,
              onTrailingPressed: () {
                privateKeyController.clear();
                ref.read(suffixIconVisibilityProvider.notifier).hideIcon();
              },
              onChanged: (text) {
                if (text.isNotEmpty) {
                  ref.read(privateKeyErrorProvider.notifier).hideError();
                  ref.read(suffixIconVisibilityProvider.notifier).showIcon();
                } else {
                  ref.read(suffixIconVisibilityProvider.notifier).hideIcon();
                }
              },
            ),
            const SizedBox(height: kScreenPadding),
          ],
        ),
      ),
      bottomNavigationBar: CustomButton(
        isBottomNavigationPosition: true,
        text: S.of(context).import,
        isFullWidth: true,
        onPressed: () async {
          if (privateKeyController.text.isEmpty) {
            ref.read(privateKeyErrorProvider.notifier).showError();
          } else {
            await _importAccount();
          }
        },
      ),
    );
  }

  Future<void> _importAccount() async {
    try {
      final privateKeyInput = privateKeyController.text.trim();

      await ref
          .read(temporaryAccountProvider.notifier)
          .restoreAccountFromPrivateKey(privateKeyInput);
      privateKeyController.clear();

      if (!mounted) return;

      GoRouter.of(context).push(widget.accountFlow == AccountFlow.setup
          ? '/setup/setupNameAccount'
          : '/addAccount/addAccountNameAccount');
    } catch (e) {
      showCustomSnackBar(
        context: context,
        snackType: SnackType.error,
        message: e.toString(),
      );
    }
  }
}
