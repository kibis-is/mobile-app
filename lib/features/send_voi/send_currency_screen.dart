import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/common_widgets/custom_snackbar.dart';
import 'package:kibisis/common_widgets/custom_text_field.dart';
import 'package:kibisis/common_widgets/pin_pad_dialog.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/algorand_provider.dart';

class SendCurrencyScreen extends ConsumerStatefulWidget {
  static String title = 'Send Currency';
  const SendCurrencyScreen({super.key});

  @override
  SendCurrencyScreenState createState() => SendCurrencyScreenState();
}

class SendCurrencyScreenState extends ConsumerState<SendCurrencyScreen> {
  final TextEditingController amountController =
      TextEditingController(text: 0.toString());
  final TextEditingController recipientAddressController =
      TextEditingController();
  final TextEditingController noteController = TextEditingController();

  @override
  void dispose() {
    amountController.dispose();
    recipientAddressController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> _sendCurrency(WidgetRef ref) async {
    final account = ref.read(accountProvider).account;
    double amountInAlgos = 0.0;
    try {
      amountInAlgos = double.parse(amountController.text);

      final txId = await ref.read(algorandServiceProvider).sendCurrency(
          account!, recipientAddressController.text, amountInAlgos);

      if (mounted) {
        _handleTransactionResult(txId);
      }
    } catch (e) {
      debugPrint("Error: The string is not a valid double.");
    }
  }

  void _handleTransactionResult(String txId) {
    if (!mounted) return;

    if (txId.isNotEmpty && txId != 'error') {
      ScaffoldMessenger.of(context).showSnackBar(
        customSnackbar(
          context: context,
          message: 'Payment Sent Successfully.',
          snackType: SnackType.success,
        ),
      );
      GoRouter.of(context).go('/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        customSnackbar(
          context: context,
          message: "There was an error sending the payment.",
          snackType: SnackType.error,
        ),
      );
    }
  }

  void _showPinPadDialog() {
    showDialog(
      context: context,
      builder: (context) => PinPadDialog(
        title: 'Enter PIN',
        onPinVerified: () async {
          await _sendCurrency(ref);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(SendCurrencyScreen.title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
        child: Column(
          children: [
            const SizedBox(height: kScreenPadding),
            CustomTextField(
              labelText: 'Amount',
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              textAlign: TextAlign.right,
              controller: amountController,
            ),
            const SizedBox(height: kScreenPadding),
            CustomTextField(
              labelText: 'Recipient Address',
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              controller: recipientAddressController,
              suffixIcon: Icons.qr_code_scanner,
              onTrailingPressed: () {},
            ),
            const SizedBox(height: kScreenPadding),
            CustomTextField(
              labelText: 'Note (Optional)',
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              maxLines: 3,
              controller: noteController,
            ),
            const Expanded(child: SizedBox(height: kScreenPadding)),
            CustomButton(
              isFullWidth: true,
              text: 'Send',
              onPressed: _showPinPadDialog,
            ),
          ],
        ),
      ),
    );
  }
}
