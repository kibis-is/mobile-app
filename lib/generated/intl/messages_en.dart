// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(activeAccountId) =>
      "Account name not found for activeAccountId: ${activeAccountId}";

  static String m1(accountId) =>
      "Account name not found for accountId: ${accountId}";

  static String m2(publicKey) => "All sessions for ${publicKey}";

  static String m3(error) => "Failed to fetch asset details: ${error}";

  static String m4(contractId) => "Asset not found for contract ${contractId}.";

  static String m5(error) => "Failed to opt-in to asset: ${error}";

  static String m6(error) => "Failed to call contract: ${error}";

  static String m7(error) => "Failed to opt-in to contract: ${error}";

  static String m8(contactName) =>
      "Are you sure you want to delete ${contactName}?";

  static String m9(index) => "Enter word ${index}";

  static String m10(error) => "Error: ${error}";

  static String m11(error) => "Failed to clear storage: ${error}";

  static String m12(error) => "Failed to complete account setup: ${error}";

  static String m13(error) => "Failed to create account: ${error}";

  static String m14(error) => "Failed to create account name: ${error}";

  static String m15(error) =>
      "Failed to create unsigned transfer transactions: ${error}";

  static String m16(error) => "Failed to create watch account: ${error}";

  static String m17(error) => "Failed to decode private key: ${error}";

  static String m18(error) => "Failed to delete account: ${error}";

  static String m19(error) => "Failed to destroy asset: ${error}";

  static String m20(sessionName) =>
      "Failed to disconnect ${sessionName}. Please try again.";

  static String m21(error) =>
      "Failed to disconnect WalletConnect sessions: ${error}";

  static String m22(error) => "Failed to edit asset: ${error}";

  static String m23(contractId) =>
      "Failed to fetch ARC200 balance for contract ${contractId}.";

  static String m24(error) => "Failed to fetch assets: ${error}";

  static String m25(error) => "Failed to fetch transactions: ${error}";

  static String m26(error) => "Failed to finalize account creation: ${error}";

  static String m27(error) => "Failed to get account balance: ${error}";

  static String m28(error) => "Failed to initialize account: ${error}";

  static String m29(statusCode) =>
      "Failed to load NFTs with status code: ${statusCode}";

  static String m30(error) => "Failed to opt-in to ASA: ${error}";

  static String m31(error) => "Failed to parse WalletConnect URI: ${error}";

  static String m32(error) => "Failed to read accounts data: ${error}";

  static String m33(error) => "Failed to restore account: ${error}";

  static String m34(error) => "Failed to revoke asset: ${error}";

  static String m35(error) => "Failed to save contact: ${error}";

  static String m36(error) => "Failed to select account: ${error}";

  static String m37(error) => "Failed to send payment: ${error}";

  static String m38(error) => "Failed to set PIN: ${error}";

  static String m39(action, error) => "Failed to ${action} asset: ${error}";

  static String m40(error) => "Failed to transfer asset: ${error}";

  static String m41(error) => "Failed to fetch assets: ${error}";

  static String m42(counter) => "Imported Account ${counter}";

  static String m43(expected, found) =>
      "Byte string must be ${expected} bytes long for a valid address, found \"${found}\" length.";

  static String m44(value) =>
      "The supplied value \"${value}\" is not a valid address.";

  static String m45(key) => "Key is neither valid Base64 nor valid Hex: ${key}";

  static String m46(balance, minimumBalance) =>
      "The maximum VOI amount is calculated by: the balance (${balance}), minus the minimum balance needed to keep the account open (${minimumBalance}), minus the minimum transaction fee (0.001)";

  static String m47(balance) =>
      "Minimum balance is ${balance} VOI. Based on the account configuration, this is the minimum balance needed to keep the account open.";

  static String m48(networkName) => "Network changed to ${networkName}";

  static String m49(networkName) => "Failed to switch to ${networkName}";

  static String m50(networkName) => "Switched to ${networkName}";

  static String m51(networkName) => "Network switched to ${networkName}";

  static String m52(partNumber) => "Part ${partNumber}";

  static String m53(accountId) =>
      "Private key not found for account ID: ${accountId}";

  static String m54(error) => "Reset app failed: ${error}";

  static String m55(sessionName) => "${sessionName} disconnected successfully.";

  static String m56(contractId) =>
      "Token details not found for contractId ${contractId}.";

  static String m57(error) => "Transaction error: ${error}";

  static String m58(maxSize) =>
      "Transaction group size exceeds the maximum size of \"${maxSize}\"";

  static String m59(assetType) => "Unsupported asset type: ${assetType}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("About"),
        "account": MessageLookupByLibrary.simpleMessage("Account"),
        "accountAlreadyAdded":
            MessageLookupByLibrary.simpleMessage("Account already added."),
        "accountCannotBeExported": MessageLookupByLibrary.simpleMessage(
            "This account cannot be exported, as it has no private key."),
        "accountIdOrAddressNotAvailable": MessageLookupByLibrary.simpleMessage(
            "Account ID or Public Address is not available"),
        "accountMissingInTemporaryData": MessageLookupByLibrary.simpleMessage(
            "Account is missing in temporary account data."),
        "accountName": MessageLookupByLibrary.simpleMessage("Account Name"),
        "accountNameIsTooLong":
            MessageLookupByLibrary.simpleMessage("Account name is too long."),
        "accountNameNotFound": m0,
        "accountNameNotFoundForId": m1,
        "accountNotFound":
            MessageLookupByLibrary.simpleMessage("Account not found."),
        "accountNotFundedPleaseFundToSeeDetails":
            MessageLookupByLibrary.simpleMessage(
                "This account has not been funded yet. Please fund it to see details."),
        "activeAssetNullError":
            MessageLookupByLibrary.simpleMessage("Active asset is null"),
        "activityTab": MessageLookupByLibrary.simpleMessage("Activity"),
        "addAccountTitle": MessageLookupByLibrary.simpleMessage("Add Account"),
        "addAsset": MessageLookupByLibrary.simpleMessage("Add Asset"),
        "addAssetTitle": MessageLookupByLibrary.simpleMessage("Add Asset"),
        "addWatch": MessageLookupByLibrary.simpleMessage("Add Watch"),
        "addWatchSubtitle": MessageLookupByLibrary.simpleMessage(
            "Add watch account to watch via public address."),
        "addressType": MessageLookupByLibrary.simpleMessage("address"),
        "advanced": MessageLookupByLibrary.simpleMessage("Advanced"),
        "algorandServiceError": MessageLookupByLibrary.simpleMessage(
            "An error occurred with Algorand service"),
        "algorandStandardAsset":
            MessageLookupByLibrary.simpleMessage("Algorand Standard Asset"),
        "allAccounts": MessageLookupByLibrary.simpleMessage("All Accounts"),
        "allSessions": MessageLookupByLibrary.simpleMessage("All sessions"),
        "allSessionsFor": m2,
        "allowTestNetworks":
            MessageLookupByLibrary.simpleMessage("Allow Test Networks"),
        "almostThere": MessageLookupByLibrary.simpleMessage("Almost there"),
        "alreadyAdded": MessageLookupByLibrary.simpleMessage("Already\nadded"),
        "amount": MessageLookupByLibrary.simpleMessage("Amount"),
        "appearance": MessageLookupByLibrary.simpleMessage("Appearance"),
        "applicationId": MessageLookupByLibrary.simpleMessage("Application ID"),
        "arc0200AssetTransferSuccessful": MessageLookupByLibrary.simpleMessage(
            "ARC-0200 Asset transfer successful."),
        "arc200AssetFetchFailed": MessageLookupByLibrary.simpleMessage(
            "Failed to fetch ARC-0200 asset details"),
        "asset": MessageLookupByLibrary.simpleMessage("Asset"),
        "assetDestructionConfirmationFailed":
            MessageLookupByLibrary.simpleMessage(
                "Asset destruction confirmation failed."),
        "assetDetailsFetchFailed": m3,
        "assetEditConfirmationFailed": MessageLookupByLibrary.simpleMessage(
            "Asset edit confirmation failed."),
        "assetIdInvalidFormat": MessageLookupByLibrary.simpleMessage(
            "Invalid asset ID format. Asset ID must be a valid integer."),
        "assetIsFrozen":
            MessageLookupByLibrary.simpleMessage("Asset is frozen."),
        "assetNameOrUnitMissing": MessageLookupByLibrary.simpleMessage(
            "Asset name or unit name is missing."),
        "assetNotFoundForContract": m4,
        "assetOptInConfirmationFailed": MessageLookupByLibrary.simpleMessage(
            "Asset opt-in confirmation failed."),
        "assetOptInFailed": m5,
        "assetOptInSuccess":
            MessageLookupByLibrary.simpleMessage("Asset successfully opted in"),
        "assetTransfer": MessageLookupByLibrary.simpleMessage("Asset Transfer"),
        "assetTransferConfirmationFailed": MessageLookupByLibrary.simpleMessage(
            "Asset transfer confirmation failed."),
        "assetsTab": MessageLookupByLibrary.simpleMessage("Assets"),
        "authenticating":
            MessageLookupByLibrary.simpleMessage("Authenticating"),
        "back": MessageLookupByLibrary.simpleMessage("Back"),
        "backupConfirmationPrompt": MessageLookupByLibrary.simpleMessage(
            "Please confirm you have stored a backup of your seed phrase in a secure location."),
        "backupConfirmationRequired": MessageLookupByLibrary.simpleMessage(
            "You must confirm you have made a backup of your seed phrase."),
        "build": MessageLookupByLibrary.simpleMessage("Build:"),
        "buildNumber": MessageLookupByLibrary.simpleMessage("Build Number:"),
        "calculating": MessageLookupByLibrary.simpleMessage("Calculating..."),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "cancelButton": MessageLookupByLibrary.simpleMessage("Cancel"),
        "changePin": MessageLookupByLibrary.simpleMessage("Change Pin"),
        "checksumMismatch": MessageLookupByLibrary.simpleMessage(
            "Checksum does not match. The scanned QR codes are not from the same set."),
        "clearFilter": MessageLookupByLibrary.simpleMessage("Clear Filter"),
        "close": MessageLookupByLibrary.simpleMessage("Close"),
        "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
        "confirmDeleteAccount": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete this account?"),
        "confirmPin": MessageLookupByLibrary.simpleMessage("Confirm Pin"),
        "confirmReset": MessageLookupByLibrary.simpleMessage("Confirm Reset"),
        "connectTitle": MessageLookupByLibrary.simpleMessage("Connect"),
        "connectToTitle": MessageLookupByLibrary.simpleMessage("Connect to:"),
        "contactNameOptional":
            MessageLookupByLibrary.simpleMessage("Contact Name (Optional)"),
        "contactNameUpdatedSuccessfully": MessageLookupByLibrary.simpleMessage(
            "Contact name updated successfully."),
        "contactNotFound":
            MessageLookupByLibrary.simpleMessage("Contact not found."),
        "contactSavedSuccessfully":
            MessageLookupByLibrary.simpleMessage("Contact saved successfully."),
        "contactsTab": MessageLookupByLibrary.simpleMessage("Contacts"),
        "contractCallFailed": m6,
        "contractOptInFailed": m7,
        "copiedToClipboard":
            MessageLookupByLibrary.simpleMessage("Copied to clipboard"),
        "copyAddress": MessageLookupByLibrary.simpleMessage("Copy Address"),
        "copySeed": MessageLookupByLibrary.simpleMessage("Copy Seed"),
        "copySeedPhrase":
            MessageLookupByLibrary.simpleMessage("Copy seed phrase"),
        "copyUri": MessageLookupByLibrary.simpleMessage("Copy URI"),
        "create": MessageLookupByLibrary.simpleMessage("Create"),
        "createNewAccount":
            MessageLookupByLibrary.simpleMessage("Create New Account"),
        "createNewAccountSubtitle": MessageLookupByLibrary.simpleMessage(
            "You will be prompted to save a seed."),
        "createPin": MessageLookupByLibrary.simpleMessage("Create Pin"),
        "creatingAccount":
            MessageLookupByLibrary.simpleMessage("Creating Account"),
        "dangerZone": MessageLookupByLibrary.simpleMessage("Danger Zone"),
        "dangerZoneDescription": MessageLookupByLibrary.simpleMessage(
            "This will remove all accounts, settings, and security information."),
        "darkMode": MessageLookupByLibrary.simpleMessage("Dark Mode"),
        "date": MessageLookupByLibrary.simpleMessage("Date"),
        "decimals": MessageLookupByLibrary.simpleMessage("Decimals"),
        "defaultConfirmationContent": MessageLookupByLibrary.simpleMessage(
            "Do you want to proceed with this action?"),
        "defaultConfirmationTitle":
            MessageLookupByLibrary.simpleMessage("Are you sure?"),
        "defaultErrorMessage": MessageLookupByLibrary.simpleMessage(
            "There was an error. No further details provided."),
        "delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "deleteContactMessage": m8,
        "deleteContactTitle":
            MessageLookupByLibrary.simpleMessage("Delete Contact"),
        "disconnect": MessageLookupByLibrary.simpleMessage("Disconnect"),
        "disconnectAll": MessageLookupByLibrary.simpleMessage("Disconnect All"),
        "disconnectAllSessions":
            MessageLookupByLibrary.simpleMessage("Disconnect All Sessions?"),
        "disconnectAllSessionsForAccountPrompt":
            MessageLookupByLibrary.simpleMessage(
                "Disconnect all sessions for this account?"),
        "disconnectAllSessionsPrompt":
            MessageLookupByLibrary.simpleMessage("Disconnect all sessions?"),
        "downloadQrImage":
            MessageLookupByLibrary.simpleMessage("Download QR Image"),
        "editAccount": MessageLookupByLibrary.simpleMessage("Edit"),
        "editAccountDescription": MessageLookupByLibrary.simpleMessage(
            "You can change your account name below."),
        "editAccountNamePrompt":
            MessageLookupByLibrary.simpleMessage("Edit your account name"),
        "enablePasswordLock":
            MessageLookupByLibrary.simpleMessage("Enable Password Lock"),
        "enterSeedPhrasePrompt": MessageLookupByLibrary.simpleMessage(
            "Enter your seed phrase to import your account."),
        "enterWord": m9,
        "error": MessageLookupByLibrary.simpleMessage("Error"),
        "errorLoadingAccounts":
            MessageLookupByLibrary.simpleMessage("Error loading accounts"),
        "errorLoadingAssets":
            MessageLookupByLibrary.simpleMessage("Error loading assets"),
        "errorLoadingTransactions":
            MessageLookupByLibrary.simpleMessage("Error loading transactions"),
        "errorMessage": m10,
        "errorProcessingPublicKey":
            MessageLookupByLibrary.simpleMessage("Error processing public key"),
        "errorReadingPinHash":
            MessageLookupByLibrary.simpleMessage("Error reading pin hash."),
        "errorTitle": MessageLookupByLibrary.simpleMessage("Error"),
        "expectedPrivateKeyButPublic": MessageLookupByLibrary.simpleMessage(
            "Expected a private key QR code but found a public key."),
        "expectedPrivateKeyButWalletConnect":
            MessageLookupByLibrary.simpleMessage(
                "Expected a private key QR code but found a WalletConnect URI."),
        "expectedPrivateKeyQr": MessageLookupByLibrary.simpleMessage(
            "Expected a private key QR code but found a public key."),
        "expectedPublicKey": MessageLookupByLibrary.simpleMessage(
            "Expected a public key QR code but found something else."),
        "expectedPublicKeyQr": MessageLookupByLibrary.simpleMessage(
            "Expected a public key QR code but found something else."),
        "expectedWalletConnectSessionQr": MessageLookupByLibrary.simpleMessage(
            "Expected a WalletConnect session QR code but found something else."),
        "expectedWalletConnectUri": MessageLookupByLibrary.simpleMessage(
            "Expected a private key QR code but found a WalletConnect URI."),
        "expires": MessageLookupByLibrary.simpleMessage("Expires:"),
        "exportAccounts":
            MessageLookupByLibrary.simpleMessage("Export Accounts"),
        "failedFinalizeAccountImport": MessageLookupByLibrary.simpleMessage(
            "Failed to finalize account import."),
        "failedParseWalletConnectUri": MessageLookupByLibrary.simpleMessage(
            "Failed to parse WalletConnect URI"),
        "failedToApproveSession":
            MessageLookupByLibrary.simpleMessage("Failed to approve session."),
        "failedToClearStorage": m11,
        "failedToCompleteAccountSetup": m12,
        "failedToCreateAccount": m13,
        "failedToCreateAccountName": m14,
        "failedToCreateUnsignedTransactions": m15,
        "failedToCreateWatchAccount": m16,
        "failedToDecodePrivateKey": m17,
        "failedToDeleteAccount": m18,
        "failedToDestroyAsset": m19,
        "failedToDisconnect": m20,
        "failedToDisconnectSession": MessageLookupByLibrary.simpleMessage(
            "Failed to disconnect session."),
        "failedToDisconnectWalletConnectSessions": m21,
        "failedToEditAsset": m22,
        "failedToFetchArc200Balance": m23,
        "failedToFetchAssets": m24,
        "failedToFetchTransactions": m25,
        "failedToFinalizeAccountCreation": m26,
        "failedToFollowArc200Asset": MessageLookupByLibrary.simpleMessage(
            "Failed to follow ARC-0200 asset."),
        "failedToGetAccountBalance": m27,
        "failedToInitializeAccount": m28,
        "failedToLoad": MessageLookupByLibrary.simpleMessage("Failed to load"),
        "failedToLoadArc200Balances": MessageLookupByLibrary.simpleMessage(
            "Failed to load ARC200 balances."),
        "failedToLoadArc200TokenDetails": MessageLookupByLibrary.simpleMessage(
            "Failed to load ARC200 token details."),
        "failedToLoadNFTs": m29,
        "failedToOptInAsset":
            MessageLookupByLibrary.simpleMessage("Failed to opt-in to asset."),
        "failedToOptInError":
            MessageLookupByLibrary.simpleMessage("Failed to opt-in to asset"),
        "failedToOptInToASA": m30,
        "failedToParseWalletConnectUri": m31,
        "failedToReadAccountsData": m32,
        "failedToRemoveSessions":
            MessageLookupByLibrary.simpleMessage("Failed to remove sessions."),
        "failedToRestoreAccount": m33,
        "failedToRetrieveSessions": MessageLookupByLibrary.simpleMessage(
            "Failed to retrieve sessions."),
        "failedToRevokeAsset": m34,
        "failedToSaveContact": m35,
        "failedToSaveSessions":
            MessageLookupByLibrary.simpleMessage("Failed to save sessions."),
        "failedToSearchArc200Assets": MessageLookupByLibrary.simpleMessage(
            "Failed to search ARC200 assets."),
        "failedToSelectAccount": m36,
        "failedToSendPayment": m37,
        "failedToSetPin": m38,
        "failedToToggleFreeze": m39,
        "failedToTransferAsset": m40,
        "fee": MessageLookupByLibrary.simpleMessage("Fee"),
        "filter": MessageLookupByLibrary.simpleMessage("Filter"),
        "fromField": MessageLookupByLibrary.simpleMessage("From"),
        "fundAccountError": MessageLookupByLibrary.simpleMessage(
            "Please fund your account to proceed."),
        "general": MessageLookupByLibrary.simpleMessage("General"),
        "generateSeedPhrase":
            MessageLookupByLibrary.simpleMessage("Generate seed phrase"),
        "genericError": MessageLookupByLibrary.simpleMessage("Error"),
        "genericErrorMessage":
            MessageLookupByLibrary.simpleMessage("Sorry, there was an error."),
        "getAccountAssetsFailed": m41,
        "hangInThere": MessageLookupByLibrary.simpleMessage("Hang in there"),
        "hereIsMyQRCode":
            MessageLookupByLibrary.simpleMessage("Here is my QR Code!"),
        "import": MessageLookupByLibrary.simpleMessage("Import"),
        "importAccountTitle":
            MessageLookupByLibrary.simpleMessage("Import Account"),
        "importPrivateKey":
            MessageLookupByLibrary.simpleMessage("Import Private Key"),
        "importPublicAddress":
            MessageLookupByLibrary.simpleMessage("Import Public Address"),
        "importSeed": MessageLookupByLibrary.simpleMessage("Import Seed"),
        "importViaPrivateKey":
            MessageLookupByLibrary.simpleMessage("Import via Private Key"),
        "importViaPrivateKeySubtitle": MessageLookupByLibrary.simpleMessage(
            "Import accounts from a private key."),
        "importViaQrCode":
            MessageLookupByLibrary.simpleMessage("Import Via QR Code"),
        "importViaQrCodeSubtitle": MessageLookupByLibrary.simpleMessage(
            "Scan a QR code to import an existing account."),
        "importViaSeed":
            MessageLookupByLibrary.simpleMessage("Import Via Seed"),
        "importViaSeedSubtitle": MessageLookupByLibrary.simpleMessage(
            "Import an existing account via seed phrase."),
        "importedAccount":
            MessageLookupByLibrary.simpleMessage("Imported Account"),
        "importedAccountWithCounter": m42,
        "incompleteTemporaryAccountData": MessageLookupByLibrary.simpleMessage(
            "Incomplete temporary account data for regular account."),
        "incorrectPin": MessageLookupByLibrary.simpleMessage("Incorrect PIN"),
        "incorrectPinError":
            MessageLookupByLibrary.simpleMessage("Incorrect PIN. Try again."),
        "info": MessageLookupByLibrary.simpleMessage("Info"),
        "infoHeader": MessageLookupByLibrary.simpleMessage("Info"),
        "initializationError": MessageLookupByLibrary.simpleMessage(
            "Initialization error, please restart the app."),
        "initializing": MessageLookupByLibrary.simpleMessage("Init"),
        "insufficientBalance":
            MessageLookupByLibrary.simpleMessage("Insufficient balance."),
        "insufficientFunds":
            MessageLookupByLibrary.simpleMessage("Insufficient funds"),
        "insufficientFundsError":
            MessageLookupByLibrary.simpleMessage("Insufficient funds."),
        "invalidAddressByteLength": m43,
        "invalidAddressSupplied": m44,
        "invalidAlgorandAddress":
            MessageLookupByLibrary.simpleMessage("Invalid Algorand address."),
        "invalidBase32String":
            MessageLookupByLibrary.simpleMessage("Invalid Base32 string."),
        "invalidBase64String":
            MessageLookupByLibrary.simpleMessage("Invalid Base64 string."),
        "invalidEncodedKeyLength": MessageLookupByLibrary.simpleMessage(
            "The encoded key should be 44 characters long."),
        "invalidHexStringLength":
            MessageLookupByLibrary.simpleMessage("Invalid hex string length."),
        "invalidIconType": MessageLookupByLibrary.simpleMessage(
            "Icon must be either IconData or a String path to SVG."),
        "invalidPageFormat": MessageLookupByLibrary.simpleMessage(
            "Invalid page format in paginated URI"),
        "invalidPageFormatInUri": MessageLookupByLibrary.simpleMessage(
            "Invalid page format in paginated URI"),
        "invalidPinTryAgain":
            MessageLookupByLibrary.simpleMessage("Invalid PIN. Try again."),
        "invalidPrivateKey":
            MessageLookupByLibrary.simpleMessage("Invalid private key"),
        "invalidPrivateKeyLength":
            MessageLookupByLibrary.simpleMessage("Invalid private key length."),
        "invalidPublicKeyFormat":
            MessageLookupByLibrary.simpleMessage("Invalid Public Key Format"),
        "invalidQrCodeData":
            MessageLookupByLibrary.simpleMessage("Invalid QR code data"),
        "invalidScanResult":
            MessageLookupByLibrary.simpleMessage("Invalid scan result"),
        "invalidUriFormat":
            MessageLookupByLibrary.simpleMessage("Invalid URI format"),
        "invalidWalletConnectUri": MessageLookupByLibrary.simpleMessage(
            "Invalid WalletConnect URI format."),
        "justABitMore": MessageLookupByLibrary.simpleMessage("Just a bit more"),
        "keyNeitherBase64NorHex": m45,
        "language": MessageLookupByLibrary.simpleMessage("Language"),
        "loading": MessageLookupByLibrary.simpleMessage("Loading..."),
        "loadingAccount":
            MessageLookupByLibrary.simpleMessage("Loading Account"),
        "max": MessageLookupByLibrary.simpleMessage("Max"),
        "maxVoiAmountCalculation": m46,
        "minimumBalanceInfo": m47,
        "missingPrivateKeyInLegacyUri": MessageLookupByLibrary.simpleMessage(
            "Missing private key in legacy URI"),
        "missingPrivateKeyLegacy": MessageLookupByLibrary.simpleMessage(
            "Missing privatekey in legacy URI"),
        "myAccountsTab": MessageLookupByLibrary.simpleMessage("My Accounts"),
        "nameAccount": MessageLookupByLibrary.simpleMessage("Name Account"),
        "nameAccountDescription": MessageLookupByLibrary.simpleMessage(
            "Give your account a nickname. Don’t worry, you can change this later."),
        "nameAccountPrompt":
            MessageLookupByLibrary.simpleMessage("Name your account"),
        "nearlyDone": MessageLookupByLibrary.simpleMessage("Nearly done"),
        "networkChangedTo": m48,
        "networkNotConfiguredForArc200": MessageLookupByLibrary.simpleMessage(
            "Network not configured for ARC200 operations."),
        "networkSwitchFailure": m49,
        "networkSwitchSuccess": m50,
        "networkSwitched": m51,
        "next": MessageLookupByLibrary.simpleMessage("Next"),
        "nextQrCode": MessageLookupByLibrary.simpleMessage("Next QR:"),
        "nftViewerTitle": MessageLookupByLibrary.simpleMessage("NFT Viewer"),
        "nftsTab": MessageLookupByLibrary.simpleMessage("NFTs"),
        "no": MessageLookupByLibrary.simpleMessage("No"),
        "noAccount": MessageLookupByLibrary.simpleMessage("No account"),
        "noAccountName":
            MessageLookupByLibrary.simpleMessage("No Account Name"),
        "noAccountsAvailableToConnect": MessageLookupByLibrary.simpleMessage(
            "No accounts available to connect."),
        "noAccountsForExport": MessageLookupByLibrary.simpleMessage(
            "No accounts available for export."),
        "noAccountsFound":
            MessageLookupByLibrary.simpleMessage("No accounts found"),
        "noActiveAccount":
            MessageLookupByLibrary.simpleMessage("No active account."),
        "noActiveAccountFound":
            MessageLookupByLibrary.simpleMessage("No active account found."),
        "noActiveAccountIdFound":
            MessageLookupByLibrary.simpleMessage("No active account ID found"),
        "noActiveAccountToUpdate": MessageLookupByLibrary.simpleMessage(
            "No active account to update."),
        "noActiveSessions":
            MessageLookupByLibrary.simpleMessage("No active sessions."),
        "noArc200TokenDetailsForNetwork": MessageLookupByLibrary.simpleMessage(
            "No ARC200 token details available for the selected network."),
        "noAssetAvailableMessage": MessageLookupByLibrary.simpleMessage(
            "No asset available to display."),
        "noAssets": MessageLookupByLibrary.simpleMessage("No Assets Found"),
        "noAssetsAdded": MessageLookupByLibrary.simpleMessage(
            "You have not added any assets."),
        "noAssetsForFilter": MessageLookupByLibrary.simpleMessage(
            "No Assets Found for the Filter"),
        "noAssetsFound":
            MessageLookupByLibrary.simpleMessage("No assets found."),
        "noInternetConnection":
            MessageLookupByLibrary.simpleMessage("No Internet Connection"),
        "noItemSelectedForTransaction": MessageLookupByLibrary.simpleMessage(
            "No item selected for the transaction."),
        "noItems": MessageLookupByLibrary.simpleMessage("No Items"),
        "noMoreTransactions":
            MessageLookupByLibrary.simpleMessage("No more transactions."),
        "noNetwork": MessageLookupByLibrary.simpleMessage("No Network"),
        "noNftsAdded": MessageLookupByLibrary.simpleMessage(
            "You have not added any NFTs."),
        "noNftsForFilter": MessageLookupByLibrary.simpleMessage(
            "No NFTs Found for the Filter"),
        "noNftsFound": MessageLookupByLibrary.simpleMessage("No NFTs Found"),
        "noPublicKey": MessageLookupByLibrary.simpleMessage("No Public Key"),
        "noSeedPhraseAvailable":
            MessageLookupByLibrary.simpleMessage("No seed phrase available."),
        "noTransactionAvailable": MessageLookupByLibrary.simpleMessage(
            "No transaction available to display."),
        "noTransactionsFound":
            MessageLookupByLibrary.simpleMessage("No Transactions Found"),
        "noTransactionsMade": MessageLookupByLibrary.simpleMessage(
            "You have not made any transactions."),
        "notAvailable": MessageLookupByLibrary.simpleMessage("N/A"),
        "note": MessageLookupByLibrary.simpleMessage("Note"),
        "noteOptional": MessageLookupByLibrary.simpleMessage("Note (Optional)"),
        "noteTooLarge":
            MessageLookupByLibrary.simpleMessage("Note is too large."),
        "ok": MessageLookupByLibrary.simpleMessage("OK"),
        "optOutAssetContent": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to opt out of this ARC-0200 asset?"),
        "optOutAssetTitle":
            MessageLookupByLibrary.simpleMessage("Opt Out of Asset?"),
        "optOutButton": MessageLookupByLibrary.simpleMessage("Opt Out"),
        "optOutTooltip": MessageLookupByLibrary.simpleMessage("Opt-out"),
        "optingInMessage": MessageLookupByLibrary.simpleMessage("Opting in..."),
        "options": MessageLookupByLibrary.simpleMessage("Options"),
        "paginatedUriMissingInfo": MessageLookupByLibrary.simpleMessage(
            "Paginated URI missing checksum or page information"),
        "partNumber": m52,
        "payment": MessageLookupByLibrary.simpleMessage("Payment"),
        "pinMismatchError":
            MessageLookupByLibrary.simpleMessage("PIN does not match."),
        "pleaseEnterPublicAddress": MessageLookupByLibrary.simpleMessage(
            "Please enter a public address."),
        "pleaseEnterText":
            MessageLookupByLibrary.simpleMessage("Please enter some text"),
        "pleaseEnterValidAlgorandAddress": MessageLookupByLibrary.simpleMessage(
            "Please enter a valid Algorand address"),
        "pleaseEnterValidAmount":
            MessageLookupByLibrary.simpleMessage("Please enter a valid amount"),
        "pleaseWait": MessageLookupByLibrary.simpleMessage("Please wait"),
        "privateKey": MessageLookupByLibrary.simpleMessage("Private Key"),
        "privateKeyMissingInUri": MessageLookupByLibrary.simpleMessage(
            "Private key is missing in the URI."),
        "privateKeyNotFound": MessageLookupByLibrary.simpleMessage(
            "Private key not found for the active account."),
        "privateKeyNotFoundError":
            MessageLookupByLibrary.simpleMessage("Private key not found"),
        "privateKeyNotFoundForAccount": m53,
        "privateKeyNotFoundInStorage": MessageLookupByLibrary.simpleMessage(
            "Private key not found in storage"),
        "processingQrCode":
            MessageLookupByLibrary.simpleMessage("Processing QR Code"),
        "publicAddress": MessageLookupByLibrary.simpleMessage("Public Address"),
        "publicAddressNotAvailable": MessageLookupByLibrary.simpleMessage(
            "Public address is not available."),
        "publicKeyIsMissing":
            MessageLookupByLibrary.simpleMessage("Public key is missing."),
        "publicKeyNotFoundInStorage": MessageLookupByLibrary.simpleMessage(
            "Public key not found in storage."),
        "pullToRefresh":
            MessageLookupByLibrary.simpleMessage("Pull down to refresh"),
        "qrCodeScannerTitle":
            MessageLookupByLibrary.simpleMessage("QR Code Scanner"),
        "receivedTransactionTitle":
            MessageLookupByLibrary.simpleMessage("Received Transaction"),
        "recipientAddress":
            MessageLookupByLibrary.simpleMessage("Recipient Address"),
        "refreshAccount": MessageLookupByLibrary.simpleMessage("Refresh"),
        "refreshing": MessageLookupByLibrary.simpleMessage("Refreshing..."),
        "releaseToRefresh":
            MessageLookupByLibrary.simpleMessage("Release to refresh"),
        "reset": MessageLookupByLibrary.simpleMessage("Reset"),
        "resetAppFailed": m54,
        "resetConfirmationMessage": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to reset this device? This will remove all accounts, settings, and security information."),
        "resettingApp": MessageLookupByLibrary.simpleMessage("Resetting App"),
        "retry": MessageLookupByLibrary.simpleMessage("Retry"),
        "save": MessageLookupByLibrary.simpleMessage("Save"),
        "scanAddressTitle":
            MessageLookupByLibrary.simpleMessage("Scan Address"),
        "scanQrCode": MessageLookupByLibrary.simpleMessage("Scan QR Code"),
        "searchPrompt": MessageLookupByLibrary.simpleMessage(
            "Enter an assetID, name, asset, or symbol ID (for ARC-200)."),
        "searchQueryLabel":
            MessageLookupByLibrary.simpleMessage("Search Query"),
        "searchQueryTooShort":
            MessageLookupByLibrary.simpleMessage("Search query is too short."),
        "security": MessageLookupByLibrary.simpleMessage("Security"),
        "seedPhraseDescription": MessageLookupByLibrary.simpleMessage(
            "Here is your 25 word mnemonic seed phrase. Make sure you save this in a secure place."),
        "seedPhraseNotAvailable": MessageLookupByLibrary.simpleMessage(
            "Seed phrase is not available."),
        "seedPhraseNotFoundInStorage": MessageLookupByLibrary.simpleMessage(
            "Seed phrase not found in storage."),
        "selectAccountTitle":
            MessageLookupByLibrary.simpleMessage("Select Account"),
        "selectAsset": MessageLookupByLibrary.simpleMessage("Select Asset"),
        "selectNetworkHeader":
            MessageLookupByLibrary.simpleMessage("Select Network"),
        "selectTimeout": MessageLookupByLibrary.simpleMessage("Select Timeout"),
        "selectTransactionPrompt": MessageLookupByLibrary.simpleMessage(
            "Select a transaction to view details"),
        "selfTransferTitle":
            MessageLookupByLibrary.simpleMessage("Self Transfer"),
        "send": MessageLookupByLibrary.simpleMessage("Send"),
        "sendAsset": MessageLookupByLibrary.simpleMessage("Send Asset"),
        "sendTransactionTitle":
            MessageLookupByLibrary.simpleMessage("Send Transaction"),
        "sendingAsset": MessageLookupByLibrary.simpleMessage("Sending Asset"),
        "sendingPayment":
            MessageLookupByLibrary.simpleMessage("Sending Payment"),
        "sentTransactionTitle":
            MessageLookupByLibrary.simpleMessage("Sent Transaction"),
        "sessionDisconnected": m55,
        "sessions": MessageLookupByLibrary.simpleMessage("Sessions"),
        "settingNewPin":
            MessageLookupByLibrary.simpleMessage("Setting New PIN"),
        "settingUp": MessageLookupByLibrary.simpleMessage("Setting Up"),
        "settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "shareAddress": MessageLookupByLibrary.simpleMessage("Share Address"),
        "shareQr": MessageLookupByLibrary.simpleMessage("Share QR"),
        "sharedPreferencesNotInitialized": MessageLookupByLibrary.simpleMessage(
            "SharedPreferences is not initialized."),
        "showFrozenAssets":
            MessageLookupByLibrary.simpleMessage("Show Frozen Assets"),
        "somethingWentWrong":
            MessageLookupByLibrary.simpleMessage("Something went wrong."),
        "sortAndFilter":
            MessageLookupByLibrary.simpleMessage("Sort and Filter Assets"),
        "standardAssetTransferSuccessful": MessageLookupByLibrary.simpleMessage(
            "Standard Asset transfer successful."),
        "successfullyConnected":
            MessageLookupByLibrary.simpleMessage("Successfully connected"),
        "thanksForWaiting":
            MessageLookupByLibrary.simpleMessage("Thanks for waiting"),
        "timeout": MessageLookupByLibrary.simpleMessage("Timeout"),
        "timeout10Minutes": MessageLookupByLibrary.simpleMessage("10 minutes"),
        "timeout15Minutes": MessageLookupByLibrary.simpleMessage("15 minutes"),
        "timeout1Minute": MessageLookupByLibrary.simpleMessage("1 minute"),
        "timeout2Minutes": MessageLookupByLibrary.simpleMessage("2 minutes"),
        "timeout5Minutes": MessageLookupByLibrary.simpleMessage("5 minutes"),
        "toField": MessageLookupByLibrary.simpleMessage("To"),
        "toggleTestNetworksDescription": MessageLookupByLibrary.simpleMessage(
            "Toggle to include test networks in the network list."),
        "tokenDetailsNotFound": m56,
        "totalSupply": MessageLookupByLibrary.simpleMessage("Total Supply"),
        "transactionError": m57,
        "transactionFailed":
            MessageLookupByLibrary.simpleMessage("Transaction failed"),
        "transactionFailedToConfirm": MessageLookupByLibrary.simpleMessage(
            "Transaction failed to confirm within the expected rounds."),
        "transactionGroupSizeExceeded": m58,
        "transactionId": MessageLookupByLibrary.simpleMessage("Transaction ID"),
        "transactionIdCopied":
            MessageLookupByLibrary.simpleMessage("Transaction ID Copied"),
        "transactionIdInvalid": MessageLookupByLibrary.simpleMessage(
            "Transaction failed: Transaction ID invalid or marked as \'error\'."),
        "transactionSuccessful":
            MessageLookupByLibrary.simpleMessage("Transaction successful"),
        "transactionType":
            MessageLookupByLibrary.simpleMessage("Transaction Type"),
        "tryClearingFilter": MessageLookupByLibrary.simpleMessage(
            "Try clearing the filter to see all assets."),
        "type": MessageLookupByLibrary.simpleMessage("Type"),
        "unknown": MessageLookupByLibrary.simpleMessage("Unknown"),
        "unknownImportAccountUriFormat": MessageLookupByLibrary.simpleMessage(
            "Unknown import account URI format"),
        "unknownImportUriFormat": MessageLookupByLibrary.simpleMessage(
            "Unknown import account URI format"),
        "unknownQrCodeType":
            MessageLookupByLibrary.simpleMessage("Unknown QR Code type"),
        "unknownWalletConnectVersion": MessageLookupByLibrary.simpleMessage(
            "Unknown WalletConnect version. Unable to pair."),
        "unlock": MessageLookupByLibrary.simpleMessage("Unlock"),
        "unnamedAccount":
            MessageLookupByLibrary.simpleMessage("Unnamed Account"),
        "unnamedAsset": MessageLookupByLibrary.simpleMessage("Unnamed Asset"),
        "unsupportedAccountType":
            MessageLookupByLibrary.simpleMessage("Unsupported account type."),
        "unsupportedAssetType": m59,
        "unsupportedEncodingInUri": MessageLookupByLibrary.simpleMessage(
            "Unsupported encoding in the URI."),
        "unsupportedEncodingOrInvalidFormat":
            MessageLookupByLibrary.simpleMessage(
                "Unsupported encoding or invalid string format."),
        "updatingAccount":
            MessageLookupByLibrary.simpleMessage("Updating Account"),
        "verifyPin": MessageLookupByLibrary.simpleMessage("Verify Pin"),
        "verifying": MessageLookupByLibrary.simpleMessage("Verifying"),
        "version": MessageLookupByLibrary.simpleMessage("Version:"),
        "viewAssetTitle": MessageLookupByLibrary.simpleMessage("View Asset"),
        "viewTransactionTitle":
            MessageLookupByLibrary.simpleMessage("View Transaction"),
        "walletConnectV1NotSupported": MessageLookupByLibrary.simpleMessage(
            "WalletConnect V1 URIs are not supported."),
        "welcomeMessage": MessageLookupByLibrary.simpleMessage(
            "Welcome. First, let’s create a new pincode to secure this device."),
        "welcomeTitle": MessageLookupByLibrary.simpleMessage("Welcome"),
        "yes": MessageLookupByLibrary.simpleMessage("Yes"),
        "youreDoingGreat":
            MessageLookupByLibrary.simpleMessage("You\'re doing great")
      };
}
