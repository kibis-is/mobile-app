import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/common_widgets/custom_snackbar.dart';
import 'package:kibisis/common_widgets/custom_text_field.dart';
import 'package:kibisis/common_widgets/pin_pad_dialog.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/loading_provider.dart';

class SendCurrencyScreen extends ConsumerStatefulWidget {
  static String title = 'Send Currency';
  const SendCurrencyScreen({super.key});

  @override
  SendCurrencyScreenState createState() => SendCurrencyScreenState();
}

class SendCurrencyScreenState extends ConsumerState<SendCurrencyScreen> {
  final TextEditingController amountController =
      TextEditingController(text: '0');
  final TextEditingController recipientAddressController =
      TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int _remainingBytes = 1000; // Initialize with max bytes allowed

  @override
  void initState() {
    super.initState();
    noteController.addListener(_updateRemainingBytes);
  }

  void _updateRemainingBytes() {
    final bytes = utf8.encode(noteController.text).length;
    setState(() {
      _remainingBytes = 1000 - bytes;
    });
  }

  bool _isValidAmount(String value) {
    if (value.isEmpty) return false;
    final number = double.tryParse(value);
    return number != null && number >= 0;
  }

  bool _isValidAlgorandAddress(String value) {
    return value.length == 58 && RegExp(r'^[A-Z2-7]+$').hasMatch(value);
  }

  String? _validateAmount(String? value) {
    if (value == null || !_isValidAmount(value)) {
      return 'Please enter a valid amount';
    }
    return null;
  }

  String? _validateAlgorandAddress(String? value) {
    if (value == null || !_isValidAlgorandAddress(value)) {
      return 'Please enter a valid Algorand address';
    }
    return null;
  }

  String? _validateNote(String? value) {
    if (value == null) return null; // Optional field, pass if null
    final bytes = utf8.encode(value).length;
    if (bytes > 1000) {
      return 'Note exceeds the maximum size of 1000 bytes';
    }
    return null;
  }

  Future<void> _sendCurrency(WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) return;
    // Existing send currency logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SendCurrencyScreen.title)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: kScreenPadding),
              CustomTextField(
                labelText: 'Amount',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                textAlign: TextAlign.right,
                controller: amountController,
                validator: _validateAmount,
              ),
              const SizedBox(height: kScreenPadding),
              CustomTextField(
                labelText: 'Recipient Address',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                controller: recipientAddressController,
                suffixIcon: Icons.qr_code_scanner,
                onTrailingPressed: () {},
                validator: _validateAlgorandAddress,
              ),
              const SizedBox(height: kScreenPadding),
              CustomTextField(
                labelText: 'Note (Optional)',
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                maxLines: 3,
                controller: noteController,
                validator: _validateNote,
              ),
              if (_remainingBytes <
                  1000) // Only show if user has started typing
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                    child: Text(
                      '$_remainingBytes bytes remaining',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              const Expanded(child: SizedBox(height: kScreenPadding)),
              CustomButton(
                isFullWidth: true,
                text: 'Send',
                onPressed: () => _showPinPadDialog(ref),
              ),
              const SizedBox(height: kScreenPadding),
            ],
          ),
        ),
      ),
    );
  }

  void _showPinPadDialog(WidgetRef ref) {
    // First validate the form
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => PinPadDialog(
          title: 'Enter PIN',
          onPinVerified: () async {
            if (mounted) {
              ref.read(loadingProvider.notifier).startLoading();
            }
            await _sendCurrency(ref);
            if (mounted) {
              ref.read(loadingProvider.notifier).stopLoading();
            }
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    noteController.removeListener(_updateRemainingBytes);
    noteController.dispose();
    amountController.dispose();
    recipientAddressController.dispose();
    super.dispose();
  }
}
