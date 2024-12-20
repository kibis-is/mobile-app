import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_bottom_sheet.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/common_widgets/custom_dropdown.dart';
import 'package:kibisis/common_widgets/custom_text_field.dart';
import 'package:kibisis/common_widgets/pin_pad_dialog.dart';
import 'package:kibisis/common_widgets/top_snack_bar.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/contacts/contacts_dialog.dart';
import 'package:kibisis/features/dashboard/providers/transactions_provider.dart';
import 'package:kibisis/features/send_transaction/providers/selected_asset_provider.dart';
import 'package:kibisis/generated/l10n.dart';
import 'package:kibisis/models/combined_asset.dart';
import 'package:kibisis/models/contact.dart';
import 'package:kibisis/models/select_item.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/accounts_list_provider.dart';
import 'package:kibisis/providers/active_asset_provider.dart';
import 'package:kibisis/providers/algorand_provider.dart';
import 'package:kibisis/providers/assets_provider.dart';
import 'package:kibisis/providers/balance_provider.dart';
import 'package:kibisis/providers/contacts_provider.dart';
import 'package:kibisis/providers/loading_provider.dart';
import 'package:kibisis/providers/minimum_balance_provider.dart';
import 'package:kibisis/providers/storage_provider.dart';
import 'package:kibisis/routing/named_routes.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/first_or_where_null.dart';
import 'package:kibisis/utils/number_shortener.dart';
import 'package:kibisis/utils/theme_extensions.dart';
import 'package:kibisis/providers/network_provider.dart';

