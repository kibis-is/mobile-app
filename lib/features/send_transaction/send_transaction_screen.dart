import 'dart:convert';
import 'package:algorand_dart/algorand_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/common_widgets/custom_dropdown.dart';
import 'package:kibisis/common_widgets/custom_text_field.dart';
import 'package:kibisis/common_widgets/pin_pad_dialog.dart';
import 'package:kibisis/common_widgets/top_snack_bar.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/send_transaction/providers/selected_asset_provider.dart';
import 'package:kibisis/models/detailed_asset.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/algorand_provider.dart';
import 'package:kibisis/providers/assets_provider.dart';
import 'package:kibisis/providers/balance_provider.dart';
import 'package:kibisis/providers/loading_provider.dart';
import 'package:kibisis/providers/network_provider.dart';
import 'package:kibisis/utils/refresh_account_data.dart';

final dropdownItemsProvider = StateProvider<List<SelectItem>>((ref) => []);

final sendTransactionScreenModeProvider =
    StateProvider<SendTransactionScreenMode>((ref) {
  return SendTransactionScreenMode.currency;
});

class SendTransactionScreen extends ConsumerStatefulWidget {
  final SendTransactionScreenMode mode;
  final int? assetId;
  const SendTransactionScreen({
    this.assetId,
    this.mode = SendTransactionScreenMode.currency,
    super.key,
  });

  @override
  SendTransactionScreenState createState() => SendTransactionScreenState();
}

class SendTransactionScreenState extends ConsumerState<SendTransactionScreen> {
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
      ref.read(selectedAssetProvider.notifier).selectAsset(
          items: items, assetId: widget.assetId, mode: widget.mode);
    }
  }

  Future<List<SelectItem>> _getAssetsAndCurrenciesAsList(WidgetRef ref) async {
    final assetsAsync = ref.read(assetsProvider);
    final network = ref.read(networkProvider);

    if (assetsAsync is! AsyncData<List<DetailedAsset>>) {
      // If assets are not loaded yet, return empty list
      return [];
    }

    final assets = assetsAsync.value;
    List<SelectItem> combinedList = assets.map((asset) {
      return SelectItem(
          name: asset.name ?? 'Unnamed Asset',
          value: asset.assetId.toString(),
          icon: '0xf02b2');
    }).toList();

    combinedList.insert(
      0,
      network ??
          SelectItem(
            name: 'No Network',
            value: "-1",
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

  Future<bool> hasSufficientFunds(String publicAddress, String value) async {
    try {
      // await ref.read(balanceProvider.notifier).getBalance(publicAddress);

      final balanceAsync = ref.read(balanceProvider(publicAddress));

      return balanceAsync.maybeWhen(
        data: (balance) => double.parse(balance) >= double.parse(value),
        orElse: () => false,
      );
    } catch (e) {
      debugPrint('Error checking sufficient funds: $e');
      return false;
    }
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

  Future<bool> _validateForm(WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) return false;
    final publicAddress =
        ref.read(accountProvider).account?.publicAddress ?? '';
    final amount = amountController.text;

    if (!await hasSufficientFunds(publicAddress, amount)) {
      _showErrorSnackbar('Insufficient funds');
      return false;
    }

    return true;
  }

  Future<void> _executeTransaction(WidgetRef ref) async {
    if (!await _validateForm(ref)) return;

    ref.read(loadingProvider.notifier).startLoading();
    try {
      final account = ref.read(accountProvider).account;
      double amountInAlgos = double.parse(amountController.text);

      final selectedItem = ref.read(selectedAssetProvider);
      if (selectedItem == null) {
        throw Exception("No item selected for the transaction.");
      }

      if (selectedItem.value.startsWith("network")) {
        final txId = await ref.read(algorandServiceProvider).sendCurrency(
            account!,
            recipientAddressController.text,
            amountInAlgos,
            noteController.text);

        if (txId.isNotEmpty && txId != 'error') {
          _showSuccessSnackbar(txId);
          if (mounted) {
            refreshAccountData(context, ref, account.publicAddress);
          }
        } else {
          throw Exception('Transaction failed');
        }
      } else {
        await ref.read(algorandServiceProvider).transferAsset(
            int.parse(selectedItem.value),
            account!,
            recipientAddressController.text,
            int.parse(amountController.text));

        _showSuccessSnackbar("Asset transfer successful.");
        if (mounted) {
          refreshAccountData(context, ref, account.publicAddress);
        }
      }
    } catch (e) {
      if (e is AlgorandException) {
        String userFriendlyMessage =
            ref.read(algorandServiceProvider).parseAlgorandException(e);
        _showErrorSnackbar(userFriendlyMessage);
      }

      _showErrorSnackbar(e.toString());
      debugPrint('Transaction error: $e');
    } finally {
      ref.read(loadingProvider.notifier).stopLoading();
    }
  }

  void _showSuccessSnackbar(String message) {
    if (mounted) {
      showCustomSnackBar(
        context: context,
        snackType: SnackType.success,
        message: 'Transaction successful: $message',
      );
    }
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      showCustomSnackBar(
        context: context,
        snackType: SnackType.error,
        message: 'Error: $message',
      );
    }
  }

  String get _getAppBarTitle =>
      'Send ${widget.mode == SendTransactionScreenMode.currency ? 'Currency' : 'Asset'}';

  void _showPinPadDialog(WidgetRef ref) async {
    if (await _validateForm(ref)) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => PinPadDialog(
            title: 'Verify PIN',
            onPinVerified: () async {
              if (mounted) {
                ref.read(loadingProvider.notifier).startLoading();
              }
              await _executeTransaction(ref);
              goBack();
              ref.read(loadingProvider.notifier).stopLoading();
            },
          ),
        );
      }
    }
  }

  void goBack() {
    Navigator.of(context).pop();
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
          ref.read(selectedAssetProvider.notifier).setAsset(newValue);
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
