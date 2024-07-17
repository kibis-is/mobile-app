import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_carousel/infinite_carousel.dart';
import 'package:kibisis/common_widgets/custom_dropdown.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/accounts_list_provider.dart';
import 'package:kibisis/providers/active_account_provider.dart';
import 'package:kibisis/providers/barcode_uri_provider.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/copy_to_clipboard.dart';
import 'package:kibisis/utils/save_qr_image.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Make sure you replace this with your QrImageView if it's a custom widget

final selectedAccountProvider = StateProvider<String?>((ref) {
  final activeAccountId = ref.read(activeAccountProvider);
  return activeAccountId;
});

class ExportAccountsScreen extends ConsumerStatefulWidget {
  static const String title = 'Export Accounts';

  const ExportAccountsScreen({super.key});

  @override
  ExportAccountsScreenState createState() => ExportAccountsScreenState();
}

class ExportAccountsScreenState extends ConsumerState<ExportAccountsScreen> {
  List<GlobalKey> qrKeys = [];

  @override
  Widget build(BuildContext context) {
    final accounts =
        ref.watch(accountsListProvider.select((value) => value.accounts));
    final selectedAccountId = ref.watch(selectedAccountProvider) ?? '0';
    final qrDataAsyncValue = ref.watch(barcodeUriProvider(selectedAccountId));

    List<SelectItem> dropdownItems = accounts
        .map((account) => SelectItem(
              name: account['accountName'] ?? 'Unnamed Account',
              value: account['accountId'] ?? '0',
              icon: AppIcons.wallet,
            ))
        .toList();
    dropdownItems.insert(0,
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
                    orElse: () => dropdownItems[0]),
                onChanged: (SelectItem? newValue) {
                  if (newValue != null) {
                    ref.read(selectedAccountProvider.notifier).state =
                        newValue.value;
                  }
                },
              ),
            const SizedBox(height: kScreenPadding),
            Expanded(
              child: qrDataAsyncValue.when(
                data: (List<String> qrDatas) {
                  qrKeys =
                      List.generate(qrDatas.length, (index) => GlobalKey());
                  return qrDatas.length > 1
                      ? buildCarousel(qrDatas)
                      : buildSingleQrView(qrDatas[0]);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, stack) => Center(child: Text('Error: $e')),
              ),
            ),
            const SizedBox(height: kScreenPadding),
            buildActionRow(selectedAccountId),
          ],
        ),
      ),
    );
  }

  Widget buildCarousel(List<String> qrDatas) {
    return InfiniteCarousel.builder(
      itemCount: qrDatas.length,
      itemExtent: MediaQuery.of(context).size.width * 0.8,
      controller: InfiniteScrollController(),
      loop: false,
      center: true,
      physics: const PageViewTypeScrollPhysics(),
      scrollBehavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
      ),
      itemBuilder: (context, itemIndex, realIndex) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: kScreenPadding / 2),
          child: Container(
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            child: RepaintBoundary(
              key: qrKeys[itemIndex],
              child: QrImageView(
                backgroundColor: Colors.white,
                data: qrDatas[0],
                version: QrVersions.auto,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildSingleQrView(String qrData) {
    return Container(
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: RepaintBoundary(
        key: qrKeys[0],
        child: QrImageView(
          backgroundColor: Colors.white,
          data: qrData,
          version: QrVersions.auto,
        ),
      ),
    );
  }

  Widget buildActionRow(String selectedAccountId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: qrKeys.isNotEmpty
              ? () => QRCodeUtils.shareQrImage(qrKeys[0])
              : null, // Share the first QR code
          tooltip: 'Share QR',
        ),
        const SizedBox(width: kScreenPadding),
        IconButton(
          icon: const Icon(Icons.copy),
          onPressed: qrKeys.isNotEmpty
              ? () => copyToClipboard(
                  context,
                  ref
                          .read(barcodeUriProvider(selectedAccountId))
                          .value
                          ?.join('\n') ??
                      '')
              : null,
          tooltip: 'Copy URI',
        ),
        if (Platform.isAndroid || Platform.isIOS)
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: qrKeys.isNotEmpty
                ? () => QRCodeUtils.saveQrImage(qrKeys[0])
                : null, // Save the first QR code
            tooltip: 'Download QR Image',
          ),
      ],
    );
  }
}
