import 'dart:convert';
import 'package:algorand_dart/algorand_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/common_widgets/custom_bottom_sheet.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/common_widgets/custom_dropdown.dart';
import 'package:kibisis/common_widgets/custom_text_field.dart';
import 'package:kibisis/common_widgets/pin_pad_dialog.dart';
import 'package:kibisis/common_widgets/top_snack_bar.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/dashboard/providers/transactions_provider.dart';
import 'package:kibisis/features/send_transaction/providers/selected_asset_provider.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/active_asset_provider.dart';
import 'package:kibisis/providers/algorand_provider.dart';
import 'package:kibisis/providers/assets_provider.dart';
import 'package:kibisis/providers/balance_provider.dart';
import 'package:kibisis/providers/loading_provider.dart';
import 'package:kibisis/providers/minimum_balance_provider.dart';
import 'package:kibisis/providers/network_provider.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/theme_extensions.dart';

final dropdownItemsProvider = StateProvider<List<SelectItem>>((ref) => []);

final sendTransactionScreenModeProvider =
    StateProvider<SendTransactionScreenMode>((ref) {
  return SendTransactionScreenMode.payment;
});

class SendTransactionScreen extends ConsumerStatefulWidget {
  final SendTransactionScreenMode mode;

  const SendTransactionScreen({
    this.mode = SendTransactionScreenMode.payment,
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
      final activeAsset = ref.read(activeAssetProvider);
      ref.read(selectedAssetProvider.notifier).selectAsset(
          items: items, assetId: activeAsset?.index ?? 0, mode: widget.mode);
    }
  }

  Future<List<SelectItem>> _getAssetsAndCurrenciesAsList(WidgetRef ref) async {
    final assetsAsync = ref.read(assetsProvider);
    final network = ref.read(networkProvider);

    if (assetsAsync is! AsyncData<List<Asset>>) {
      // If assets are not loaded yet, return empty list
      return [];
    }

    final assets = assetsAsync.value;
    List<SelectItem> combinedList = assets.map((asset) {
      return SelectItem(
        name: asset.params.name ?? 'Unnamed Asset',
        value: asset.index.toString(),
        icon: AppIcons.asset,
      );
    }).toList();

    //insert the network (voi or algorand) item at the beginning of the list
    combinedList.insert(
      0,
      network ??
          SelectItem(
            name: 'No Network',
            value: "-1",
            icon: AppIcons.error,
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
      final balance = await getMaxAmount(ref);

      return balance >= double.parse(value);
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
        final txId = await ref.read(algorandServiceProvider).sendPayment(
            account!,
            recipientAddressController.text,
            amountInAlgos,
            noteController.text);

        if (txId.isNotEmpty && txId != 'error') {
          _showSuccessSnackbar(txId);
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
      }

      ref.invalidate(transactionsProvider);
      ref.invalidate(balanceProvider);
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

// Helper function to get the balance as a double
  double getBalance(WidgetRef ref) {
    return ref.watch(balanceProvider);
  }

  Future<double> getMaxAmount(WidgetRef ref) async {
    final double balance = getBalance(ref);
    final double minimumBalance = ref.watch(minimumBalanceProvider);
    const double transactionFee = 0.0001;
    final sum = balance - minimumBalance - transactionFee;

    return sum < 0 ? 0 : sum;
  }

  Widget buildMaxAmountDisplay(WidgetRef ref) {
    final selectedItem = ref.watch(selectedAssetProvider);
    bool isNetworkSelected = selectedItem?.value.startsWith("network") ?? false;

    if (isNetworkSelected) {
      // Asynchronous fetching of maximum payment amount
      return FutureBuilder<double>(
        future: getMaxAmount(ref),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return Text('Max: ${snapshot.data?.toStringAsFixed(2)}');
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
          }
          return const Text('Calculating...');
        },
      );
    } else {
      // Direct synchronous access for asset mode
      final int maxAssetAmount =
          ref.read(activeAssetProvider)?.params.total ?? 0;
      final assetName = selectedItem?.name ?? 'Asset';
      return Text('Max: $maxAssetAmount $assetName');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Send"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
          child: Form(
            key: _formKey,
            child: Consumer(
              builder: (context, ref, child) {
                final dropdownItems = ref.watch(dropdownItemsProvider);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _maxSendInfo(context, ref),
                    const SizedBox(height: kScreenPadding),
                    _buildCustomDropDown(ref, dropdownItems),
                    const SizedBox(height: kScreenPadding),
                    _buildAmountTextField(),
                    const SizedBox(height: kScreenPadding),
                    _buildRecipientAddressTextField(),
                    const SizedBox(height: kScreenPadding),
                    _buildNoteTextField(),
                    if (_remainingBytes < 1000) _buildRemainingBytesIndicator(),
                    const SizedBox(height: kScreenPadding),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(kScreenPadding),
        child: CustomButton(
          isFullWidth: true,
          text: "Send",
          onPressed: () => _showPinPadDialog(ref),
        ),
      ),
    );
  }

  Row _maxSendInfo(BuildContext context, WidgetRef ref) {
    final selectedItem = ref.watch(selectedAssetProvider);
    bool isNetworkSelected = selectedItem?.value.startsWith("network") ?? false;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isNetworkSelected)
          IconButton(
            icon: AppIcons.icon(
              icon: AppIcons.info,
              size: AppIcons.small,
              color: context.colorScheme.onBackground,
            ),
            iconSize: kScreenPadding,
            onPressed: () {
              customBottomSheet(
                context: context,
                singleWidget: Text(
                  'The maximum VOI amount is calculated by: the balance (${ref.watch(balanceProvider)}), '
                  'minus the minimum balance needed to keep the account open (${ref.watch(minimumBalanceProvider)}), '
                  'minus the minimum transaction fee (0.001)',
                  softWrap: true,
                  style: context.textTheme.bodyMedium,
                ),
                header: "Info",
                onPressed: (SelectItem item) {},
              );
            },
          ),
        buildMaxAmountDisplay(ref),
      ],
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
      suffixIcon: AppIcons.scan,
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
