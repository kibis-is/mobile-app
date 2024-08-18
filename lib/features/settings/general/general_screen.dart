import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/confirmation_dialog.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/common_widgets/pin_pad_dialog.dart';
import 'package:kibisis/common_widgets/top_snack_bar.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/loading_provider.dart';
import 'package:kibisis/routing/named_routes.dart';
import 'package:kibisis/utils/app_reset_util.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class GeneralScreen extends ConsumerWidget {
  static const String title = 'General'; // Use const for compile-time constants
  const GeneralScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text(title)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: kScreenPadding),
            _buildDangerZoneTitle(context),
            const SizedBox(height: kScreenPadding / 2),
            _buildDangerZoneDescription(context),
            const SizedBox(height: kScreenPadding),
            _buildResetButton(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerZoneTitle(BuildContext context) {
    return Text(
      'Danger Zone',
      style: context.textTheme.bodyMedium?.copyWith(
        color: context.colorScheme.error,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDangerZoneDescription(BuildContext context) {
    return Text(
      'This will remove all accounts, settings, and security information.',
      style: context.textTheme.bodySmall,
    );
  }

  Widget _buildResetButton(BuildContext context, WidgetRef ref) {
    return CustomButton(
      text: 'Reset',
      isFullWidth: true,
      buttonType: ButtonType.warning,
      onPressed: () => _handleResetPressed(context, ref),
    );
  }

  Future<void> _handleResetPressed(BuildContext context, WidgetRef ref) async {
    bool confirm = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => const ConfirmationDialog(
            yesText: 'Reset',
            noText: 'Cancel',
            content:
                'Are you sure you want to reset this device? This will remove all accounts, settings, and security information.',
          ),
        ) ??
        false;

    if (confirm) {
      if (!context.mounted) return;
      _showPinPadDialog(context, ref);
    }
  }

  void _handleResetApp(WidgetRef ref, BuildContext context) {
    try {
      ref
          .read(loadingProvider.notifier)
          .startLoading(message: 'Resetting App', fullScreen: true);
      AppResetUtil.resetApp(ref);
      GoRouter.of(context).go('/setup');
    } catch (e) {
      showCustomSnackBar(
        context: context,
        snackType: SnackType.error,
        message: e.toString(),
      );
      ref.read(loadingProvider.notifier).stopLoading();
    }
  }

  void _showPinPadDialog(BuildContext context, WidgetRef ref) async {
    await showDialog(
      context: context,
      builder: (context) => PinPadDialog(
        title: 'Confirm Reset',
        onPinVerified: () {
          _handleResetApp(ref, context);
          GoRouter.of(context).goNamed(welcomeRouteName);
        },
      ),
    );
  }
}
