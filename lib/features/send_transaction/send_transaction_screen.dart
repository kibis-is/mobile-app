import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/common_widgets/custom_dropdown.dart';
import 'package:kibisis/common_widgets/custom_text_field.dart';
import 'package:kibisis/common_widgets/pin_pad_dialog.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/algorand_provider.dart';
import 'package:kibisis/providers/loading_provider.dart';
import 'package:kibisis/providers/network_provider.dart';

final dropdownItemsProvider = StateProvider<List<SelectItem>>((ref) => []);

final sendTransactionScreenModeProvider =
    StateProvider<SendTransactionScreenMode>((ref) {
  return SendTransactionScreenMode.currency;
});

final selectedAssetProvider = StateProvider<SelectItem?>((ref) {
  final items = ref.watch(dropdownItemsProvider);
  final mode = ref.watch(sendTransactionScreenModeProvider);

  if (items.isEmpty) {
    return SelectItem(name: 'No Items', value: -1, icon: '0xe3af');
  }
  if (mode == SendTransactionScreenMode.currency) {
    return items[0];
  } else if (mode == SendTransactionScreenMode.asset && items.length > 1) {
    return items[1];
  }
  return items[0];
});

class SendTransactionScreen extends ConsumerStatefulWidget {
  final SendTransactionScreenMode mode;
  const SendTransactionScreen(
      {this.mode = SendTransactionScreenMode.currency, super.key});

  @override
  SendCurrencyScreenState createState() => SendCurrencyScreenState();
}

class SendCurrencyScreenState extends ConsumerState<SendTransactionScreen> {
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sendTransactionScreenModeProvider.notifier).state = widget.mode;
      _loadAssetsAndCurrencies();
    });
  }

  void _updateRemainingBytes() {
    final bytes = utf8.encode(noteController.text).length;
    setState(() {
      _remainingBytes = 1000 - bytes;
    });
  }

  Future<void> _loadAssetsAndCurrencies() async {
    final items = await _getAssetsAndCurrenciesAsList(ref);
    if (mounted) {
      ref.read(dropdownItemsProvider.notifier).state = items;
    }
  }

  Future<List<SelectItem>> _getAssetsAndCurrenciesAsList(WidgetRef ref) async {
    final publicAddress =
        ref.read(accountProvider).account?.publicAddress ?? '';
    final assets =
        await ref.read(algorandServiceProvider).getAccountAssets(publicAddress);

    List<SelectItem> combinedList = assets.map((asset) {
      return SelectItem(
          name: asset.name ?? 'Unnamed Asset',
          value: asset.assetId,
          icon: '0xf02b2');
    }).toList();

    final network = ref.read(networkProvider);
    combinedList.insert(
      0,
      network ??
          SelectItem(
            name: 'No Network',
            value: -1,
            icon: '0xe3af',
          ),
    );
    return combinedList;
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
    if (value == null) return null;
    final bytes = utf8.encode(value).length;
    if (bytes > 1000) {
      return 'Note exceeds the maximum size of 1000 bytes';
    }
    return null;
  }

  Future<void> _sendCurrency(WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) return;

    ref.read(loadingProvider.notifier).startLoading();
    try {
      final account = ref.read(accountProvider).account;
      double amountInAlgos = double.parse(amountController.text);

      final txId = await ref.read(algorandServiceProvider).sendCurrency(
          account!,
          recipientAddressController.text,
          amountInAlgos,
          noteController.text);

      if (txId.isNotEmpty && txId != 'error') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Transaction successful: $txId')),
          );
        }
      } else {
        throw Exception('Transaction failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
      debugPrint('Transaction error: $e');
    } finally {
      ref.read(loadingProvider.notifier).stopLoading();
    }
  }

  String get _getAppBarTitle =>
      'Send ${widget.mode == SendTransactionScreenMode.currency ? 'Currency' : 'Asset'}';

  void _showPinPadDialog(WidgetRef ref) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
        child: Form(
          key: _formKey,
          child: Consumer(
            builder: (context, ref, child) {
              final dropdownItems = ref.watch(dropdownItemsProvider);
              return Column(
                children: [
                  const SizedBox(height: kScreenPadding),
                  _buildCustomDropDown(ref, dropdownItems),
                  const SizedBox(height: kScreenPadding),
                  _buildAmountTextField(),
                  const SizedBox(height: kScreenPadding),
                  _buildRecipientAddressTextField(),
                  const SizedBox(height: kScreenPadding),
                  _buildNoteTextField(),
                  if (_remainingBytes < 1000) _buildRemainingBytesIndicator(),
                  const Expanded(child: SizedBox(height: kScreenPadding)),
                  CustomButton(
                    isFullWidth: true,
                    text: 'Send',
                    onPressed: () => _showPinPadDialog(ref),
                  ),
                  const SizedBox(height: kScreenPadding),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCustomDropDown(WidgetRef ref, List<SelectItem> dropdownItems) {
    return CustomDropDown(
      label: 'Asset',
      items: dropdownItems,
      selectedValue: ref.watch(selectedAssetProvider),
      onChanged: (SelectItem? newValue) {
        if (newValue != null) {
          ref.read(selectedAssetProvider.notifier).state = newValue;
        }
      },
    );
  }

  Widget _buildAmountTextField() {
    return CustomTextField(
      labelText: 'Amount',
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      textAlign: TextAlign.right,
      autoCorrect: false,
      controller: amountController,
      validator: _validateAmount,
    );
  }

  Widget _buildRecipientAddressTextField() {
    return CustomTextField(
      labelText: 'Recipient Address',
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      controller: recipientAddressController,
      suffixIcon: Icons.qr_code_scanner,
      autoCorrect: false,
      onTrailingPressed: () {},
      validator: _validateAlgorandAddress,
    );
  }

  Widget _buildNoteTextField() {
    return CustomTextField(
      labelText: 'Note (Optional)',
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      maxLines: 3,
      controller: noteController,
      validator: _validateNote,
    );
  }

  Widget _buildRemainingBytesIndicator() {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
        child: Text(
          '$_remainingBytes / 1000',
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
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
