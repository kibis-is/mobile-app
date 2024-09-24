import 'dart:convert';
import 'dart:io';
import 'package:algorand_dart/algorand_dart.dart';
import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_bottom_sheet.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/common_widgets/custom_dialog_picker.dart';
import 'package:kibisis/common_widgets/custom_dropdown.dart';
import 'package:kibisis/common_widgets/custom_text_field.dart';
import 'package:kibisis/common_widgets/pin_pad_dialog.dart';
import 'package:kibisis/common_widgets/top_snack_bar.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/dashboard/providers/transactions_provider.dart';
import 'package:kibisis/features/send_transaction/providers/selected_asset_provider.dart';
import 'package:kibisis/models/combined_asset.dart';
import 'package:kibisis/models/select_item.dart';
import 'package:kibisis/models/watch_account.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/accounts_list_provider.dart';
import 'package:kibisis/providers/active_asset_provider.dart';
import 'package:kibisis/providers/algorand_provider.dart';
import 'package:kibisis/providers/assets_provider.dart';
import 'package:kibisis/providers/balance_provider.dart';
import 'package:kibisis/providers/loading_provider.dart';
import 'package:kibisis/providers/minimum_balance_provider.dart';
import 'package:kibisis/providers/network_provider.dart';
import 'package:kibisis/providers/storage_provider.dart';
import 'package:kibisis/routing/named_routes.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/number_shortener.dart';
import 'package:kibisis/utils/theme_extensions.dart';

final dropdownItemsProvider = StateProvider<List<SelectItem>>((ref) => []);

final sendTransactionScreenModeProvider =
    StateProvider<SendTransactionScreenMode>((ref) {
  return SendTransactionScreenMode.payment;
});

class SendTransactionScreen extends ConsumerStatefulWidget {
  final SendTransactionScreenMode mode;
  final String? address;

