import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/common_widgets/custom_dropdown.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/accounts_list_provider.dart';
import 'package:kibisis/providers/active_account_provider.dart';
import 'package:kibisis/providers/barcode_uri_provider.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/copy_to_clipboard.dart';
import 'package:kibisis/utils/save_qr_image.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
  Timer? _timer;
  final _pageController = PageController();
  int _currentPage = 0;
  double _intervalSeconds = 2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startTimer();
    });
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: _intervalSeconds.round()),
        (Timer timer) {
      if (_currentPage < qrKeys.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_currentPage);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

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
                    _timer?.cancel(); // Stop the timer
                    ref.read(selectedAccountProvider.notifier).state =
                        newValue.value;
                    // Restart the timer after the state update
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      startTimer();
                    });
                  }
                },
              ),
            const SizedBox(height: kScreenPadding),
            Expanded(
              child: qrDataAsyncValue.when(
                data: (List<String> qrData) {
                  qrKeys = List.generate(qrData.length, (index) => GlobalKey());
                  resetTimer();
                  return qrData.length > 1
                      ? buildSlideshow(qrData)
                      : buildSingleQrView(qrData[0]);
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

  Widget buildSlideshow(List<String> qrData) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: qrData.length,
            itemBuilder: (context, index) {
              return Center(
                child: RepaintBoundary(
                  key: qrKeys[index],
                  child: QrImageView(
                    backgroundColor: Colors.white,
                    data: qrData[index],
                    version: QrVersions.auto,
                  ),
                ),
              );
            },
          ),
        ),
        Slider(
          value: _intervalSeconds,
          min: 0,
          max: 10,
          divisions: 10,
          label: '${_intervalSeconds.round()} seconds',
          onChanged: (double value) {
            setState(() {
              _intervalSeconds = value;
              resetTimer();
            });
          },
        ),
        const SizedBox(height: kScreenPadding),
      ],
    );
  }

  Widget buildSingleQrView(String qrData) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
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
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
          child: Slider(
            value: _intervalSeconds,
            min: 1,
            max: 10,
            divisions: 9,
            label: '${_intervalSeconds.round()} seconds',
            onChanged: (double value) {
              setState(() {
                _intervalSeconds = value;
                resetTimer();
              });
            },
          ),
        ),
        const SizedBox(height: kScreenPadding),
      ],
    );
  }

  void resetTimer() {
    _timer?.cancel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startTimer();
    });
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
