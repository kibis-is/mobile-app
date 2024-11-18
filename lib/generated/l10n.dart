// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `No Internet Connection`
  String get noInternetConnection {
    return Intl.message(
      'No Internet Connection',
      name: 'noInternetConnection',
      desc: 'Shown in the banner when the device has no internet connectivity.',
      args: [],
    );
  }

  /// `Initialization error, please restart the app.`
  String get initializationError {
    return Intl.message(
      'Initialization error, please restart the app.',
      name: 'initializationError',
      desc: 'Error message displayed when app initialization fails.',
      args: [],
    );
  }

  /// `Unknown`
  String get unknown {
    return Intl.message(
      'Unknown',
      name: 'unknown',
      desc: 'Displayed when the asset name is unknown.',
      args: [],
    );
  }

  /// `Already\nadded`
  String get alreadyAdded {
    return Intl.message(
      'Already\nadded',
      name: 'alreadyAdded',
      desc: 'Displayed when an asset is already added to the user\'s list.',
      args: [],
    );
  }

  /// `Are you sure?`
  String get defaultConfirmationTitle {
    return Intl.message(
      'Are you sure?',
      name: 'defaultConfirmationTitle',
      desc: 'Default title for confirmation dialogs.',
      args: [],
    );
  }

  /// `Do you want to proceed with this action?`
  String get defaultConfirmationContent {
    return Intl.message(
      'Do you want to proceed with this action?',
      name: 'defaultConfirmationContent',
      desc: 'Default content for confirmation dialogs.',
      args: [],
    );
  }

  /// `Yes`
  String get yes {
    return Intl.message(
      'Yes',
      name: 'yes',
      desc: 'Label for the confirmation button.',
      args: [],
    );
  }

  /// `No`
  String get no {
    return Intl.message(
      'No',
      name: 'no',
      desc: 'Label for the cancel button in confirmation dialogs.',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message(
      'OK',
      name: 'ok',
      desc: 'Label for the OK button in dialogs.',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message(
      'Confirm',
      name: 'confirm',
      desc: 'Default text for confirmation button on bottom sheets.',
      args: [],
    );
  }

  /// `Pull down to refresh`
  String get pullToRefresh {
    return Intl.message(
      'Pull down to refresh',
      name: 'pullToRefresh',
      desc: 'Shown when the user can pull down to refresh the content.',
      args: [],
    );
  }

  /// `Release to refresh`
  String get releaseToRefresh {
    return Intl.message(
      'Release to refresh',
      name: 'releaseToRefresh',
      desc: 'Shown when the user should release to trigger refresh.',
      args: [],
    );
  }

  /// `Refreshing...`
  String get refreshing {
    return Intl.message(
      'Refreshing...',
      name: 'refreshing',
      desc: 'Shown when the refresh action is in progress.',
      args: [],
    );
  }

  /// `Init`
  String get initializing {
    return Intl.message(
      'Init',
      name: 'initializing',
      desc: 'Prefix text shown during initialization with animated dots.',
      args: [],
    );
  }

  /// `Reset`
  String get reset {
    return Intl.message(
      'Reset',
      name: 'reset',
      desc: 'Text for the reset confirmation button.',
      args: [],
    );
  }

  /// `Are you sure you want to reset this device? This will remove all accounts, settings, and security information.`
  String get resetConfirmationMessage {
    return Intl.message(
      'Are you sure you want to reset this device? This will remove all accounts, settings, and security information.',
      name: 'resetConfirmationMessage',
      desc: 'Confirmation message displayed when resetting the app.',
      args: [],
    );
  }

  /// `PIN does not match.`
  String get pinMismatchError {
    return Intl.message(
      'PIN does not match.',
      name: 'pinMismatchError',
      desc: 'Error message shown when PINs do not match during setup.',
      args: [],
    );
  }

  /// `Incorrect PIN. Try again.`
  String get incorrectPinError {
    return Intl.message(
      'Incorrect PIN. Try again.',
      name: 'incorrectPinError',
      desc: 'Error message shown when an incorrect PIN is entered.',
      args: [],
    );
  }

  /// `1 minute`
  String get timeout1Minute {
    return Intl.message(
      '1 minute',
      name: 'timeout1Minute',
      desc: 'Timeout duration of 1 minute.',
      args: [],
    );
  }

  /// `2 minutes`
  String get timeout2Minutes {
    return Intl.message(
      '2 minutes',
      name: 'timeout2Minutes',
      desc: 'Timeout duration of 2 minutes.',
      args: [],
    );
  }

  /// `5 minutes`
  String get timeout5Minutes {
    return Intl.message(
      '5 minutes',
      name: 'timeout5Minutes',
      desc: 'Timeout duration of 5 minutes.',
      args: [],
    );
  }

  /// `10 minutes`
  String get timeout10Minutes {
    return Intl.message(
      '10 minutes',
      name: 'timeout10Minutes',
      desc: 'Timeout duration of 10 minutes.',
      args: [],
    );
  }

  /// `15 minutes`
  String get timeout15Minutes {
    return Intl.message(
      '15 minutes',
      name: 'timeout15Minutes',
      desc: 'Timeout duration of 15 minutes.',
      args: [],
    );
  }

  /// `Transaction group size exceeds the maximum size of "{maxSize}"`
  String transactionGroupSizeExceeded(int maxSize) {
    return Intl.message(
      'Transaction group size exceeds the maximum size of "$maxSize"',
      name: 'transactionGroupSizeExceeded',
      desc:
          'Error message when the transaction group size exceeds the maximum allowed.',
      args: [maxSize],
    );
  }

  /// `Enter an assetID, name, asset, or symbol ID (for ARC-200).`
  String get searchPrompt {
    return Intl.message(
      'Enter an assetID, name, asset, or symbol ID (for ARC-200).',
      name: 'searchPrompt',
      desc: 'Prompt text shown above the search input.',
      args: [],
    );
  }

  /// `Search Query`
  String get searchQueryLabel {
    return Intl.message(
      'Search Query',
      name: 'searchQueryLabel',
      desc: 'Label for the search input field.',
      args: [],
    );
  }

  /// `No assets found.`
  String get noAssetsFound {
    return Intl.message(
      'No assets found.',
      name: 'noAssetsFound',
      desc: 'Displayed when no assets match the search query.',
      args: [],
    );
  }

  /// `Sorry, there was an error.`
  String get genericErrorMessage {
    return Intl.message(
      'Sorry, there was an error.',
      name: 'genericErrorMessage',
      desc: 'Generic error message displayed when an unexpected error occurs.',
      args: [],
    );
  }

  /// `N/A`
  String get notAvailable {
    return Intl.message(
      'N/A',
      name: 'notAvailable',
      desc: 'Default value for asset unit name when it\'s not available.',
      args: [],
    );
  }

  /// `Contacts`
  String get contactsTab {
    return Intl.message(
      'Contacts',
      name: 'contactsTab',
      desc: 'Tab title for the contacts list.',
      args: [],
    );
  }

  /// `My Accounts`
  String get myAccountsTab {
    return Intl.message(
      'My Accounts',
      name: 'myAccountsTab',
      desc: 'Tab title for the user\'s accounts list.',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: 'Label for cancel buttons.',
      args: [],
    );
  }

  /// `Delete Contact`
  String get deleteContactTitle {
    return Intl.message(
      'Delete Contact',
      name: 'deleteContactTitle',
      desc: 'Title for the delete contact confirmation dialog.',
      args: [],
    );
  }

  /// `Are you sure you want to delete {contactName}?`
  String deleteContactMessage(String contactName) {
    return Intl.message(
      'Are you sure you want to delete $contactName?',
      name: 'deleteContactMessage',
      desc: 'Message shown when confirming contact deletion.',
      args: [contactName],
    );
  }

  /// `Select Account`
  String get selectAccountTitle {
    return Intl.message(
      'Select Account',
      name: 'selectAccountTitle',
      desc: 'Title for the select account screen.',
      args: [],
    );
  }

  /// `Error: {error}`
  String errorMessage(String error) {
    return Intl.message(
      'Error: $error',
      name: 'errorMessage',
      desc: 'Error message displayed when an error occurs.',
      args: [error],
    );
  }

  /// `No accounts found`
  String get noAccountsFound {
    return Intl.message(
      'No accounts found',
      name: 'noAccountsFound',
      desc: 'Message displayed when no accounts are available.',
      args: [],
    );
  }

  /// `No Public Key`
  String get noPublicKey {
    return Intl.message(
      'No Public Key',
      name: 'noPublicKey',
      desc: 'Fallback message when an account has no public key.',
      args: [],
    );
  }

  /// `Assets`
  String get assetsTab {
    return Intl.message(
      'Assets',
      name: 'assetsTab',
      desc: 'Label for the Assets tab in the dashboard.',
      args: [],
    );
  }

  /// `NFTs`
  String get nftsTab {
    return Intl.message(
      'NFTs',
      name: 'nftsTab',
      desc: 'Label for the NFTs tab in the dashboard.',
      args: [],
    );
  }

  /// `Activity`
  String get activityTab {
    return Intl.message(
      'Activity',
      name: 'activityTab',
      desc: 'Label for the Activity tab in the dashboard.',
      args: [],
    );
  }

  /// `Select Network`
  String get selectNetworkHeader {
    return Intl.message(
      'Select Network',
      name: 'selectNetworkHeader',
      desc: 'Header for the network selection bottom sheet.',
      args: [],
    );
  }

  /// `Switched to {networkName}`
  String networkSwitchSuccess(String networkName) {
    return Intl.message(
      'Switched to $networkName',
      name: 'networkSwitchSuccess',
      desc: 'Message shown when switching networks succeeds.',
      args: [networkName],
    );
  }

  /// `Failed to switch to {networkName}`
  String networkSwitchFailure(String networkName) {
    return Intl.message(
      'Failed to switch to $networkName',
      name: 'networkSwitchFailure',
      desc: 'Message shown when switching networks fails.',
      args: [networkName],
    );
  }

  /// `Minimum balance is {balance} VOI. Based on the account configuration, this is the minimum balance needed to keep the account open.`
  String minimumBalanceInfo(String balance) {
    return Intl.message(
      'Minimum balance is $balance VOI. Based on the account configuration, this is the minimum balance needed to keep the account open.',
      name: 'minimumBalanceInfo',
      desc: 'Message explaining the minimum balance required for an account.',
      args: [balance],
    );
  }

  /// `Info`
  String get infoHeader {
    return Intl.message(
      'Info',
      name: 'infoHeader',
      desc: 'Header for the info bottom sheet.',
      args: [],
    );
  }

  /// `Loading Account`
  String get loadingAccount {
    return Intl.message(
      'Loading Account',
      name: 'loadingAccount',
      desc: 'Text shown when account details are loading.',
      args: [],
    );
  }

  /// `Please wait`
  String get pleaseWait {
    return Intl.message(
      'Please wait',
      name: 'pleaseWait',
      desc: 'Text shown while waiting for account details to load.',
      args: [],
    );
  }

  /// `Error`
  String get genericError {
    return Intl.message(
      'Error',
      name: 'genericError',
      desc: 'Generic error message displayed when an error occurs.',
      args: [],
    );
  }

  /// `Error loading transactions`
  String get errorLoadingTransactions {
    return Intl.message(
      'Error loading transactions',
      name: 'errorLoadingTransactions',
      desc: 'Displayed when transactions fail to load.',
      args: [],
    );
  }

  /// `Select a transaction to view details`
  String get selectTransactionPrompt {
    return Intl.message(
      'Select a transaction to view details',
      name: 'selectTransactionPrompt',
      desc: 'Prompt displayed in wide screen mode to select a transaction.',
      args: [],
    );
  }

  /// `No Transactions Found`
  String get noTransactionsFound {
    return Intl.message(
      'No Transactions Found',
      name: 'noTransactionsFound',
      desc: 'Displayed when no transactions exist.',
      args: [],
    );
  }

  /// `You have not made any transactions.`
  String get noTransactionsMade {
    return Intl.message(
      'You have not made any transactions.',
      name: 'noTransactionsMade',
      desc: 'Displayed when the user hasn\'t made any transactions.',
      args: [],
    );
  }

  /// `No more transactions.`
  String get noMoreTransactions {
    return Intl.message(
      'No more transactions.',
      name: 'noMoreTransactions',
      desc: 'Displayed when there are no more transactions to load.',
      args: [],
    );
  }

  /// `No Assets Found`
  String get noAssets {
    return Intl.message(
      'No Assets Found',
      name: 'noAssets',
      desc: 'Displayed when no assets are available.',
      args: [],
    );
  }

  /// `No Assets Found for the Filter`
  String get noAssetsForFilter {
    return Intl.message(
      'No Assets Found for the Filter',
      name: 'noAssetsForFilter',
      desc: 'Displayed when filtered assets yield no results.',
      args: [],
    );
  }

  /// `Try clearing the filter to see all assets.`
  String get tryClearingFilter {
    return Intl.message(
      'Try clearing the filter to see all assets.',
      name: 'tryClearingFilter',
      desc: 'Subtitle prompting to clear the filter.',
      args: [],
    );
  }

  /// `You have not added any assets.`
  String get noAssetsAdded {
    return Intl.message(
      'You have not added any assets.',
      name: 'noAssetsAdded',
      desc: 'Subtitle displayed when no assets have been added yet.',
      args: [],
    );
  }

  /// `Clear Filter`
  String get clearFilter {
    return Intl.message(
      'Clear Filter',
      name: 'clearFilter',
      desc: 'Label for the button to clear filter.',
      args: [],
    );
  }

  /// `Retry`
  String get retry {
    return Intl.message(
      'Retry',
      name: 'retry',
      desc: 'Label for the button to retry fetching assets.',
      args: [],
    );
  }

  /// `Error loading assets`
  String get errorLoadingAssets {
    return Intl.message(
      'Error loading assets',
      name: 'errorLoadingAssets',
      desc: 'Displayed when assets fail to load.',
      args: [],
    );
  }

  /// `Sort and Filter Assets`
  String get sortAndFilter {
    return Intl.message(
      'Sort and Filter Assets',
      name: 'sortAndFilter',
      desc: 'Dialog header for sorting and filtering assets.',
      args: [],
    );
  }

  /// `Show Frozen Assets`
  String get showFrozenAssets {
    return Intl.message(
      'Show Frozen Assets',
      name: 'showFrozenAssets',
      desc: 'Checkbox label to toggle visibility of frozen assets.',
      args: [],
    );
  }

  /// `Copy Address`
  String get copyAddress {
    return Intl.message(
      'Copy Address',
      name: 'copyAddress',
      desc: 'Displayed as an action to copy the account\'s address.',
      args: [],
    );
  }

  /// `Share Address`
  String get shareAddress {
    return Intl.message(
      'Share Address',
      name: 'shareAddress',
      desc: 'Displayed as an action to share the account\'s address.',
      args: [],
    );
  }

  /// `Edit`
  String get editAccount {
    return Intl.message(
      'Edit',
      name: 'editAccount',
      desc: 'Displayed as an action to edit the account details.',
      args: [],
    );
  }

  /// `Refresh`
  String get refreshAccount {
    return Intl.message(
      'Refresh',
      name: 'refreshAccount',
      desc: 'Displayed as an action to refresh the account data.',
      args: [],
    );
  }

  /// `No Account Name`
  String get noAccountName {
    return Intl.message(
      'No Account Name',
      name: 'noAccountName',
      desc: 'Displayed when the account does not have a name.',
      args: [],
    );
  }

  /// `Options`
  String get options {
    return Intl.message(
      'Options',
      name: 'options',
      desc: 'Header for the bottom sheet with account options.',
      args: [],
    );
  }

  /// `No NFTs Found`
  String get noNftsFound {
    return Intl.message(
      'No NFTs Found',
      name: 'noNftsFound',
      desc: 'Displayed when no NFTs are available.',
      args: [],
    );
  }

  /// `No NFTs Found for the Filter`
  String get noNftsForFilter {
    return Intl.message(
      'No NFTs Found for the Filter',
      name: 'noNftsForFilter',
      desc: 'Displayed when no NFTs match the filter criteria.',
      args: [],
    );
  }

  /// `You have not added any NFTs.`
  String get noNftsAdded {
    return Intl.message(
      'You have not added any NFTs.',
      name: 'noNftsAdded',
      desc: 'Displayed when the user has not added any NFTs.',
      args: [],
    );
  }

  /// `Filter`
  String get filter {
    return Intl.message(
      'Filter',
      name: 'filter',
      desc: 'Label text for the filter input field.',
      args: [],
    );
  }

  /// `Scan QR Code`
  String get scanQrCode {
    return Intl.message(
      'Scan QR Code',
      name: 'scanQrCode',
      desc: 'Title displayed in the QR dialog.',
      args: [],
    );
  }

  /// `Share QR`
  String get shareQr {
    return Intl.message(
      'Share QR',
      name: 'shareQr',
      desc: 'Tooltip for sharing the QR code.',
      args: [],
    );
  }

  /// `Copy URI`
  String get copyUri {
    return Intl.message(
      'Copy URI',
      name: 'copyUri',
      desc: 'Tooltip for copying the QR data to the clipboard.',
      args: [],
    );
  }

  /// `Download QR Image`
  String get downloadQrImage {
    return Intl.message(
      'Download QR Image',
      name: 'downloadQrImage',
      desc: 'Tooltip for downloading the QR code as an image.',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message(
      'Close',
      name: 'close',
      desc: 'Button text to close the dialog.',
      args: [],
    );
  }

  /// `Transaction ID Copied`
  String get transactionIdCopied {
    return Intl.message(
      'Transaction ID Copied',
      name: 'transactionIdCopied',
      desc: 'Snackbar message displayed when a transaction ID is copied.',
      args: [],
    );
  }

  /// `Payment`
  String get payment {
    return Intl.message(
      'Payment',
      name: 'payment',
      desc: 'Label for payment-type transactions.',
      args: [],
    );
  }

  /// `Asset Transfer`
  String get assetTransfer {
    return Intl.message(
      'Asset Transfer',
      name: 'assetTransfer',
      desc: 'Label for asset transfers involving tokens.',
      args: [],
    );
  }

  /// `Error`
  String get errorTitle {
    return Intl.message(
      'Error',
      name: 'errorTitle',
      desc: 'Title displayed on the error screen.',
      args: [],
    );
  }

  /// `There was an error. No further details provided.`
  String get defaultErrorMessage {
    return Intl.message(
      'There was an error. No further details provided.',
      name: 'defaultErrorMessage',
      desc: 'Default error message displayed when no details are provided.',
      args: [],
    );
  }

  /// `Back`
  String get back {
    return Intl.message(
      'Back',
      name: 'back',
      desc: 'Label for the button that navigates back to the home screen.',
      args: [],
    );
  }

  /// `Create Pin`
  String get createPin {
    return Intl.message(
      'Create Pin',
      name: 'createPin',
      desc: 'Title for the screen where the user creates a PIN.',
      args: [],
    );
  }

  /// `Confirm Pin`
  String get confirmPin {
    return Intl.message(
      'Confirm Pin',
      name: 'confirmPin',
      desc: 'Title for the screen where the user confirms the PIN.',
      args: [],
    );
  }

  /// `Unlock`
  String get unlock {
    return Intl.message(
      'Unlock',
      name: 'unlock',
      desc: 'Title for the screen where the user unlocks the app.',
      args: [],
    );
  }

  /// `Verify Pin`
  String get verifyPin {
    return Intl.message(
      'Verify Pin',
      name: 'verifyPin',
      desc: 'Title for the screen where the user verifies their PIN.',
      args: [],
    );
  }

  /// `Resetting App`
  String get resettingApp {
    return Intl.message(
      'Resetting App',
      name: 'resettingApp',
      desc: 'Message shown when the app is resetting.',
      args: [],
    );
  }

  /// `Invalid QR code data`
  String get invalidQrCodeData {
    return Intl.message(
      'Invalid QR code data',
      name: 'invalidQrCodeData',
      desc: 'Error message shown when a scanned QR code contains no data.',
      args: [],
    );
  }

  /// `Expected a private key QR code but found a public key.`
  String get expectedPrivateKeyQr {
    return Intl.message(
      'Expected a private key QR code but found a public key.',
      name: 'expectedPrivateKeyQr',
      desc: 'Error message when a public key is scanned in private key mode.',
      args: [],
    );
  }

  /// `Expected a private key QR code but found a WalletConnect URI.`
  String get expectedWalletConnectUri {
    return Intl.message(
      'Expected a private key QR code but found a WalletConnect URI.',
      name: 'expectedWalletConnectUri',
      desc:
          'Error message when a WalletConnect URI is scanned in private key mode.',
      args: [],
    );
  }

  /// `Expected a public key QR code but found something else.`
  String get expectedPublicKeyQr {
    return Intl.message(
      'Expected a public key QR code but found something else.',
      name: 'expectedPublicKeyQr',
      desc:
          'Error message when a non-public key QR code is scanned in public key mode.',
      args: [],
    );
  }

  /// `Expected a WalletConnect session QR code but found something else.`
  String get expectedWalletConnectSessionQr {
    return Intl.message(
      'Expected a WalletConnect session QR code but found something else.',
      name: 'expectedWalletConnectSessionQr',
      desc:
          'Error message when a non-WalletConnect QR code is scanned in session mode.',
      args: [],
    );
  }

  /// `Unknown QR Code type`
  String get unknownQrCodeType {
    return Intl.message(
      'Unknown QR Code type',
      name: 'unknownQrCodeType',
      desc: 'Error message shown when the QR code type is not recognized.',
      args: [],
    );
  }

  /// `WalletConnect V1 URIs are not supported.`
  String get walletConnectV1NotSupported {
    return Intl.message(
      'WalletConnect V1 URIs are not supported.',
      name: 'walletConnectV1NotSupported',
      desc: 'Error message shown when a WalletConnect V1 URI is scanned.',
      args: [],
    );
  }

  /// `Invalid WalletConnect URI format.`
  String get invalidWalletConnectUri {
    return Intl.message(
      'Invalid WalletConnect URI format.',
      name: 'invalidWalletConnectUri',
      desc:
          'Error message shown when a WalletConnect URI has an invalid format.',
      args: [],
    );
  }

  /// `Failed to parse WalletConnect URI: {error}`
  String failedToParseWalletConnectUri(String error) {
    return Intl.message(
      'Failed to parse WalletConnect URI: $error',
      name: 'failedToParseWalletConnectUri',
      desc: 'Error message shown when a WalletConnect URI parsing fails.',
      args: [error],
    );
  }

  /// `Unknown import account URI format`
  String get unknownImportAccountUriFormat {
    return Intl.message(
      'Unknown import account URI format',
      name: 'unknownImportAccountUriFormat',
      desc:
          'Error message shown when an account import URI format is not recognized.',
      args: [],
    );
  }

  /// `Paginated URI missing checksum or page information`
  String get paginatedUriMissingInfo {
    return Intl.message(
      'Paginated URI missing checksum or page information',
      name: 'paginatedUriMissingInfo',
      desc: 'Error message for paginated URIs missing checksum or page data.',
      args: [],
    );
  }

  /// `Invalid page format in paginated URI`
  String get invalidPageFormatInUri {
    return Intl.message(
      'Invalid page format in paginated URI',
      name: 'invalidPageFormatInUri',
      desc:
          'Error message shown when the page parameter in a paginated URI is invalid.',
      args: [],
    );
  }

  /// `Invalid Public Key Format`
  String get invalidPublicKeyFormat {
    return Intl.message(
      'Invalid Public Key Format',
      name: 'invalidPublicKeyFormat',
      desc:
          'Error message shown when the provided public key format is invalid.',
      args: [],
    );
  }

  /// `Invalid URI format`
  String get invalidUriFormat {
    return Intl.message(
      'Invalid URI format',
      name: 'invalidUriFormat',
      desc: 'Error message shown when a URI cannot be parsed.',
      args: [],
    );
  }

  /// `Invalid private key`
  String get invalidPrivateKey {
    return Intl.message(
      'Invalid private key',
      name: 'invalidPrivateKey',
      desc: 'Error message shown when the private key fails validation.',
      args: [],
    );
  }

  /// `Missing private key in legacy URI`
  String get missingPrivateKeyInLegacyUri {
    return Intl.message(
      'Missing private key in legacy URI',
      name: 'missingPrivateKeyInLegacyUri',
      desc: 'Error message for legacy import URIs without a private key.',
      args: [],
    );
  }

  /// `Key is neither valid Base64 nor valid Hex: {key}`
  String keyNeitherBase64NorHex(String key) {
    return Intl.message(
      'Key is neither valid Base64 nor valid Hex: $key',
      name: 'keyNeitherBase64NorHex',
      desc: 'Debug message when a private key is neither valid Base64 nor Hex.',
      args: [key],
    );
  }

  /// `Failed to decode private key: {error}`
  String failedToDecodePrivateKey(String error) {
    return Intl.message(
      'Failed to decode private key: $error',
      name: 'failedToDecodePrivateKey',
      desc: 'Debug message for private key decoding failures.',
      args: [error],
    );
  }

  /// `Unknown WalletConnect version. Unable to pair.`
  String get unknownWalletConnectVersion {
    return Intl.message(
      'Unknown WalletConnect version. Unable to pair.',
      name: 'unknownWalletConnectVersion',
      desc:
          'Error message when an unknown WalletConnect version is encountered.',
      args: [],
    );
  }

  /// `Invalid private key length.`
  String get invalidPrivateKeyLength {
    return Intl.message(
      'Invalid private key length.',
      name: 'invalidPrivateKeyLength',
      desc: 'Error message for invalid private key length.',
      args: [],
    );
  }

  /// `Imported Account`
  String get importedAccount {
    return Intl.message(
      'Imported Account',
      name: 'importedAccount',
      desc: 'Default account name for imported accounts.',
      args: [],
    );
  }

  /// `Imported Account {counter}`
  String importedAccountWithCounter(int counter) {
    return Intl.message(
      'Imported Account $counter',
      name: 'importedAccountWithCounter',
      desc: 'Default account name with a counter for imported accounts.',
      args: [counter],
    );
  }

  /// `Connect to:`
  String get connectToTitle {
    return Intl.message(
      'Connect to:',
      name: 'connectToTitle',
      desc: 'Dialog title for connecting to a WalletConnect session.',
      args: [],
    );
  }

  /// `Failed to finalize account import.`
  String get failedFinalizeAccountImport {
    return Intl.message(
      'Failed to finalize account import.',
      name: 'failedFinalizeAccountImport',
      desc: 'Error message when account import could not be completed.',
      args: [],
    );
  }

  /// `Error processing public key`
  String get errorProcessingPublicKey {
    return Intl.message(
      'Error processing public key',
      name: 'errorProcessingPublicKey',
      desc: 'Error message when a public key fails to process.',
      args: [],
    );
  }

  /// `Successfully connected`
  String get successfullyConnected {
    return Intl.message(
      'Successfully connected',
      name: 'successfullyConnected',
      desc: 'Message displayed after a successful WalletConnect connection.',
      args: [],
    );
  }

  /// `Next QR:`
  String get nextQrCode {
    return Intl.message(
      'Next QR:',
      name: 'nextQrCode',
      desc: 'Label for indicating the next QR code part to scan.',
      args: [],
    );
  }

  /// `Part {partNumber}`
  String partNumber(int partNumber) {
    return Intl.message(
      'Part $partNumber',
      name: 'partNumber',
      desc: 'Label for indicating the current QR code part being scanned.',
      args: [partNumber],
    );
  }

  /// `Expected a private key QR code but found a public key.`
  String get expectedPrivateKeyButPublic {
    return Intl.message(
      'Expected a private key QR code but found a public key.',
      name: 'expectedPrivateKeyButPublic',
      desc:
          'Error message for mismatched QR code type when expecting private key but received public key.',
      args: [],
    );
  }

  /// `Expected a private key QR code but found a WalletConnect URI.`
  String get expectedPrivateKeyButWalletConnect {
    return Intl.message(
      'Expected a private key QR code but found a WalletConnect URI.',
      name: 'expectedPrivateKeyButWalletConnect',
      desc:
          'Error message for mismatched QR code type when expecting private key but received WalletConnect URI.',
      args: [],
    );
  }

  /// `Expected a public key QR code but found something else.`
  String get expectedPublicKey {
    return Intl.message(
      'Expected a public key QR code but found something else.',
      name: 'expectedPublicKey',
      desc:
          'Error message when expecting public key but received a different type of QR code.',
      args: [],
    );
  }

  /// `Failed to parse WalletConnect URI`
  String get failedParseWalletConnectUri {
    return Intl.message(
      'Failed to parse WalletConnect URI',
      name: 'failedParseWalletConnectUri',
      desc: 'Error message for failure to parse a WalletConnect URI.',
      args: [],
    );
  }

  /// `Invalid page format in paginated URI`
  String get invalidPageFormat {
    return Intl.message(
      'Invalid page format in paginated URI',
      name: 'invalidPageFormat',
      desc:
          'Error message for an invalid page parameter format in a paginated URI.',
      args: [],
    );
  }

  /// `Missing privatekey in legacy URI`
  String get missingPrivateKeyLegacy {
    return Intl.message(
      'Missing privatekey in legacy URI',
      name: 'missingPrivateKeyLegacy',
      desc: 'Error message when a legacy URI is missing the private key.',
      args: [],
    );
  }

  /// `Unknown import account URI format`
  String get unknownImportUriFormat {
    return Intl.message(
      'Unknown import account URI format',
      name: 'unknownImportUriFormat',
      desc: 'Error message when the import account URI format is unrecognized.',
      args: [],
    );
  }

  /// `Import Account`
  String get importAccountTitle {
    return Intl.message(
      'Import Account',
      name: 'importAccountTitle',
      desc:
          'Title for the screen when scanning a private key to import an account.',
      args: [],
    );
  }

  /// `Scan Address`
  String get scanAddressTitle {
    return Intl.message(
      'Scan Address',
      name: 'scanAddressTitle',
      desc: 'Title for the screen when scanning a public key address.',
      args: [],
    );
  }

  /// `Connect`
  String get connectTitle {
    return Intl.message(
      'Connect',
      name: 'connectTitle',
      desc:
          'Title for the screen when scanning to connect a WalletConnect session.',
      args: [],
    );
  }

  /// `QR Code Scanner`
  String get qrCodeScannerTitle {
    return Intl.message(
      'QR Code Scanner',
      name: 'qrCodeScannerTitle',
      desc: 'Default title for the QR code scanner screen.',
      args: [],
    );
  }

  /// `Processing QR Code`
  String get processingQrCode {
    return Intl.message(
      'Processing QR Code',
      name: 'processingQrCode',
      desc: 'Loading message displayed while processing the scanned QR code.',
      args: [],
    );
  }

  /// `Invalid scan result`
  String get invalidScanResult {
    return Intl.message(
      'Invalid scan result',
      name: 'invalidScanResult',
      desc: 'Error message when the QR scan result is invalid.',
      args: [],
    );
  }

  /// `No accounts available to connect.`
  String get noAccountsAvailableToConnect {
    return Intl.message(
      'No accounts available to connect.',
      name: 'noAccountsAvailableToConnect',
      desc:
          'Error message displayed when there are no accounts available for WalletConnect.',
      args: [],
    );
  }

  /// `Error loading accounts`
  String get errorLoadingAccounts {
    return Intl.message(
      'Error loading accounts',
      name: 'errorLoadingAccounts',
      desc: 'Error message displayed when the account list fails to load.',
      args: [],
    );
  }

  /// `Unnamed Asset`
  String get unnamedAsset {
    return Intl.message(
      'Unnamed Asset',
      name: 'unnamedAsset',
      desc: 'Label used when an asset does not have a name.',
      args: [],
    );
  }

  /// `No Network`
  String get noNetwork {
    return Intl.message(
      'No Network',
      name: 'noNetwork',
      desc: 'Label displayed when there is no network selected.',
      args: [],
    );
  }

  /// `Please enter a valid amount`
  String get pleaseEnterValidAmount {
    return Intl.message(
      'Please enter a valid amount',
      name: 'pleaseEnterValidAmount',
      desc: 'Error message when the entered amount is invalid.',
      args: [],
    );
  }

  /// `Please enter a valid Algorand address`
  String get pleaseEnterValidAlgorandAddress {
    return Intl.message(
      'Please enter a valid Algorand address',
      name: 'pleaseEnterValidAlgorandAddress',
      desc: 'Error message when the entered Algorand address is invalid.',
      args: [],
    );
  }

  /// `Insufficient funds`
  String get insufficientFunds {
    return Intl.message(
      'Insufficient funds',
      name: 'insufficientFunds',
      desc:
          'Error message when there are not enough funds to complete the transaction.',
      args: [],
    );
  }

  /// `Transaction successful`
  String get transactionSuccessful {
    return Intl.message(
      'Transaction successful',
      name: 'transactionSuccessful',
      desc: 'Message displayed when a transaction is successful.',
      args: [],
    );
  }

  /// `No active account ID found`
  String get noActiveAccountIdFound {
    return Intl.message(
      'No active account ID found',
      name: 'noActiveAccountIdFound',
      desc: 'Exception message when there is no active account ID.',
      args: [],
    );
  }

  /// `Private key not found in storage`
  String get privateKeyNotFoundInStorage {
    return Intl.message(
      'Private key not found in storage',
      name: 'privateKeyNotFoundInStorage',
      desc: 'Exception message when the private key is not found in storage.',
      args: [],
    );
  }

  /// `No item selected for the transaction.`
  String get noItemSelectedForTransaction {
    return Intl.message(
      'No item selected for the transaction.',
      name: 'noItemSelectedForTransaction',
      desc: 'Exception message when no item is selected for the transaction.',
      args: [],
    );
  }

  /// `Standard Asset transfer successful.`
  String get standardAssetTransferSuccessful {
    return Intl.message(
      'Standard Asset transfer successful.',
      name: 'standardAssetTransferSuccessful',
      desc: 'Message displayed when a standard asset transfer is successful.',
      args: [],
    );
  }

  /// `ARC-0200 Asset transfer successful.`
  String get arc0200AssetTransferSuccessful {
    return Intl.message(
      'ARC-0200 Asset transfer successful.',
      name: 'arc0200AssetTransferSuccessful',
      desc: 'Message displayed when an ARC-0200 asset transfer is successful.',
      args: [],
    );
  }

  /// `Unsupported asset type: {assetType}`
  String unsupportedAssetType(String assetType) {
    return Intl.message(
      'Unsupported asset type: $assetType',
      name: 'unsupportedAssetType',
      desc: 'Error message for unsupported asset type.',
      args: [assetType],
    );
  }

  /// `Insufficient funds.`
  String get insufficientFundsError {
    return Intl.message(
      'Insufficient funds.',
      name: 'insufficientFundsError',
      desc: 'Error message when there are insufficient funds.',
      args: [],
    );
  }

  /// `Transaction failed to confirm within the expected rounds.`
  String get transactionFailedToConfirm {
    return Intl.message(
      'Transaction failed to confirm within the expected rounds.',
      name: 'transactionFailedToConfirm',
      desc:
          'Error message when a transaction fails to confirm within expected rounds.',
      args: [],
    );
  }

  /// `Sending Payment`
  String get sendingPayment {
    return Intl.message(
      'Sending Payment',
      name: 'sendingPayment',
      desc: 'Message displayed when sending a payment.',
      args: [],
    );
  }

  /// `Sending Asset`
  String get sendingAsset {
    return Intl.message(
      'Sending Asset',
      name: 'sendingAsset',
      desc: 'Message displayed when sending an asset.',
      args: [],
    );
  }

  /// `Contact name updated successfully.`
  String get contactNameUpdatedSuccessfully {
    return Intl.message(
      'Contact name updated successfully.',
      name: 'contactNameUpdatedSuccessfully',
      desc: 'Message displayed when a contact name is successfully updated.',
      args: [],
    );
  }

  /// `Contact saved successfully.`
  String get contactSavedSuccessfully {
    return Intl.message(
      'Contact saved successfully.',
      name: 'contactSavedSuccessfully',
      desc: 'Message displayed when a contact is successfully saved.',
      args: [],
    );
  }

  /// `Failed to save contact: {error}`
  String failedToSaveContact(Object error) {
    return Intl.message(
      'Failed to save contact: $error',
      name: 'failedToSaveContact',
      desc: 'Error message when saving a contact fails.',
      args: [error],
    );
  }

  /// `Max`
  String get max {
    return Intl.message(
      'Max',
      name: 'max',
      desc: 'Label for maximum amount.',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message(
      'Error',
      name: 'error',
      desc: 'Label for error messages.',
      args: [],
    );
  }

  /// `Calculating...`
  String get calculating {
    return Intl.message(
      'Calculating...',
      name: 'calculating',
      desc: 'Message displayed when a calculation is in progress.',
      args: [],
    );
  }

  /// `The maximum VOI amount is calculated by: the balance ({balance}), minus the minimum balance needed to keep the account open ({minimumBalance}), minus the minimum transaction fee (0.001)`
  String maxVoiAmountCalculation(Object balance, Object minimumBalance) {
    return Intl.message(
      'The maximum VOI amount is calculated by: the balance ($balance), minus the minimum balance needed to keep the account open ($minimumBalance), minus the minimum transaction fee (0.001)',
      name: 'maxVoiAmountCalculation',
      desc: 'Explanation of how the maximum VOI amount is calculated.',
      args: [balance, minimumBalance],
    );
  }

  /// `Info`
  String get info {
    return Intl.message(
      'Info',
      name: 'info',
      desc: 'Header label for information.',
      args: [],
    );
  }

  /// `Account`
  String get account {
    return Intl.message(
      'Account',
      name: 'account',
      desc: 'Label for the account field.',
      args: [],
    );
  }

  /// `Asset`
  String get asset {
    return Intl.message(
      'Asset',
      name: 'asset',
      desc: 'Label for the asset field.',
      args: [],
    );
  }

  /// `Amount`
  String get amount {
    return Intl.message(
      'Amount',
      name: 'amount',
      desc: 'Label for the amount field.',
      args: [],
    );
  }

  /// `Contact Name (Optional)`
  String get contactNameOptional {
    return Intl.message(
      'Contact Name (Optional)',
      name: 'contactNameOptional',
      desc: 'Label for the contact name field, optional.',
      args: [],
    );
  }

  /// `Note (Optional)`
  String get noteOptional {
    return Intl.message(
      'Note (Optional)',
      name: 'noteOptional',
      desc: 'Label for the note field, optional.',
      args: [],
    );
  }

  /// `Send`
  String get send {
    return Intl.message(
      'Send',
      name: 'send',
      desc: 'Text for the send button.',
      args: [],
    );
  }

  /// `Select Asset`
  String get selectAsset {
    return Intl.message(
      'Select Asset',
      name: 'selectAsset',
      desc: 'Header for the select asset dialog.',
      args: [],
    );
  }

  /// `Transaction failed`
  String get transactionFailed {
    return Intl.message(
      'Transaction failed',
      name: 'transactionFailed',
      desc: 'Exception message when a transaction fails.',
      args: [],
    );
  }

  /// `No account`
  String get noAccount {
    return Intl.message(
      'No account',
      name: 'noAccount',
      desc: 'Text displayed when there is no active account.',
      args: [],
    );
  }

  /// `Note is too large.`
  String get noteTooLarge {
    return Intl.message(
      'Note is too large.',
      name: 'noteTooLarge',
      desc:
          'Error message displayed when the note exceeds the maximum allowed byte size.',
      args: [],
    );
  }

  /// `Send Transaction`
  String get sendTransactionTitle {
    return Intl.message(
      'Send Transaction',
      name: 'sendTransactionTitle',
      desc: 'Title displayed on the send transaction screen.',
      args: [],
    );
  }

  /// `Loading...`
  String get loading {
    return Intl.message(
      'Loading...',
      name: 'loading',
      desc: 'Text displayed during loading states.',
      args: [],
    );
  }

  /// `Failed to load`
  String get failedToLoad {
    return Intl.message(
      'Failed to load',
      name: 'failedToLoad',
      desc: 'Text displayed when data fails to load.',
      args: [],
    );
  }

  /// `Recipient Address`
  String get recipientAddress {
    return Intl.message(
      'Recipient Address',
      name: 'recipientAddress',
      desc: 'Label for the recipient address input field.',
      args: [],
    );
  }

  /// `No Items`
  String get noItems {
    return Intl.message(
      'No Items',
      name: 'noItems',
      desc: 'Text displayed when there are no items available.',
      args: [],
    );
  }

  /// `About`
  String get about {
    return Intl.message(
      'About',
      name: 'about',
      desc: 'Title for the About screen.',
      args: [],
    );
  }

  /// `Version:`
  String get version {
    return Intl.message(
      'Version:',
      name: 'version',
      desc: 'Label for the app version.',
      args: [],
    );
  }

  /// `Build:`
  String get build {
    return Intl.message(
      'Build:',
      name: 'build',
      desc: 'Label for the app build version.',
      args: [],
    );
  }

  /// `Build Number:`
  String get buildNumber {
    return Intl.message(
      'Build Number:',
      name: 'buildNumber',
      desc: 'Label for the app build number.',
      args: [],
    );
  }

  /// `Advanced`
  String get advanced {
    return Intl.message(
      'Advanced',
      name: 'advanced',
      desc: 'Title for the Advanced screen.',
      args: [],
    );
  }

  /// `Network switched to {networkName}`
  String networkSwitched(Object networkName) {
    return Intl.message(
      'Network switched to $networkName',
      name: 'networkSwitched',
      desc: 'Message displayed when the network is switched.',
      args: [networkName],
    );
  }

  /// `Allow Test Networks`
  String get allowTestNetworks {
    return Intl.message(
      'Allow Test Networks',
      name: 'allowTestNetworks',
      desc: 'Label for the test network toggle.',
      args: [],
    );
  }

  /// `Toggle to include test networks in the network list.`
  String get toggleTestNetworksDescription {
    return Intl.message(
      'Toggle to include test networks in the network list.',
      name: 'toggleTestNetworksDescription',
      desc: 'Description for the test network toggle.',
      args: [],
    );
  }

  /// `Appearance`
  String get appearance {
    return Intl.message(
      'Appearance',
      name: 'appearance',
      desc: 'Title for the Appearance screen.',
      args: [],
    );
  }

  /// `Dark Mode`
  String get darkMode {
    return Intl.message(
      'Dark Mode',
      name: 'darkMode',
      desc: 'Label for the dark mode toggle.',
      args: [],
    );
  }

  /// `General`
  String get general {
    return Intl.message(
      'General',
      name: 'general',
      desc: 'Title for the General screen.',
      args: [],
    );
  }

  /// `Danger Zone`
  String get dangerZone {
    return Intl.message(
      'Danger Zone',
      name: 'dangerZone',
      desc: 'Title for the danger zone section.',
      args: [],
    );
  }

  /// `This will remove all accounts, settings, and security information.`
  String get dangerZoneDescription {
    return Intl.message(
      'This will remove all accounts, settings, and security information.',
      name: 'dangerZoneDescription',
      desc: 'Description of the danger zone section.',
      args: [],
    );
  }

  /// `Confirm Reset`
  String get confirmReset {
    return Intl.message(
      'Confirm Reset',
      name: 'confirmReset',
      desc: 'Title for the pin pad dialog to confirm reset.',
      args: [],
    );
  }

  /// `Export Accounts`
  String get exportAccounts {
    return Intl.message(
      'Export Accounts',
      name: 'exportAccounts',
      desc: 'Title for the Export Accounts screen.',
      args: [],
    );
  }

  /// `No accounts available for export.`
  String get noAccountsForExport {
    return Intl.message(
      'No accounts available for export.',
      name: 'noAccountsForExport',
      desc: 'Message displayed when no accounts are available for export.',
      args: [],
    );
  }

  /// `Unnamed Account`
  String get unnamedAccount {
    return Intl.message(
      'Unnamed Account',
      name: 'unnamedAccount',
      desc: 'Label for an account with no name.',
      args: [],
    );
  }

  /// `This account cannot be exported, as it has no private key.`
  String get accountCannotBeExported {
    return Intl.message(
      'This account cannot be exported, as it has no private key.',
      name: 'accountCannotBeExported',
      desc:
          'Message displayed when an account without a private key cannot be exported.',
      args: [],
    );
  }

  /// `All Accounts`
  String get allAccounts {
    return Intl.message(
      'All Accounts',
      name: 'allAccounts',
      desc: 'Label for selecting all accounts in the dropdown.',
      args: [],
    );
  }

  /// `Security`
  String get security {
    return Intl.message(
      'Security',
      name: 'security',
      desc: 'Title for the Security screen.',
      args: [],
    );
  }

  /// `Enable Password Lock`
  String get enablePasswordLock {
    return Intl.message(
      'Enable Password Lock',
      name: 'enablePasswordLock',
      desc: 'Label for the switch to enable or disable password lock.',
      args: [],
    );
  }

  /// `Select Timeout`
  String get selectTimeout {
    return Intl.message(
      'Select Timeout',
      name: 'selectTimeout',
      desc: 'Header for the timeout selection dialog.',
      args: [],
    );
  }

  /// `Timeout`
  String get timeout {
    return Intl.message(
      'Timeout',
      name: 'timeout',
      desc: 'Label for the timeout dropdown.',
      args: [],
    );
  }

  /// `Change Pin`
  String get changePin {
    return Intl.message(
      'Change Pin',
      name: 'changePin',
      desc: 'Title for the change pin option.',
      args: [],
    );
  }

  /// `Sessions`
  String get sessions {
    return Intl.message(
      'Sessions',
      name: 'sessions',
      desc: 'Title for the Sessions screen.',
      args: [],
    );
  }

  /// `Disconnect All Sessions?`
  String get disconnectAllSessions {
    return Intl.message(
      'Disconnect All Sessions?',
      name: 'disconnectAllSessions',
      desc: 'Tooltip for disconnecting all sessions.',
      args: [],
    );
  }

  /// `Disconnect all sessions?`
  String get disconnectAllSessionsPrompt {
    return Intl.message(
      'Disconnect all sessions?',
      name: 'disconnectAllSessionsPrompt',
      desc: 'Prompt message to confirm disconnecting all sessions.',
      args: [],
    );
  }

  /// `No active sessions.`
  String get noActiveSessions {
    return Intl.message(
      'No active sessions.',
      name: 'noActiveSessions',
      desc: 'Message displayed when there are no active sessions.',
      args: [],
    );
  }

  /// `Disconnect all sessions for this account?`
  String get disconnectAllSessionsForAccountPrompt {
    return Intl.message(
      'Disconnect all sessions for this account?',
      name: 'disconnectAllSessionsForAccountPrompt',
      desc:
          'Prompt message to confirm disconnecting all sessions for a specific account.',
      args: [],
    );
  }

  /// `Disconnect All`
  String get disconnectAll {
    return Intl.message(
      'Disconnect All',
      name: 'disconnectAll',
      desc: 'Label for the button to disconnect all sessions for an account.',
      args: [],
    );
  }

  /// `Expires:`
  String get expires {
    return Intl.message(
      'Expires:',
      name: 'expires',
      desc: 'Label for the session expiration date.',
      args: [],
    );
  }

  /// `Failed to disconnect {sessionName}. Please try again.`
  String failedToDisconnect(Object sessionName) {
    return Intl.message(
      'Failed to disconnect $sessionName. Please try again.',
      name: 'failedToDisconnect',
      desc: 'Error message when failing to disconnect a session.',
      args: [sessionName],
    );
  }

  /// `{sessionName} disconnected successfully.`
  String sessionDisconnected(Object sessionName) {
    return Intl.message(
      '$sessionName disconnected successfully.',
      name: 'sessionDisconnected',
      desc: 'Message displayed when a session is successfully disconnected.',
      args: [sessionName],
    );
  }

  /// `All sessions`
  String get allSessions {
    return Intl.message(
      'All sessions',
      name: 'allSessions',
      desc: 'Label for all sessions.',
      args: [],
    );
  }

  /// `All sessions for {publicKey}`
  String allSessionsFor(Object publicKey) {
    return Intl.message(
      'All sessions for $publicKey',
      name: 'allSessionsFor',
      desc: 'Label for all sessions associated with a specific account.',
      args: [publicKey],
    );
  }

  /// `Disconnect`
  String get disconnect {
    return Intl.message(
      'Disconnect',
      name: 'disconnect',
      desc: 'Label for the disconnect button.',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: 'Label for the Settings screen.',
      args: [],
    );
  }

  /// `Create New Account`
  String get createNewAccount {
    return Intl.message(
      'Create New Account',
      name: 'createNewAccount',
      desc: 'Title for creating a new account.',
      args: [],
    );
  }

  /// `You will be prompted to save a seed.`
  String get createNewAccountSubtitle {
    return Intl.message(
      'You will be prompted to save a seed.',
      name: 'createNewAccountSubtitle',
      desc: 'Subtitle for creating a new account.',
      args: [],
    );
  }

  /// `Import Via Seed`
  String get importViaSeed {
    return Intl.message(
      'Import Via Seed',
      name: 'importViaSeed',
      desc: 'Title for importing an account via seed.',
      args: [],
    );
  }

  /// `Import an existing account via seed phrase.`
  String get importViaSeedSubtitle {
    return Intl.message(
      'Import an existing account via seed phrase.',
      name: 'importViaSeedSubtitle',
      desc: 'Subtitle for importing an account via seed.',
      args: [],
    );
  }

  /// `Import Via QR Code`
  String get importViaQrCode {
    return Intl.message(
      'Import Via QR Code',
      name: 'importViaQrCode',
      desc: 'Title for importing an account via QR code.',
      args: [],
    );
  }

  /// `Scan a QR code to import an existing account.`
  String get importViaQrCodeSubtitle {
    return Intl.message(
      'Scan a QR code to import an existing account.',
      name: 'importViaQrCodeSubtitle',
      desc: 'Subtitle for importing an account via QR code.',
      args: [],
    );
  }

  /// `Import via Private Key`
  String get importViaPrivateKey {
    return Intl.message(
      'Import via Private Key',
      name: 'importViaPrivateKey',
      desc: 'Title for importing an account via private key.',
      args: [],
    );
  }

  /// `Import accounts from a private key.`
  String get importViaPrivateKeySubtitle {
    return Intl.message(
      'Import accounts from a private key.',
      name: 'importViaPrivateKeySubtitle',
      desc: 'Subtitle for importing an account via private key.',
      args: [],
    );
  }

  /// `Add Watch`
  String get addWatch {
    return Intl.message(
      'Add Watch',
      name: 'addWatch',
      desc: 'Title for adding a watch account.',
      args: [],
    );
  }

  /// `Add watch account to watch via public address.`
  String get addWatchSubtitle {
    return Intl.message(
      'Add watch account to watch via public address.',
      name: 'addWatchSubtitle',
      desc: 'Subtitle for adding a watch account.',
      args: [],
    );
  }

  /// `Add Account`
  String get addAccountTitle {
    return Intl.message(
      'Add Account',
      name: 'addAccountTitle',
      desc: 'Title for Add Account screen.',
      args: [],
    );
  }

  /// `Import Public Address`
  String get importPublicAddress {
    return Intl.message(
      'Import Public Address',
      name: 'importPublicAddress',
      desc: 'Title for the Add Watch screen.',
      args: [],
    );
  }

  /// `Public Address`
  String get publicAddress {
    return Intl.message(
      'Public Address',
      name: 'publicAddress',
      desc: 'Label for the public address text field.',
      args: [],
    );
  }

  /// `Import`
  String get import {
    return Intl.message(
      'Import',
      name: 'import',
      desc: 'Text for the import button.',
      args: [],
    );
  }

  /// `Please enter a public address.`
  String get pleaseEnterPublicAddress {
    return Intl.message(
      'Please enter a public address.',
      name: 'pleaseEnterPublicAddress',
      desc: 'Error message displayed when the public address is empty.',
      args: [],
    );
  }

  /// `Invalid Algorand address.`
  String get invalidAlgorandAddress {
    return Intl.message(
      'Invalid Algorand address.',
      name: 'invalidAlgorandAddress',
      desc:
          'Error message displayed when an invalid Algorand address is entered.',
      args: [],
    );
  }

  /// `Copy Seed`
  String get copySeed {
    return Intl.message(
      'Copy Seed',
      name: 'copySeed',
      desc: 'Title for the Copy Seed screen.',
      args: [],
    );
  }

  /// `Generate seed phrase`
  String get generateSeedPhrase {
    return Intl.message(
      'Generate seed phrase',
      name: 'generateSeedPhrase',
      desc: 'Label for generating a seed phrase.',
      args: [],
    );
  }

  /// `Here is your 25 word mnemonic seed phrase. Make sure you save this in a secure place.`
  String get seedPhraseDescription {
    return Intl.message(
      'Here is your 25 word mnemonic seed phrase. Make sure you save this in a secure place.',
      name: 'seedPhraseDescription',
      desc: 'Description for displaying the mnemonic seed phrase.',
      args: [],
    );
  }

  /// `Copy seed phrase`
  String get copySeedPhrase {
    return Intl.message(
      'Copy seed phrase',
      name: 'copySeedPhrase',
      desc: 'Tooltip for copying the seed phrase.',
      args: [],
    );
  }

  /// `No seed phrase available.`
  String get noSeedPhraseAvailable {
    return Intl.message(
      'No seed phrase available.',
      name: 'noSeedPhraseAvailable',
      desc: 'Message when no seed phrase is available.',
      args: [],
    );
  }

  /// `You must confirm you have made a backup of your seed phrase.`
  String get backupConfirmationRequired {
    return Intl.message(
      'You must confirm you have made a backup of your seed phrase.',
      name: 'backupConfirmationRequired',
      desc: 'Validation error message when backup is not confirmed.',
      args: [],
    );
  }

  /// `Please confirm you have stored a backup of your seed phrase in a secure location.`
  String get backupConfirmationPrompt {
    return Intl.message(
      'Please confirm you have stored a backup of your seed phrase in a secure location.',
      name: 'backupConfirmationPrompt',
      desc:
          'Prompt for users to confirm they have backed up their seed phrase.',
      args: [],
    );
  }

  /// `Next`
  String get next {
    return Intl.message(
      'Next',
      name: 'next',
      desc: 'Label for the next button.',
      args: [],
    );
  }

  /// `Import Private Key`
  String get importPrivateKey {
    return Intl.message(
      'Import Private Key',
      name: 'importPrivateKey',
      desc: 'Title for the Import Private Key screen.',
      args: [],
    );
  }

  /// `Private Key`
  String get privateKey {
    return Intl.message(
      'Private Key',
      name: 'privateKey',
      desc: 'Label for the private key text field.',
      args: [],
    );
  }

  /// `Import Seed`
  String get importSeed {
    return Intl.message(
      'Import Seed',
      name: 'importSeed',
      desc: 'Title for the Import Seed screen.',
      args: [],
    );
  }

  /// `Enter your seed phrase to import your account.`
  String get enterSeedPhrasePrompt {
    return Intl.message(
      'Enter your seed phrase to import your account.',
      name: 'enterSeedPhrasePrompt',
      desc: 'Prompt asking the user to enter their seed phrase.',
      args: [],
    );
  }

  /// `Enter word {index}`
  String enterWord(int index) {
    return Intl.message(
      'Enter word $index',
      name: 'enterWord',
      desc: 'Error message for an empty word input in the seed phrase.',
      args: [index],
    );
  }

  /// `Name Account`
  String get nameAccount {
    return Intl.message(
      'Name Account',
      name: 'nameAccount',
      desc: 'Title for naming an account.',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: 'Label for the delete button.',
      args: [],
    );
  }

  /// `Are you sure you want to delete this account?`
  String get confirmDeleteAccount {
    return Intl.message(
      'Are you sure you want to delete this account?',
      name: 'confirmDeleteAccount',
      desc: 'Confirmation message for deleting an account.',
      args: [],
    );
  }

  /// `Edit your account name`
  String get editAccountNamePrompt {
    return Intl.message(
      'Edit your account name',
      name: 'editAccountNamePrompt',
      desc: 'Prompt for editing the account name.',
      args: [],
    );
  }

  /// `Name your account`
  String get nameAccountPrompt {
    return Intl.message(
      'Name your account',
      name: 'nameAccountPrompt',
      desc: 'Prompt for naming an account.',
      args: [],
    );
  }

  /// `You can change your account name below.`
  String get editAccountDescription {
    return Intl.message(
      'You can change your account name below.',
      name: 'editAccountDescription',
      desc: 'Description for editing an account.',
      args: [],
    );
  }

  /// `Give your account a nickname. Don’t worry, you can change this later.`
  String get nameAccountDescription {
    return Intl.message(
      'Give your account a nickname. Don’t worry, you can change this later.',
      name: 'nameAccountDescription',
      desc: 'Description for naming an account.',
      args: [],
    );
  }

  /// `Account Name`
  String get accountName {
    return Intl.message(
      'Account Name',
      name: 'accountName',
      desc: 'Label for the account name text field.',
      args: [],
    );
  }

  /// `Please enter some text`
  String get pleaseEnterText {
    return Intl.message(
      'Please enter some text',
      name: 'pleaseEnterText',
      desc: 'Validation error message for empty input fields.',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: 'Label for the save button.',
      args: [],
    );
  }

  /// `Create`
  String get create {
    return Intl.message(
      'Create',
      name: 'create',
      desc: 'Label for the create button.',
      args: [],
    );
  }

  /// `Updating Account`
  String get updatingAccount {
    return Intl.message(
      'Updating Account',
      name: 'updatingAccount',
      desc: 'Message displayed while updating an account.',
      args: [],
    );
  }

  /// `Creating Account`
  String get creatingAccount {
    return Intl.message(
      'Creating Account',
      name: 'creatingAccount',
      desc: 'Message displayed while creating an account.',
      args: [],
    );
  }

  /// `Welcome`
  String get welcomeTitle {
    return Intl.message(
      'Welcome',
      name: 'welcomeTitle',
      desc: 'Title for the Welcome screen.',
      args: [],
    );
  }

  /// `Welcome. First, let’s create a new pincode to secure this device.`
  String get welcomeMessage {
    return Intl.message(
      'Welcome. First, let’s create a new pincode to secure this device.',
      name: 'welcomeMessage',
      desc: 'Welcome message for the user, prompting them to create a pincode.',
      args: [],
    );
  }

  /// `Algorand Standard Asset`
  String get algorandStandardAsset {
    return Intl.message(
      'Algorand Standard Asset',
      name: 'algorandStandardAsset',
      desc: 'Label for ASA assets.',
      args: [],
    );
  }

  /// `Insufficient balance.`
  String get insufficientBalance {
    return Intl.message(
      'Insufficient balance.',
      name: 'insufficientBalance',
      desc: 'Error message when the user does not have enough funds.',
      args: [],
    );
  }

  /// `Asset successfully opted in`
  String get assetOptInSuccess {
    return Intl.message(
      'Asset successfully opted in',
      name: 'assetOptInSuccess',
      desc: 'Success message displayed when asset opt-in completes.',
      args: [],
    );
  }

  /// `Application ID`
  String get applicationId {
    return Intl.message(
      'Application ID',
      name: 'applicationId',
      desc: 'Label for the application ID field.',
      args: [],
    );
  }

  /// `Type`
  String get type {
    return Intl.message(
      'Type',
      name: 'type',
      desc: 'Label for the type field.',
      args: [],
    );
  }

  /// `Decimals`
  String get decimals {
    return Intl.message(
      'Decimals',
      name: 'decimals',
      desc: 'Label for the decimals field.',
      args: [],
    );
  }

  /// `Total Supply`
  String get totalSupply {
    return Intl.message(
      'Total Supply',
      name: 'totalSupply',
      desc: 'Label for the total supply field.',
      args: [],
    );
  }

  /// `Send Asset`
  String get sendAsset {
    return Intl.message(
      'Send Asset',
      name: 'sendAsset',
      desc: 'Button text to send an asset.',
      args: [],
    );
  }

  /// `Add Asset`
  String get addAsset {
    return Intl.message(
      'Add Asset',
      name: 'addAsset',
      desc: 'Button text to add an asset.',
      args: [],
    );
  }

  /// `Opting in...`
  String get optingInMessage {
    return Intl.message(
      'Opting in...',
      name: 'optingInMessage',
      desc: 'Message displayed during the asset opt-in process.',
      args: [],
    );
  }

  /// `Active asset is null`
  String get activeAssetNullError {
    return Intl.message(
      'Active asset is null',
      name: 'activeAssetNullError',
      desc: 'Error message when no active asset is found.',
      args: [],
    );
  }

  /// `Please fund your account to proceed.`
  String get fundAccountError {
    return Intl.message(
      'Please fund your account to proceed.',
      name: 'fundAccountError',
      desc: 'Error message when the user\'s account balance is insufficient.',
      args: [],
    );
  }

  /// `Private key not found`
  String get privateKeyNotFoundError {
    return Intl.message(
      'Private key not found',
      name: 'privateKeyNotFoundError',
      desc: 'Error message when the private key is unavailable.',
      args: [],
    );
  }

  /// `Account ID or Public Address is not available`
  String get accountIdOrAddressNotAvailable {
    return Intl.message(
      'Account ID or Public Address is not available',
      name: 'accountIdOrAddressNotAvailable',
      desc: 'Error message when account ID or public address is missing.',
      args: [],
    );
  }

  /// `Failed to opt-in to asset`
  String get failedToOptInError {
    return Intl.message(
      'Failed to opt-in to asset',
      name: 'failedToOptInError',
      desc: 'Error message when asset opt-in fails.',
      args: [],
    );
  }

  /// `An error occurred with Algorand service`
  String get algorandServiceError {
    return Intl.message(
      'An error occurred with Algorand service',
      name: 'algorandServiceError',
      desc: 'General error message for Algorand service failures.',
      args: [],
    );
  }

  /// `View Asset`
  String get viewAssetTitle {
    return Intl.message(
      'View Asset',
      name: 'viewAssetTitle',
      desc: 'Title for the View Asset screen.',
      args: [],
    );
  }

  /// `Add Asset`
  String get addAssetTitle {
    return Intl.message(
      'Add Asset',
      name: 'addAssetTitle',
      desc: 'Title for the Add Asset screen.',
      args: [],
    );
  }

  /// `No asset available to display.`
  String get noAssetAvailableMessage {
    return Intl.message(
      'No asset available to display.',
      name: 'noAssetAvailableMessage',
      desc: 'Message displayed when no asset is available to view.',
      args: [],
    );
  }

  /// `Opt-out`
  String get optOutTooltip {
    return Intl.message(
      'Opt-out',
      name: 'optOutTooltip',
      desc: 'Tooltip for the opt-out action button.',
      args: [],
    );
  }

  /// `Opt Out of Asset?`
  String get optOutAssetTitle {
    return Intl.message(
      'Opt Out of Asset?',
      name: 'optOutAssetTitle',
      desc: 'Title for the opt-out confirmation dialog.',
      args: [],
    );
  }

  /// `Are you sure you want to opt out of this ARC-0200 asset?`
  String get optOutAssetContent {
    return Intl.message(
      'Are you sure you want to opt out of this ARC-0200 asset?',
      name: 'optOutAssetContent',
      desc: 'Content for the opt-out confirmation dialog.',
      args: [],
    );
  }

  /// `Opt Out`
  String get optOutButton {
    return Intl.message(
      'Opt Out',
      name: 'optOutButton',
      desc: 'Label for the Opt-Out button in the confirmation dialog.',
      args: [],
    );
  }

  /// `Cancel`
  String get cancelButton {
    return Intl.message(
      'Cancel',
      name: 'cancelButton',
      desc: 'Label for the Cancel button in dialogs.',
      args: [],
    );
  }

  /// `NFT Viewer`
  String get nftViewerTitle {
    return Intl.message(
      'NFT Viewer',
      name: 'nftViewerTitle',
      desc: 'Title for the NFT Viewer screen.',
      args: [],
    );
  }

  /// `Sent Transaction`
  String get sentTransactionTitle {
    return Intl.message(
      'Sent Transaction',
      name: 'sentTransactionTitle',
      desc: 'Title for transactions where assets are sent.',
      args: [],
    );
  }

  /// `Transaction Type`
  String get transactionType {
    return Intl.message(
      'Transaction Type',
      name: 'transactionType',
      desc: 'Label for transaction type field.',
      args: [],
    );
  }

  /// `From`
  String get fromField {
    return Intl.message(
      'From',
      name: 'fromField',
      desc: 'Label for sender field.',
      args: [],
    );
  }

  /// `To`
  String get toField {
    return Intl.message(
      'To',
      name: 'toField',
      desc: 'Label for recipient field.',
      args: [],
    );
  }

  /// `Fee`
  String get fee {
    return Intl.message(
      'Fee',
      name: 'fee',
      desc: 'Label for transaction fee.',
      args: [],
    );
  }

  /// `Date`
  String get date {
    return Intl.message(
      'Date',
      name: 'date',
      desc: 'Label for transaction date field.',
      args: [],
    );
  }

  /// `Transaction ID`
  String get transactionId {
    return Intl.message(
      'Transaction ID',
      name: 'transactionId',
      desc: 'Label for transaction ID field.',
      args: [],
    );
  }

  /// `Note`
  String get note {
    return Intl.message(
      'Note',
      name: 'note',
      desc: 'Label for transaction note field.',
      args: [],
    );
  }

  /// `Received Transaction`
  String get receivedTransactionTitle {
    return Intl.message(
      'Received Transaction',
      name: 'receivedTransactionTitle',
      desc: 'Title for transactions where assets are received.',
      args: [],
    );
  }

  /// `Self Transfer`
  String get selfTransferTitle {
    return Intl.message(
      'Self Transfer',
      name: 'selfTransferTitle',
      desc: 'Title for transactions where assets are sent to self.',
      args: [],
    );
  }

  /// `View Transaction`
  String get viewTransactionTitle {
    return Intl.message(
      'View Transaction',
      name: 'viewTransactionTitle',
      desc: 'Title for the view transaction screen.',
      args: [],
    );
  }

  /// `No transaction available to display.`
  String get noTransactionAvailable {
    return Intl.message(
      'No transaction available to display.',
      name: 'noTransactionAvailable',
      desc: 'Message displayed when no transaction is available.',
      args: [],
    );
  }

  /// `The supplied value "{value}" is not a valid address.`
  String invalidAddressSupplied(String value) {
    return Intl.message(
      'The supplied value "$value" is not a valid address.',
      name: 'invalidAddressSupplied',
      desc: 'Error message for invalid Algorand address.',
      args: [value],
    );
  }

  /// `Byte string must be {expected} bytes long for a valid address, found "{found}" length.`
  String invalidAddressByteLength(int expected, int found) {
    return Intl.message(
      'Byte string must be $expected bytes long for a valid address, found "$found" length.',
      name: 'invalidAddressByteLength',
      desc: 'Error message for incorrect byte length for an address.',
      args: [expected, found],
    );
  }

  /// `address`
  String get addressType {
    return Intl.message(
      'address',
      name: 'addressType',
      desc: 'String representation of the ABI address type.',
      args: [],
    );
  }

  /// `No active account found.`
  String get noActiveAccountFound {
    return Intl.message(
      'No active account found.',
      name: 'noActiveAccountFound',
      desc:
          'Error message displayed when no active account is found in storage.',
      args: [],
    );
  }

  /// `Failed to initialize account: {error}`
  String failedToInitializeAccount(Object error) {
    return Intl.message(
      'Failed to initialize account: $error',
      name: 'failedToInitializeAccount',
      desc: 'Error message when account initialization fails.',
      args: [error],
    );
  }

  /// `Public key not found in storage.`
  String get publicKeyNotFoundInStorage {
    return Intl.message(
      'Public key not found in storage.',
      name: 'publicKeyNotFoundInStorage',
      desc: 'Error message when the public key is not found in storage.',
      args: [],
    );
  }

  /// `This account has not been funded yet. Please fund it to see details.`
  String get accountNotFundedPleaseFundToSeeDetails {
    return Intl.message(
      'This account has not been funded yet. Please fund it to see details.',
      name: 'accountNotFundedPleaseFundToSeeDetails',
      desc: 'Error message displayed when an account has not been funded yet.',
      args: [],
    );
  }

  /// `Account name is too long.`
  String get accountNameIsTooLong {
    return Intl.message(
      'Account name is too long.',
      name: 'accountNameIsTooLong',
      desc:
          'Error message displayed when the account name exceeds the maximum length.',
      args: [],
    );
  }

  /// `Failed to create account name: {error}`
  String failedToCreateAccountName(Object error) {
    return Intl.message(
      'Failed to create account name: $error',
      name: 'failedToCreateAccountName',
      desc: 'Error message displayed when creating account name fails.',
      args: [error],
    );
  }

  /// `Failed to create account: {error}`
  String failedToCreateAccount(Object error) {
    return Intl.message(
      'Failed to create account: $error',
      name: 'failedToCreateAccount',
      desc: 'Error message displayed when account creation fails.',
      args: [error],
    );
  }

  /// `No active account to update.`
  String get noActiveAccountToUpdate {
    return Intl.message(
      'No active account to update.',
      name: 'noActiveAccountToUpdate',
      desc: 'Error message when there is no active account to update.',
      args: [],
    );
  }

  /// `Account not found.`
  String get accountNotFound {
    return Intl.message(
      'Account not found.',
      name: 'accountNotFound',
      desc: 'Error message when the specified account is not found.',
      args: [],
    );
  }

  /// `Failed to delete account: {error}`
  String failedToDeleteAccount(Object error) {
    return Intl.message(
      'Failed to delete account: $error',
      name: 'failedToDeleteAccount',
      desc: 'Error message displayed when account deletion fails.',
      args: [error],
    );
  }

  /// `Failed to restore account: {error}`
  String failedToRestoreAccount(Object error) {
    return Intl.message(
      'Failed to restore account: $error',
      name: 'failedToRestoreAccount',
      desc: 'Error message displayed when account restoration fails.',
      args: [error],
    );
  }

  /// `No active account.`
  String get noActiveAccount {
    return Intl.message(
      'No active account.',
      name: 'noActiveAccount',
      desc: 'Error message when there is no active account.',
      args: [],
    );
  }

  /// `Seed phrase not found in storage.`
  String get seedPhraseNotFoundInStorage {
    return Intl.message(
      'Seed phrase not found in storage.',
      name: 'seedPhraseNotFoundInStorage',
      desc: 'Error message when the seed phrase is not found in storage.',
      args: [],
    );
  }

  /// `Public address is not available.`
  String get publicAddressNotAvailable {
    return Intl.message(
      'Public address is not available.',
      name: 'publicAddressNotAvailable',
      desc: 'Error message when the public address is not available.',
      args: [],
    );
  }

  /// `Account is missing in temporary account data.`
  String get accountMissingInTemporaryData {
    return Intl.message(
      'Account is missing in temporary account data.',
      name: 'accountMissingInTemporaryData',
      desc: 'Error message when the account is missing in temporary data.',
      args: [],
    );
  }

  /// `Incomplete temporary account data for regular account.`
  String get incompleteTemporaryAccountData {
    return Intl.message(
      'Incomplete temporary account data for regular account.',
      name: 'incompleteTemporaryAccountData',
      desc: 'Error message when the temporary account data is incomplete.',
      args: [],
    );
  }

  /// `Public key is missing.`
  String get publicKeyIsMissing {
    return Intl.message(
      'Public key is missing.',
      name: 'publicKeyIsMissing',
      desc: 'Error message when the public key is missing.',
      args: [],
    );
  }

  /// `Unsupported account type.`
  String get unsupportedAccountType {
    return Intl.message(
      'Unsupported account type.',
      name: 'unsupportedAccountType',
      desc: 'Error message when an unsupported account type is encountered.',
      args: [],
    );
  }

  /// `Failed to finalize account creation: {error}`
  String failedToFinalizeAccountCreation(Object error) {
    return Intl.message(
      'Failed to finalize account creation: $error',
      name: 'failedToFinalizeAccountCreation',
      desc: 'Error message displayed when finalizing account creation fails.',
      args: [error],
    );
  }

  /// `Failed to create unsigned transfer transactions: {error}`
  String failedToCreateUnsignedTransactions(Object error) {
    return Intl.message(
      'Failed to create unsigned transfer transactions: $error',
      name: 'failedToCreateUnsignedTransactions',
      desc: 'Error message when creating unsigned transactions fails.',
      args: [error],
    );
  }

  /// `Transaction failed: Transaction ID invalid or marked as 'error'.`
  String get transactionIdInvalid {
    return Intl.message(
      'Transaction failed: Transaction ID invalid or marked as \'error\'.',
      name: 'transactionIdInvalid',
      desc:
          'Error message when a transaction ID is invalid or marked as \'error\'.',
      args: [],
    );
  }

  /// `Failed to send payment: {error}`
  String failedToSendPayment(Object error) {
    return Intl.message(
      'Failed to send payment: $error',
      name: 'failedToSendPayment',
      desc: 'Error message when a payment fails to send.',
      args: [error],
    );
  }

  /// `Failed to fetch assets: {error}`
  String getAccountAssetsFailed(Object error) {
    return Intl.message(
      'Failed to fetch assets: $error',
      name: 'getAccountAssetsFailed',
      desc: 'Error message when fetching account assets fails.',
      args: [error],
    );
  }

  /// `Failed to fetch asset details: {error}`
  String assetDetailsFetchFailed(Object error) {
    return Intl.message(
      'Failed to fetch asset details: $error',
      name: 'assetDetailsFetchFailed',
      desc: 'Error message when fetching asset details fails.',
      args: [error],
    );
  }

  /// `Invalid asset ID format. Asset ID must be a valid integer.`
  String get assetIdInvalidFormat {
    return Intl.message(
      'Invalid asset ID format. Asset ID must be a valid integer.',
      name: 'assetIdInvalidFormat',
      desc: 'Error message when an asset ID is invalid.',
      args: [],
    );
  }

  /// `Failed to opt-in to asset: {error}`
  String assetOptInFailed(Object error) {
    return Intl.message(
      'Failed to opt-in to asset: $error',
      name: 'assetOptInFailed',
      desc: 'Error message when opting into an asset fails.',
      args: [error],
    );
  }

  /// `Failed to fetch ARC-0200 asset details`
  String get arc200AssetFetchFailed {
    return Intl.message(
      'Failed to fetch ARC-0200 asset details',
      name: 'arc200AssetFetchFailed',
      desc: 'Error message when fetching ARC-0200 asset details fails.',
      args: [],
    );
  }

  /// `Failed to transfer asset: {error}`
  String failedToTransferAsset(Object error) {
    return Intl.message(
      'Failed to transfer asset: $error',
      name: 'failedToTransferAsset',
      desc: 'Error message when transferring an asset fails.',
      args: [error],
    );
  }

  /// `Failed to {action} asset: {error}`
  String failedToToggleFreeze(Object action, Object error) {
    return Intl.message(
      'Failed to $action asset: $error',
      name: 'failedToToggleFreeze',
      desc: 'Error message when freezing/unfreezing an asset fails.',
      args: [action, error],
    );
  }

  /// `Failed to revoke asset: {error}`
  String failedToRevokeAsset(Object error) {
    return Intl.message(
      'Failed to revoke asset: $error',
      name: 'failedToRevokeAsset',
      desc: 'Error message when revoking an asset fails.',
      args: [error],
    );
  }

  /// `Failed to fetch transactions: {error}`
  String failedToFetchTransactions(Object error) {
    return Intl.message(
      'Failed to fetch transactions: $error',
      name: 'failedToFetchTransactions',
      desc: 'Error message when fetching transactions fails.',
      args: [error],
    );
  }

  /// `Failed to opt-in to contract: {error}`
  String contractOptInFailed(Object error) {
    return Intl.message(
      'Failed to opt-in to contract: $error',
      name: 'contractOptInFailed',
      desc: 'Error message when opting into a contract fails.',
      args: [error],
    );
  }

  /// `Failed to call contract: {error}`
  String contractCallFailed(Object error) {
    return Intl.message(
      'Failed to call contract: $error',
      name: 'contractCallFailed',
      desc: 'Error message when calling a contract fails.',
      args: [error],
    );
  }

  /// `Transaction error: {error}`
  String transactionError(Object error) {
    return Intl.message(
      'Transaction error: $error',
      name: 'transactionError',
      desc: 'Error message for transaction error.',
      args: [error],
    );
  }

  /// `Search query is too short.`
  String get searchQueryTooShort {
    return Intl.message(
      'Search query is too short.',
      name: 'searchQueryTooShort',
      desc: 'Error message when the search query is too short.',
      args: [],
    );
  }

  /// `Failed to fetch assets: {error}`
  String failedToFetchAssets(Object error) {
    return Intl.message(
      'Failed to fetch assets: $error',
      name: 'failedToFetchAssets',
      desc: 'Error message when fetching assets fails.',
      args: [error],
    );
  }

  /// `Failed to get account balance: {error}`
  String failedToGetAccountBalance(Object error) {
    return Intl.message(
      'Failed to get account balance: $error',
      name: 'failedToGetAccountBalance',
      desc: 'Error message when getting the account balance fails.',
      args: [error],
    );
  }

  /// `Asset edit confirmation failed.`
  String get assetEditConfirmationFailed {
    return Intl.message(
      'Asset edit confirmation failed.',
      name: 'assetEditConfirmationFailed',
      desc: 'Error message when asset edit confirmation fails.',
      args: [],
    );
  }

  /// `Failed to edit asset: {error}`
  String failedToEditAsset(Object error) {
    return Intl.message(
      'Failed to edit asset: $error',
      name: 'failedToEditAsset',
      desc: 'Error message when editing an asset fails.',
      args: [error],
    );
  }

  /// `Failed to destroy asset: {error}`
  String failedToDestroyAsset(Object error) {
    return Intl.message(
      'Failed to destroy asset: $error',
      name: 'failedToDestroyAsset',
      desc: 'Error message when destroying an asset fails.',
      args: [error],
    );
  }

  /// `Asset destruction confirmation failed.`
  String get assetDestructionConfirmationFailed {
    return Intl.message(
      'Asset destruction confirmation failed.',
      name: 'assetDestructionConfirmationFailed',
      desc: 'Error message when the confirmation of asset destruction fails.',
      args: [],
    );
  }

  /// `Failed to opt-in to asset.`
  String get failedToOptInAsset {
    return Intl.message(
      'Failed to opt-in to asset.',
      name: 'failedToOptInAsset',
      desc: 'Error message when opting in to an asset fails.',
      args: [],
    );
  }

  /// `Private key not found for the active account.`
  String get privateKeyNotFound {
    return Intl.message(
      'Private key not found for the active account.',
      name: 'privateKeyNotFound',
      desc:
          'Error message when private key for the active account is not found.',
      args: [],
    );
  }

  /// `Asset opt-in confirmation failed.`
  String get assetOptInConfirmationFailed {
    return Intl.message(
      'Asset opt-in confirmation failed.',
      name: 'assetOptInConfirmationFailed',
      desc: 'Error message when asset opt-in confirmation fails.',
      args: [],
    );
  }

  /// `Failed to opt-in to ASA: {error}`
  String failedToOptInToASA(Object error) {
    return Intl.message(
      'Failed to opt-in to ASA: $error',
      name: 'failedToOptInToASA',
      desc: 'Error message when opting in to an ASA asset fails.',
      args: [error],
    );
  }

  /// `Asset name or unit name is missing.`
  String get assetNameOrUnitMissing {
    return Intl.message(
      'Asset name or unit name is missing.',
      name: 'assetNameOrUnitMissing',
      desc: 'Error message when the asset name or unit name is missing.',
      args: [],
    );
  }

  /// `Failed to follow ARC-0200 asset.`
  String get failedToFollowArc200Asset {
    return Intl.message(
      'Failed to follow ARC-0200 asset.',
      name: 'failedToFollowArc200Asset',
      desc: 'Error message when following an ARC-0200 asset fails.',
      args: [],
    );
  }

  /// `Asset transfer confirmation failed.`
  String get assetTransferConfirmationFailed {
    return Intl.message(
      'Asset transfer confirmation failed.',
      name: 'assetTransferConfirmationFailed',
      desc: 'Error message when asset transfer confirmation fails.',
      args: [],
    );
  }

  /// `Asset is frozen.`
  String get assetIsFrozen {
    return Intl.message(
      'Asset is frozen.',
      name: 'assetIsFrozen',
      desc: 'Error message indicating an asset is frozen.',
      args: [],
    );
  }

  /// `Private key not found for account ID: {accountId}`
  String privateKeyNotFoundForAccount(String accountId) {
    return Intl.message(
      'Private key not found for account ID: $accountId',
      name: 'privateKeyNotFoundForAccount',
      desc:
          'Error message when the private key is not found for a specific account.',
      args: [accountId],
    );
  }

  /// `The encoded key should be 44 characters long.`
  String get invalidEncodedKeyLength {
    return Intl.message(
      'The encoded key should be 44 characters long.',
      name: 'invalidEncodedKeyLength',
      desc: 'Error message when the encoded key length is not 44 characters.',
      args: [],
    );
  }

  /// `Contact not found.`
  String get contactNotFound {
    return Intl.message(
      'Contact not found.',
      name: 'contactNotFound',
      desc: 'Error message when a requested contact cannot be found.',
      args: [],
    );
  }

  /// `Almost there`
  String get almostThere {
    return Intl.message(
      'Almost there',
      name: 'almostThere',
      desc: 'Follow-up message to show when loading is almost complete.',
      args: [],
    );
  }

  /// `Hang in there`
  String get hangInThere {
    return Intl.message(
      'Hang in there',
      name: 'hangInThere',
      desc: 'Encouraging follow-up message during loading.',
      args: [],
    );
  }

  /// `Just a bit more`
  String get justABitMore {
    return Intl.message(
      'Just a bit more',
      name: 'justABitMore',
      desc: 'Message to indicate loading is nearly done.',
      args: [],
    );
  }

  /// `You're doing great`
  String get youreDoingGreat {
    return Intl.message(
      'You\'re doing great',
      name: 'youreDoingGreat',
      desc: 'Encouraging message shown during loading.',
      args: [],
    );
  }

  /// `Nearly done`
  String get nearlyDone {
    return Intl.message(
      'Nearly done',
      name: 'nearlyDone',
      desc: 'Message indicating the loading process is nearly finished.',
      args: [],
    );
  }

  /// `Thanks for waiting`
  String get thanksForWaiting {
    return Intl.message(
      'Thanks for waiting',
      name: 'thanksForWaiting',
      desc: 'Message thanking the user for their patience during loading.',
      args: [],
    );
  }

  /// `Checksum does not match. The scanned QR codes are not from the same set.`
  String get checksumMismatch {
    return Intl.message(
      'Checksum does not match. The scanned QR codes are not from the same set.',
      name: 'checksumMismatch',
      desc:
          'Error message when the checksum of scanned QR codes does not match, indicating they are not from the same set.',
      args: [],
    );
  }

  /// `Network changed to {networkName}`
  String networkChangedTo(String networkName) {
    return Intl.message(
      'Network changed to $networkName',
      name: 'networkChangedTo',
      desc: 'Message displayed when the network is successfully changed.',
      args: [networkName],
    );
  }

  /// `Failed to load NFTs with status code: {statusCode}`
  String failedToLoadNFTs(int statusCode) {
    return Intl.message(
      'Failed to load NFTs with status code: $statusCode',
      name: 'failedToLoadNFTs',
      desc:
          'Error message when the app fails to load NFTs, showing the HTTP status code.',
      args: [statusCode],
    );
  }

  /// `Setting Up`
  String get settingUp {
    return Intl.message(
      'Setting Up',
      name: 'settingUp',
      desc: 'Overlay text shown during PIN setup.',
      args: [],
    );
  }

  /// `Authenticating`
  String get authenticating {
    return Intl.message(
      'Authenticating',
      name: 'authenticating',
      desc: 'Overlay text shown during authentication.',
      args: [],
    );
  }

  /// `Verifying`
  String get verifying {
    return Intl.message(
      'Verifying',
      name: 'verifying',
      desc: 'Overlay text shown during transaction verification.',
      args: [],
    );
  }

  /// `Setting New PIN`
  String get settingNewPin {
    return Intl.message(
      'Setting New PIN',
      name: 'settingNewPin',
      desc: 'Overlay text shown during PIN change process.',
      args: [],
    );
  }

  /// `Account name not found for activeAccountId: {activeAccountId}`
  String accountNameNotFound(String activeAccountId) {
    return Intl.message(
      'Account name not found for activeAccountId: $activeAccountId',
      name: 'accountNameNotFound',
      desc:
          'Error message when the account name for a specific ID is not found.',
      args: [activeAccountId],
    );
  }

  /// `Incorrect PIN`
  String get incorrectPin {
    return Intl.message(
      'Incorrect PIN',
      name: 'incorrectPin',
      desc: 'Error message when the user enters an incorrect PIN.',
      args: [],
    );
  }

  /// `Invalid PIN. Try again.`
  String get invalidPinTryAgain {
    return Intl.message(
      'Invalid PIN. Try again.',
      name: 'invalidPinTryAgain',
      desc: 'Error message when the entered PIN is invalid.',
      args: [],
    );
  }

  /// `Failed to set PIN: {error}`
  String failedToSetPin(String error) {
    return Intl.message(
      'Failed to set PIN: $error',
      name: 'failedToSetPin',
      desc: 'Error message when setting the PIN fails.',
      args: [error],
    );
  }

  /// `Error reading pin hash.`
  String get errorReadingPinHash {
    return Intl.message(
      'Error reading pin hash.',
      name: 'errorReadingPinHash',
      desc:
          'Error message when reading the pin hash from secure storage fails.',
      args: [],
    );
  }

  /// `Failed to read accounts data: {error}`
  String failedToReadAccountsData(String error) {
    return Intl.message(
      'Failed to read accounts data: $error',
      name: 'failedToReadAccountsData',
      desc: 'Error message when reading accounts data fails.',
      args: [error],
    );
  }

  /// `SharedPreferences is not initialized.`
  String get sharedPreferencesNotInitialized {
    return Intl.message(
      'SharedPreferences is not initialized.',
      name: 'sharedPreferencesNotInitialized',
      desc:
          'Error message when SharedPreferences is accessed before initialization.',
      args: [],
    );
  }

  /// `Failed to save sessions.`
  String get failedToSaveSessions {
    return Intl.message(
      'Failed to save sessions.',
      name: 'failedToSaveSessions',
      desc: 'Error message when saving sessions fails.',
      args: [],
    );
  }

  /// `Failed to retrieve sessions.`
  String get failedToRetrieveSessions {
    return Intl.message(
      'Failed to retrieve sessions.',
      name: 'failedToRetrieveSessions',
      desc: 'Error message when retrieving sessions fails.',
      args: [],
    );
  }

  /// `Failed to remove sessions.`
  String get failedToRemoveSessions {
    return Intl.message(
      'Failed to remove sessions.',
      name: 'failedToRemoveSessions',
      desc: 'Error message when removing all sessions fails.',
      args: [],
    );
  }

  /// `Failed to create watch account: {error}`
  String failedToCreateWatchAccount(String error) {
    return Intl.message(
      'Failed to create watch account: $error',
      name: 'failedToCreateWatchAccount',
      desc: 'Error message when creating a watch account fails.',
      args: [error],
    );
  }

  /// `Account already added.`
  String get accountAlreadyAdded {
    return Intl.message(
      'Account already added.',
      name: 'accountAlreadyAdded',
      desc: 'Error message when attempting to add an already existing account.',
      args: [],
    );
  }

  /// `Seed phrase is not available.`
  String get seedPhraseNotAvailable {
    return Intl.message(
      'Seed phrase is not available.',
      name: 'seedPhraseNotAvailable',
      desc:
          'Error message when attempting to access a seed phrase that is not available.',
      args: [],
    );
  }

  /// `Something went wrong.`
  String get somethingWentWrong {
    return Intl.message(
      'Something went wrong.',
      name: 'somethingWentWrong',
      desc: 'A generic error message.',
      args: [],
    );
  }

  /// `Account name not found for accountId: {accountId}`
  String accountNameNotFoundForId(String accountId) {
    return Intl.message(
      'Account name not found for accountId: $accountId',
      name: 'accountNameNotFoundForId',
      desc:
          'Error message when the account name for a specific account ID is not found.',
      args: [accountId],
    );
  }

  /// `Failed to select account: {error}`
  String failedToSelectAccount(String error) {
    return Intl.message(
      'Failed to select account: $error',
      name: 'failedToSelectAccount',
      desc: 'Error message when the app fails to select an account.',
      args: [error],
    );
  }

  /// `Failed to complete account setup: {error}`
  String failedToCompleteAccountSetup(String error) {
    return Intl.message(
      'Failed to complete account setup: $error',
      name: 'failedToCompleteAccountSetup',
      desc: 'Error message when account setup fails to complete.',
      args: [error],
    );
  }

  /// `Icon must be either IconData or a String path to SVG.`
  String get invalidIconType {
    return Intl.message(
      'Icon must be either IconData or a String path to SVG.',
      name: 'invalidIconType',
      desc: 'Error message when an invalid icon type is provided.',
      args: [],
    );
  }

  /// `Reset app failed: {error}`
  String resetAppFailed(String error) {
    return Intl.message(
      'Reset app failed: $error',
      name: 'resetAppFailed',
      desc: 'Error message when the app reset process fails.',
      args: [error],
    );
  }

  /// `Failed to disconnect WalletConnect sessions: {error}`
  String failedToDisconnectWalletConnectSessions(String error) {
    return Intl.message(
      'Failed to disconnect WalletConnect sessions: $error',
      name: 'failedToDisconnectWalletConnectSessions',
      desc: 'Error message when disconnecting WalletConnect sessions fails.',
      args: [error],
    );
  }

  /// `Failed to clear storage: {error}`
  String failedToClearStorage(String error) {
    return Intl.message(
      'Failed to clear storage: $error',
      name: 'failedToClearStorage',
      desc: 'Error message when clearing secure storage fails.',
      args: [error],
    );
  }

  /// `Failed to load ARC200 balances.`
  String get failedToLoadArc200Balances {
    return Intl.message(
      'Failed to load ARC200 balances.',
      name: 'failedToLoadArc200Balances',
      desc: 'Error message when loading ARC200 balances fails.',
      args: [],
    );
  }

  /// `No ARC200 token details available for the selected network.`
  String get noArc200TokenDetailsForNetwork {
    return Intl.message(
      'No ARC200 token details available for the selected network.',
      name: 'noArc200TokenDetailsForNetwork',
      desc:
          'Error message when ARC200 token details are unavailable for the selected network.',
      args: [],
    );
  }

  /// `Failed to load ARC200 token details.`
  String get failedToLoadArc200TokenDetails {
    return Intl.message(
      'Failed to load ARC200 token details.',
      name: 'failedToLoadArc200TokenDetails',
      desc: 'Error message when loading ARC200 token details fails.',
      args: [],
    );
  }

  /// `Token details not found for contractId {contractId}.`
  String tokenDetailsNotFound(String contractId) {
    return Intl.message(
      'Token details not found for contractId $contractId.',
      name: 'tokenDetailsNotFound',
      desc:
          'Error message when token details for a specific contract ID are not found.',
      args: [contractId],
    );
  }

  /// `Failed to search ARC200 assets.`
  String get failedToSearchArc200Assets {
    return Intl.message(
      'Failed to search ARC200 assets.',
      name: 'failedToSearchArc200Assets',
      desc: 'Error message when searching for ARC200 assets fails.',
      args: [],
    );
  }

  /// `Network not configured for ARC200 operations.`
  String get networkNotConfiguredForArc200 {
    return Intl.message(
      'Network not configured for ARC200 operations.',
      name: 'networkNotConfiguredForArc200',
      desc:
          'Error message when the selected network is not configured for ARC200 operations.',
      args: [],
    );
  }

  /// `Failed to fetch ARC200 balance for contract {contractId}.`
  String failedToFetchArc200Balance(String contractId) {
    return Intl.message(
      'Failed to fetch ARC200 balance for contract $contractId.',
      name: 'failedToFetchArc200Balance',
      desc:
          'Error message when fetching the ARC200 balance for a specific contract fails.',
      args: [contractId],
    );
  }

  /// `Asset not found for contract {contractId}.`
  String assetNotFoundForContract(String contractId) {
    return Intl.message(
      'Asset not found for contract $contractId.',
      name: 'assetNotFoundForContract',
      desc:
          'Error message when an asset for a specific contract ID is not found.',
      args: [contractId],
    );
  }

  /// `Copied to clipboard`
  String get copiedToClipboard {
    return Intl.message(
      'Copied to clipboard',
      name: 'copiedToClipboard',
      desc:
          'Message displayed when an item is successfully copied to the clipboard.',
      args: [],
    );
  }

  /// `Unsupported encoding or invalid string format.`
  String get unsupportedEncodingOrInvalidFormat {
    return Intl.message(
      'Unsupported encoding or invalid string format.',
      name: 'unsupportedEncodingOrInvalidFormat',
      desc:
          'Error message when the input string has an unsupported encoding or an invalid format.',
      args: [],
    );
  }

  /// `Private key is missing in the URI.`
  String get privateKeyMissingInUri {
    return Intl.message(
      'Private key is missing in the URI.',
      name: 'privateKeyMissingInUri',
      desc: 'Error message when a private key is missing from a URI input.',
      args: [],
    );
  }

  /// `Unsupported encoding in the URI.`
  String get unsupportedEncodingInUri {
    return Intl.message(
      'Unsupported encoding in the URI.',
      name: 'unsupportedEncodingInUri',
      desc: 'Error message when an unsupported encoding is specified in a URI.',
      args: [],
    );
  }

  /// `Invalid hex string length.`
  String get invalidHexStringLength {
    return Intl.message(
      'Invalid hex string length.',
      name: 'invalidHexStringLength',
      desc: 'Error message when a hex string has an invalid length.',
      args: [],
    );
  }

  /// `Invalid Base64 string.`
  String get invalidBase64String {
    return Intl.message(
      'Invalid Base64 string.',
      name: 'invalidBase64String',
      desc: 'Error message when a Base64 string is invalid.',
      args: [],
    );
  }

  /// `Invalid Base32 string.`
  String get invalidBase32String {
    return Intl.message(
      'Invalid Base32 string.',
      name: 'invalidBase32String',
      desc: 'Error message when a Base32 string is invalid.',
      args: [],
    );
  }

  /// `Here is my QR Code!`
  String get hereIsMyQRCode {
    return Intl.message(
      'Here is my QR Code!',
      name: 'hereIsMyQRCode',
      desc: 'Text accompanying the shared QR code.',
      args: [],
    );
  }

  /// `Failed to approve session.`
  String get failedToApproveSession {
    return Intl.message(
      'Failed to approve session.',
      name: 'failedToApproveSession',
      desc: 'Error message when approving a WalletConnect session fails.',
      args: [],
    );
  }

  /// `Failed to disconnect session.`
  String get failedToDisconnectSession {
    return Intl.message(
      'Failed to disconnect session.',
      name: 'failedToDisconnectSession',
      desc: 'Error message when disconnecting a WalletConnect session fails.',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: 'Label for the language selection dropdown.',
      args: [],
    );
  }

  /// `View Seed Phrase`
  String get viewSeedPhrase {
    return Intl.message(
      'View Seed Phrase',
      name: 'viewSeedPhrase',
      desc: 'Label for the button or screen title to view the seed phrase.',
      args: [],
    );
  }

  /// `Floating Button Position`
  String get fabPosition {
    return Intl.message(
      'Floating Button Position',
      name: 'fabPosition',
      desc:
          'Label for the setting to choose the position of the floating action button.',
      args: [],
    );
  }

  /// `Left`
  String get fabLeft {
    return Intl.message(
      'Left',
      name: 'fabLeft',
      desc: 'Option for positioning the floating button on the left.',
      args: [],
    );
  }

  /// `Right`
  String get fabRight {
    return Intl.message(
      'Right',
      name: 'fabRight',
      desc: 'Option for positioning the floating button on the right.',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'es'),
      Locale.fromSubtags(languageCode: 'th'),
      Locale.fromSubtags(languageCode: 'tr'),
      Locale.fromSubtags(languageCode: 'vi'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