  const SendTransactionScreen({
    this.mode = SendTransactionScreenMode.payment,
    this.address,
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
  int _remainingBytes = 1000;

  @override
  void initState() {
    super.initState();
    noteController.addListener(_updateRemainingBytes);
    if (widget.address != null) {
      recipientAddressController.text = widget.address!;
    }
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

    if (assetsAsync is! AsyncData<List<CombinedAsset>>) {
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
    try {
      final accountId = ref.read(accountProvider).accountId;
      if (accountId == null) {
        throw Exception("No active account ID found");
      }

      final privateKey = await ref
          .read(storageProvider)
          .getAccountData(accountId, 'privateKey');
      if (privateKey == null || privateKey.isEmpty) {
        throw Exception("Private key not found in storage");
      }

      final algorand = ref.read(algorandProvider);
      final account = await algorand.loadAccountFromPrivateKey(privateKey);

      double amountInAlgos = double.parse(amountController.text);
      final selectedItem = ref.read(selectedAssetProvider);
      if (selectedItem == null) {
        throw Exception("No item selected for the transaction.");
      }
      if (selectedItem.value.startsWith("network")) {
        final txId = await ref.read(algorandServiceProvider).sendPayment(
            account,
            recipientAddressController.text,
            amountInAlgos,
            noteController.text);

        if (txId.isEmpty || txId == 'error') {
          throw Exception('Transaction failed');
        }
        _showSuccessSnackbar(txId);
      } else {
        await ref.read(algorandServiceProvider).transferAsset(
            int.parse(selectedItem.value),
            account,
            recipientAddressController.text,
            int.parse(amountController.text));
        _showSuccessSnackbar("Asset transfer successful.");
      }
      ref.invalidate(transactionsProvider);
      ref.invalidate(balanceProvider);
    } on AlgorandException catch (e) {
      String errorMessage =
          ref.read(algorandServiceProvider).parseAlgorandException(e);
      debugPrint('AlgorandException: $errorMessage');
      _showErrorSnackbar(errorMessage);
    } catch (e) {
      String errorMessage = e.toString();
      debugPrint('Error: $errorMessage');
      _showErrorSnackbar(errorMessage);
    } finally {
      goBack();
    }
  }

  void _showSuccessSnackbar(String message) {
    if (mounted) {
      showCustomSnackBar(
        context: context,
        snackType: SnackType.success,
        message: 'Transaction successful',
      );
    }
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      showCustomSnackBar(
        context: context,
        snackType: SnackType.error,
        message: message,
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
              ref.read(loadingProvider.notifier).startLoading(
                    message: widget.mode == SendTransactionScreenMode.payment
                        ? 'Sending Payment'
                        : 'Sending Asset',
                    withProgressBar: true,
                  );

              try {
                if (await _validateForm(ref)) {
                  await _executeTransaction(ref);
                  goBack();
                }
              } catch (e) {
                debugPrint("Error during transaction: $e");
                ref.read(loadingProvider.notifier).stopLoading();
              }
            },
          ),
        );
      }
    }
  }

  void goBack() {
    ref.invalidate(transactionsProvider);
    ref.invalidate(balanceProvider);
    GoRouter.of(context).goNamed(rootRouteName);
  }

  Future<double> getMaxAmount(WidgetRef ref) async {
    final double balance = ref.watch(balanceProvider).when(
          data: (balance) => balance,
          loading: () => 0.0,
          error: (error, stackTrace) => 0.0,
        );

    final double minimumBalance = ref.watch(minimumBalanceProvider);
    const double transactionFee = 0.0001;
    final sum = balance - minimumBalance - transactionFee;

    return sum < 0 ? 0 : sum;
  }

  Widget buildMaxAmountDisplay(WidgetRef ref) {
    final selectedItem = ref.watch(selectedAssetProvider);
    bool isNetworkSelected = selectedItem?.value.startsWith("network") ?? false;

    if (isNetworkSelected) {
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
      final int maxAssetAmount =
          ref.read(activeAssetProvider)?.params.total ?? 0;
      final String formattedAmount =
          NumberShortener.shortenNumber(maxAssetAmount.toDouble());
      return Text('Max: $formattedAmount');
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeAccount = ref.watch(accountProvider).account;
    final isWatchAccount = activeAccount is WatchAccount;

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
                    _buildRecipientAddressTextField(context, ref),
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
      bottomNavigationBar: isWatchAccount
          ? const SizedBox.shrink()
          : CustomButton(
              isBottomNavigationPosition: true,
              isFullWidth: true,
              text: "Send",
              onPressed: () => _showPinPadDialog(ref),
            ),
    );
  }

  Row _maxSendInfo(BuildContext context, WidgetRef ref) {
    final selectedItem = ref.watch(selectedAssetProvider);
    final accountName = ref.watch(accountProvider).accountName;
    bool isNetworkSelected = selectedItem?.value.startsWith("network") ?? false;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        EllipsizedText(
          accountName ?? 'No Account',
          ellipsis: '...',
          type: EllipsisType.end,
          style: context.textTheme.bodyMedium,
        ),
        Row(
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
        ),
      ],
    );
  }

  Widget _buildCustomDropDown(WidgetRef ref, List<SelectItem> dropdownItems) {
    final isDisabled = dropdownItems.length <= 1;

    return GestureDetector(
      onTap: isDisabled ? () {} : null,
      child: AbsorbPointer(
        absorbing: isDisabled,
        child: CustomDropDown(
          label: 'Asset',
          items: dropdownItems,
          selectedValue: ref.watch(selectedAssetProvider),
          onChanged: (SelectItem? newValue) {
            if (newValue != null) {
              ref.read(selectedAssetProvider.notifier).setAsset(newValue);
            }
          },
        ),
      ),
    );
  }

  Widget _buildAmountTextField() {
    return CustomTextField(
      labelText: 'Amount',
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      textAlign: TextAlign.right,
      autoCorrect: false,
      leadingIcon: AppIcons.advanced,
      controller: amountController,
      validator: _validateAmount,
      onTap: () {
        if (amountController.text == '0') {
          amountController.clear();
        }
      },
    );
  }

  Widget _buildRecipientAddressTextField(BuildContext context, WidgetRef ref) {
    final isMobile = (Platform.isAndroid || Platform.isIOS) ? true : false;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CustomTextField(
            labelText: 'Recipient Address',
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            controller: recipientAddressController,
            leadingIcon: AppIcons.addAccount,
            suffixIcon: AppIcons.scan,
            autoCorrect: false,
            onTrailingPressed: isMobile
                ? () async {
                    getScannedAddress(context, ref);
                  }
                : null,
            validator: _validateAlgorandAddress,
          ),
        ),
        IconButton(
          style: ButtonStyle(
            padding: MaterialStateProperty.all<EdgeInsets>(
              const EdgeInsets.symmetric(
                  horizontal: kScreenPadding, vertical: 14),
            ),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100.0),
              ),
            ),
            foregroundColor: MaterialStateProperty.all<Color>(
              context.colorScheme.onSurface,
            ),
          ),
          icon: const Icon(AppIcons.addAccount),
          onPressed: () {
            _showAddressBook(context, ref);
          },
        ),
      ],
    );
  }

  Future<void> _showAddressBook(BuildContext context, WidgetRef ref) async {
    final accountsState = ref.watch(accountsListProvider);

    if (accountsState.error != null) {
      return showGeneralDialog<void>(
        context: context,
        barrierDismissible: true,
        barrierLabel: '',
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation1, animation2) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            titlePadding: const EdgeInsets.all(kScreenPadding),
            title: const Text('Error'),
            content: Text(accountsState.error!),
          );
        },
      );
    }

    if (accountsState.isLoading) {
      await ref.read(accountsListProvider.notifier).loadAccounts();
    }

    final accounts = ref.read(accountsListProvider).accounts;

    if (!context.mounted) return;

    final selectedAccount = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return CustomAlertDialog(
          title: 'Select Address',
          icon: AppIcons.contacts,
          items: accounts,
        );
      },
    );

    if (selectedAccount != null) {
      recipientAddressController.text = selectedAccount['publicKey']!;
    }
  }

  Widget _buildNoteTextField() {
    return CustomTextField(
      labelText: 'Note (Optional)',
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      maxLines: 3,
      controller: noteController,
      validator: _validateNote,
      leadingIcon: AppIcons.about,
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

  void getScannedAddress(BuildContext context, WidgetRef ref) async {
    final mode = ref.watch(sendTransactionScreenModeProvider);
    final scannedData = await GoRouter.of(context).pushNamed(
      sendTransactionQrScannerRouteName,
      pathParameters: {
        'mode': mode == SendTransactionScreenMode.payment ? 'payment' : 'asset',
      },
      extra: ScanMode.publicKey,
    );

    if (scannedData != null) {
      recipientAddressController.text = scannedData as String;
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