final dropdownItemsProvider =
    StateProvider<AsyncValue<List<SelectItem>>>((ref) {
  return const AsyncValue.loading();
});

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
  final TextEditingController activeAccountController =
      TextEditingController(text: '');
  final TextEditingController amountController =
      TextEditingController(text: '0');
  final TextEditingController recipientAddressController =
      TextEditingController();
  final TextEditingController contactNameController = TextEditingController();
  bool saveAsContact = false;
  final TextEditingController noteController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int _remainingBytes = 1000;
  Contact? selectedContact;

  @override
  void initState() {
    super.initState();
    noteController.addListener(_updateRemainingBytes);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final accountName = ref.read(accountProvider).accountName;
      activeAccountController.text = accountName ?? S.of(context).noAccount;
    });

    if (widget.address != null) {
      recipientAddressController.text = widget.address!;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sendTransactionScreenModeProvider.notifier).state = widget.mode;
      ref.read(accountsListProvider.notifier).loadAccounts();
      ref.read(contactsListProvider.notifier).loadContacts();
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
    try {
      ref.read(dropdownItemsProvider.notifier).state =
          const AsyncValue.loading();
      final items = await _getAssetsAndCurrenciesAsList(ref);
      if (mounted) {
        ref.read(dropdownItemsProvider.notifier).state = AsyncValue.data(items);
        final activeAsset = ref.read(activeAssetProvider);
        ref.read(selectedAssetProvider.notifier).selectAsset(
              items: items,
              assetId: activeAsset?.index ?? 0,
              mode: widget.mode,
            );
      }
    } catch (e, stack) {
      ref.read(dropdownItemsProvider.notifier).state =
          AsyncValue.error(e, stack);
    }
  }

  Future<List<SelectItem>> _getAssetsAndCurrenciesAsList(WidgetRef ref) async {
    final publicAddress = ref.read(accountProvider).account?.address;
    if (publicAddress == null || publicAddress.isEmpty) {
      debugPrint('No public address available');
      return [];
    }

    final assetsAsync = ref.read(assetsProvider(publicAddress));
    if (assetsAsync is! AsyncData<List<CombinedAsset>>) {
      return [];
    }

    final assets = assetsAsync.value;
    final network = ref.read(networkProvider);

    List<SelectItem> combinedList = assets.map((asset) {
      return SelectItem(
        name: asset.params.name ?? S.of(context).unnamedAsset,
        value: asset.index.toString(),
        icon: AppIcons.asset,
        assetType: asset.assetType,
      );
    }).toList();

    combinedList.insert(
      0,
      network ??
          SelectItem(
              name: S.of(context).noNetwork, value: "-1", icon: AppIcons.error),
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
      return S.of(context).pleaseEnterValidAmount;
    }
    return null;
  }

  String? _validateAlgorandAddress(String? value) {
    if (value == null || !_isValidAlgorandAddress(value)) {
      return S.of(context).pleaseEnterValidAlgorandAddress;
    }
    return null;
  }

  String? _validateNote(String? value) {
    if (value == null) return null;
    final bytes = utf8.encode(value).length;
    if (bytes > 1000) {
      return S.of(context).noteTooLarge;
    }
    return null;
  }

  Future<bool> _validateForm(WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) return false;
    final publicAddress = ref.read(accountProvider).account?.address ?? '';
    final amount = amountController.text;

    if (!await hasSufficientFunds(publicAddress, amount) && mounted) {
      _showErrorSnackbar(S.of(context).insufficientFunds);
      return false;
    }

    return true;
  }

  Future<void> _executeTransaction(WidgetRef ref) async {
    try {
      final accountId = ref.read(accountProvider).accountId;
      if (accountId == null) {
        throw Exception(S.of(context).noActiveAccountIdFound);
      }

      final privateKey = await ref
          .read(storageProvider)
          .getAccountData(accountId, 'privateKey');
      if ((privateKey == null || privateKey.isEmpty) && mounted) {
        throw Exception(S.of(context).privateKeyNotFoundInStorage);
      }

      final algorand = ref.read(algorandProvider);
      final account =
          await algorand.loadAccountFromPrivateKey(privateKey ?? '');

      final selectedItem = ref.read(selectedAssetProvider);
      if (selectedItem == null && mounted) {
        throw Exception(S.of(context).noItemSelectedForTransaction);
      }

      if (selectedItem?.assetType == AssetType.standard) {
        await ref.read(algorandServiceProvider).transferAsset(
              assetId: int.parse(selectedItem?.value ?? '0'),
              senderAccount: account,
              receiverAddress: recipientAddressController.text,
              amount: int.parse(amountController.text),
            );
        if (mounted) {
          _showSuccessSnackbar(S.of(context).standardAssetTransferSuccessful);
        }
      } else if (selectedItem?.assetType == AssetType.arc200) {
        await ref.read(algorandServiceProvider).sendARC0200Asset(
              amount: BigInt.parse(amountController.text),
              appID: BigInt.parse(selectedItem?.value ?? '0'),
              receiverAddress: recipientAddressController.text,
              senderAccount: account,
            );
        if (mounted) {
          _showSuccessSnackbar(S.of(context).arc0200AssetTransferSuccessful);
        }
      } else if (selectedItem?.value.startsWith("network") ?? false) {
        final txId = await ref.read(algorandServiceProvider).sendPayment(
              account,
              recipientAddressController.text,
              double.parse(amountController.text),
              noteController.text,
            );
        if ((txId.isEmpty || txId == 'error') && mounted) {
          throw Exception(S.of(context).transactionFailed);
        }
        _showSuccessSnackbar(txId);
      } else {
        if (mounted) {
          throw Exception(S.of(context).unsupportedAssetType);
        }
      }

      final existingContact = await ref
          .read(contactsListProvider.notifier)
          .getContactByPublicKey(recipientAddressController.text.trim());

      if (existingContact != null) {
        if (existingContact.name != contactNameController.text.trim()) {
          existingContact.name = contactNameController.text.trim();
          existingContact.lastUsedDate = DateTime.now();
          await ref
              .read(contactsListProvider.notifier)
              .updateContact(existingContact);
          if (mounted) {
            _showSuccessSnackbar(S.of(context).contactNameUpdatedSuccessfully);
          }
        }
      } else {
        _saveContact();
      }

      ref.invalidate(transactionsProvider);
      ref.invalidate(balanceProvider);
    } catch (e) {
      var errorMessage = e.toString();
      debugPrint("Transaction failed with error: $errorMessage");
      var friendlyErrorMessage = processTransactionError(errorMessage);
      _showErrorSnackbar(friendlyErrorMessage);
    } finally {
      goBack();
    }
  }

  String processTransactionError(String errorMessage) {
    if (errorMessage.contains("overspend")) {
      return S.of(context).insufficientFundsError;
    } else if (errorMessage.toLowerCase().contains("confirm")) {
      return S.of(context).transactionFailedToConfirm;
    } else {
      return errorMessage;
    }
  }

  void _saveContact() async {
    final contactName = contactNameController.text.trim();
    final recipientPublicKey = recipientAddressController.text.trim();
    final accounts = ref.read(accountsListProvider).accounts;
    final isMyAccount =
        accounts.any((account) => account['publicKey'] == recipientPublicKey);

    if (contactName.isNotEmpty && !isMyAccount) {
      final newContact = Contact(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: contactName,
        publicKey: recipientPublicKey,
      );

      try {
        await ref
            .read(contactsListProvider.notifier)
            .addOrUpdateContact(newContact);
        if (mounted) {
          _showSuccessSnackbar(S.of(context).contactSavedSuccessfully);
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackbar(S.of(context).failedToSaveContact(e.toString()));
        }
      }
    }
  }

  void _showSuccessSnackbar(String message) {
    if (mounted) {
      showCustomSnackBar(
        context: context,
        snackType: SnackType.success,
        showConfetti: true,
        message: S.of(context).transactionSuccessful,
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
            title: S.of(context).verifyPin,
            onPinVerified: () async {
              ref.read(loadingProvider.notifier).startLoading(
                    message: widget.mode == SendTransactionScreenMode.payment
                        ? S.of(context).sendingPayment
                        : S.of(context).sendingAsset,
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
              return Text(
                  '${S.of(context).max}: ${snapshot.data?.toStringAsFixed(2)}');
            } else if (snapshot.hasError) {
              return Text('${S.of(context).error}: ${snapshot.error}');
            }
          }
          return Text(S.of(context).calculating);
        },
      );
    } else {
      final int maxAssetAmount =
          ref.read(activeAssetProvider)?.params.total ?? 0;
      final String formattedAmount =
          NumberFormatter.shortenNumber(maxAssetAmount.toDouble());
      return Text('Max: $formattedAmount');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).sendTransactionTitle),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
          child: Form(
            key: _formKey,
            child: Consumer(
              builder: (context, ref, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(height: kScreenPadding),
                    _buildActiveAccountTextField(),
                    const SizedBox(height: kScreenPadding),
                    _buildCustomDropDown(ref),
                    _maxSendInfo(),
                    _buildAmountTextField(),
                    const SizedBox(height: kScreenPadding),
                    _buildRecipientAddressTextField(context, ref),
                    const SizedBox(height: kScreenPadding),
                    CustomTextField(
                      labelText: S.of(context).contactNameOptional,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      controller: contactNameController,
                      validator: (value) {
                        return null;
                      },
                      leadingIcon: Icons.person,
                    ),
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
      bottomNavigationBar: FutureBuilder<bool>(
        future: ref.read(accountProvider.notifier).hasPrivateKey(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox.shrink();
          }

          if (snapshot.hasError || !(snapshot.data ?? false)) {
            return const SizedBox.shrink();
          }

          return CustomButton(
            isBottomNavigationPosition: true,
            isFullWidth: true,
            text: S.of(context).send,
            onPressed: () => _showPinPadDialog(ref),
          );
        },
      ),
    );
  }

  Row _maxSendInfo() {
    final selectedItem = ref.watch(selectedAssetProvider);
    bool isNetworkSelected = selectedItem?.value.startsWith("network") ?? false;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
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
                  final balanceAsync = ref.watch(balanceProvider);
                  final minimumBalance = ref.watch(minimumBalanceProvider);

                  balanceAsync.when(
                    data: (balance) {
                      customBottomSheet(
                        context: context,
                        singleWidget: Text(
                          S.of(context).maxVoiAmountCalculation(
                                balance.toString(),
                                minimumBalance.toString(),
                              ),
                          softWrap: true,
                          style: context.textTheme.bodyMedium,
                        ),
                        header: S.of(context).info,
                        onPressed: (SelectItem item) {},
                      );
                    },
                    loading: () {
                      customBottomSheet(
                        context: context,
                        singleWidget: Text(
                          'Loading balance...',
                          style: context.textTheme.bodyMedium,
                        ),
                        header: S.of(context).info,
                        onPressed: (SelectItem item) {},
                      );
                    },
                    error: (err, stack) {
                      customBottomSheet(
                        context: context,
                        singleWidget: Text(
                          'Error loading balance: $err',
                          style: context.textTheme.bodyMedium,
                        ),
                        header: S.of(context).info,
                        onPressed: (SelectItem item) {},
                      );
                    },
                  );
                },
              ),
            buildMaxAmountDisplay(ref),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveAccountTextField() {
    return CustomTextField(
      labelText: S.of(context).account,
      isEnabled: false,
      leadingIcon: AppIcons.wallet,
      controller: activeAccountController,
      onTap: null,
    );
  }

  Widget _buildCustomDropDown(WidgetRef ref) {
    final dropdownItemsAsync = ref.watch(dropdownItemsProvider);
    final network = ref.watch(networkProvider)?.value;
    return dropdownItemsAsync.when(
      loading: () => CustomDropDown(
        label: S.of(context).asset,
        items: [
          SelectItem(
            name: S.of(context).loading,
            value: 'loading',
            icon: network?.startsWith('network-voi') ?? false
                ? AppIcons.voiIcon
                : AppIcons.algorandIcon,
          ),
        ],
        selectedValue: null,
        onChanged: null,
      ),
      error: (err, stack) => CustomDropDown(
        label: S.of(context).asset,
        items: [
          SelectItem(
            name: S.of(context).failedToLoad,
            value: 'error',
            icon: AppIcons.error,
          ),
        ],
        selectedValue: null,
        onChanged: null,
      ),
      data: (dropdownItems) {
        final isDisabled = dropdownItems.length < 2;
        final selectedAsset = ref.watch(selectedAssetProvider);

        final selectedValue = dropdownItems.firstWhereOrNull(
                (item) => item.value == selectedAsset?.value) ??
            dropdownItems.firstOrNull;

        return GestureDetector(
          onTap: isDisabled
              ? null
              : () {
                  customBottomSheet(
                    context: context,
                    items: dropdownItems,
                    header: S.of(context).selectAsset,
                    onPressed: (SelectItem selectedItem) {
                      ref
                          .read(selectedAssetProvider.notifier)
                          .setAsset(selectedItem);
                    },
                  );
                },
          child: AbsorbPointer(
            absorbing: isDisabled,
            child: CustomDropDown(
              label: S.of(context).asset,
              items: dropdownItems.isNotEmpty
                  ? dropdownItems
                  : [
                      SelectItem(
                        name: S.of(context).noAssetsFound,
                        value: 'no_assets',
                        icon: AppIcons.error,
                      ),
                    ],
              selectedValue: selectedValue,
              onChanged: null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAmountTextField() {
    return CustomTextField(
      labelText: S.of(context).amount,
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
            labelText: S.of(context).recipientAddress,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            controller: recipientAddressController,
            leadingIcon: AppIcons.addAccount,
            suffixIcon: isMobile ? AppIcons.scan : null,
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
    final contactsState = ref.watch(contactsListProvider);

    if (accountsState.error != null || contactsState.error != null) {
      return;
    }

    if (accountsState.isLoading || contactsState.isLoading) {
      await Future.wait([
        ref.read(accountsListProvider.notifier).loadAccounts(),
        ref.read(contactsListProvider.notifier).loadContacts(),
      ]);
    }

    final accounts = accountsState.accounts;
    final contacts = contactsState.contacts;

    if (!context.mounted) return;

    await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return ContactsDialog(
          accounts: accounts,
          contacts: contacts,
          onAccountSelected: (account) {
            recipientAddressController.text = account['publicKey']!;
            selectedContact = null;
            contactNameController.clear();
          },
          onContactSelected: (contact) {
            recipientAddressController.text = contact.publicKey;
            selectedContact = contact;
            contactNameController.text = contact.name;
          },
          onCancel: () => Navigator.pop(context),
        );
      },
    );
  }

  Widget _buildNoteTextField() {
    return CustomTextField(
      labelText: S.of(context).noteOptional,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      maxLines: 7,
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
