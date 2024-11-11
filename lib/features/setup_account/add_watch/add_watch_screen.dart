import 'package:algorand_dart/algorand_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/common_widgets/custom_text_field.dart';
import 'package:kibisis/common_widgets/top_snack_bar.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/generated/l10n.dart';
import 'package:kibisis/providers/temporary_account_provider.dart';
import 'package:kibisis/utils/app_icons.dart';

class AddWatchScreen extends ConsumerWidget {
  static String title = S.current.importPublicAddress;
  final AccountFlow accountFlow;

  const AddWatchScreen({super.key, required this.accountFlow});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publicAddressController = TextEditingController();
    final isSuffixIconVisible = publicAddressController.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: AppIcons.icon(icon: AppIcons.paste),
            onPressed: () async {
              ClipboardData? clipData = await Clipboard.getData('text/plain');
              if (clipData != null) {
                publicAddressController.text = clipData.text ?? '';
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
              controller: publicAddressController,
              labelText: S.of(context).publicAddress,
              suffixIcon: isSuffixIconVisible ? AppIcons.cross : null,
              leadingIcon: AppIcons.importAccount,
              autoCorrect: false,
              onTrailingPressed: () {
                publicAddressController.clear();
              },
              onChanged: (text) {},
            ),
            const SizedBox(height: kScreenPadding),
          ],
        ),
      ),
      bottomNavigationBar: CustomButton(
        isBottomNavigationPosition: true,
        text: S.of(context).import,
        isFullWidth: true,
        onPressed: () {
          if (publicAddressController.text.isEmpty) {
            showCustomSnackBar(
              context: context,
              snackType: SnackType.error,
              message: S.of(context).pleaseEnterPublicAddress,
            );
          } else {
            _addWatchAccount(
              context,
              ref,
              publicAddressController.text.trim(),
            );
          }
        },
      ),
    );
  }

  Future<void> _addWatchAccount(
      BuildContext context, WidgetRef ref, String publicAddress) async {
    try {
      final isValid = _isValidAlgorandAddress(publicAddress);
      if (!isValid) {
        showCustomSnackBar(
          context: context,
          snackType: SnackType.error,
          message: S.of(context).invalidAlgorandAddress,
        );
        return;
      }

      await ref
          .read(temporaryAccountProvider.notifier)
          .createWatchAccount(publicAddress);

      if (!context.mounted) return;
      GoRouter.of(context).push(accountFlow == AccountFlow.setup
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

  bool _isValidAlgorandAddress(String address) {
    try {
      Address.fromAlgorandAddress(address: address);
      return true;
    } catch (e) {
      return false;
    }
  }
}
