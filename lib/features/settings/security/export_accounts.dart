import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/common_widgets/custom_dropdown.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/accounts_list_provider.dart';
import 'package:kibisis/providers/active_account_provider.dart';
import 'package:kibisis/providers/storage_provider.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/copy_to_clipboard.dart';
import 'package:kibisis/utils/save_qr_image.dart';
import 'package:qr_flutter/qr_flutter.dart';

final selectedAccountProvider = StateProvider<String?>((ref) {
  final activeAccountId = ref.read(activeAccountProvider);
  return activeAccountId;
});

final qrDataProvider =
    FutureProvider.autoDispose.family<String, String?>((ref, accountId) async {
  if (accountId == 'all') {
    return await generateAllAccountURIs(ref);
  } else if (accountId != null) {
    return await generateSingleAccountURI(ref, accountId);
  }
  return '';
});

Future<String> generateAllAccountURIs(Ref ref) async {
  await ref.read(accountsListProvider.notifier).loadAccountsWithPrivateKeys();
  final accounts = ref.read(accountsListProvider).accounts;

  final uri = StringBuffer(buildURI(name: '', privateKey: ''));
  for (var account in accounts) {
    uri.write(buildURIParams(account['accountName'] ?? 'Unnamed Account',
        account['privateKey'] ?? '0'));
  }
  final uriString = uri.toString();
  debugPrint(uriString);
  return uriString;
}

Future<String> generateSingleAccountURI(Ref ref, String accountId) async {
  final storageService = ref.read(storageProvider);
  final accountName =
      await storageService.getAccountData(accountId, 'accountName') ??
          'Unnamed Account';
  final privateKey =
      await storageService.getPrivateKey(accountId) ?? 'No Private Key';
  return buildURI(name: accountName, privateKey: privateKey);
}

String buildURI(
    {String base = 'avm://account/import?',
    required String name,
    required String privateKey}) {
  return '$base${buildURIParams(name, privateKey)}';
}

String buildURIParams(String name, String privateKey) {
  return 'name=${Uri.encodeComponent(name)}&privatekey=$privateKey';
}

class ExportAccountsScreen extends ConsumerWidget {
  static const String title = 'Export';
  final GlobalKey qrKey = GlobalKey();

  ExportAccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts =
        ref.watch(accountsListProvider.select((value) => value.accounts));
    final selectedAccountId = ref.watch(selectedAccountProvider) ?? '0';
    final qrDataAsyncValue = ref.watch(qrDataProvider(selectedAccountId));

    // Prepare dropdown items as a list of SelectItem
    List<SelectItem> dropdownItems = accounts
        .map((account) => SelectItem(
              name: account['accountName'] ?? 'Unnamed Account',
              value: account['accountId'] ?? '0',
              icon: AppIcons.wallet,
            ))
        .toList();

    // Add the 'All Accounts' item
    dropdownItems.insert(dropdownItems.length,
        SelectItem(name: 'All Accounts', value: 'all', icon: AppIcons.group));

    return Scaffold(
      appBar: AppBar(
        title: const Text(ExportAccountsScreen.title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
        child: Column(
          children: [
            const SizedBox(height: kScreenPadding),
            if (accounts.length > 1)
              CustomDropDown(
                label: 'Account',
                items: dropdownItems,
                selectedValue: dropdownItems.firstWhere(
                    (item) => item.value == selectedAccountId,
                    orElse: () => dropdownItems[0]), // Ensure default selection
                onChanged: (SelectItem? newValue) {
                  ref.read(selectedAccountProvider.notifier).state =
                      newValue!.value;
                },
              ),
            const SizedBox(height: kScreenPadding),
            Expanded(
              child: qrDataAsyncValue.when(
                data: (qrData) => qrData.isNotEmpty
                    ? Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width,
                        alignment: Alignment.topCenter,
                        child: RepaintBoundary(
                          key: qrKey,
                          child: QrImageView(
                            backgroundColor: Colors.white,
                            data: qrData,
                            version: QrVersions.auto,
                          ),
                        ),
                      )
                    : const Center(child: Text('No QR Data')),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, stack) => Center(child: Text('Error: $e')),
              ),
            ),
            const SizedBox(height: kScreenPadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: qrDataAsyncValue.maybeWhen(
                    data: (qrData) => qrData.isNotEmpty,
                    orElse: () => false,
                  )
                      ? () => QRCodeUtils.shareQrImage(qrKey)
                      : null,
                  tooltip: 'Share QR',
                ),
                const SizedBox(width: kScreenPadding),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: qrDataAsyncValue.maybeWhen(
                    data: (qrData) => qrData.isNotEmpty,
                    orElse: () => false,
                  )
                      ? () => copyToClipboard(context, qrDataAsyncValue.value!)
                      : null,
                  tooltip: 'Copy URI',
                ),
                if (Platform.isAndroid || Platform.isIOS)
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: qrDataAsyncValue.maybeWhen(
                      data: (qrData) => qrData.isNotEmpty,
                      orElse: () => false,
                    )
                        ? () => QRCodeUtils.saveQrImage(qrKey)
                        : null,
                    tooltip: 'Download QR Image',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
