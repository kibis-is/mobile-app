import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:kibisis/common_widgets/custom_dropdown.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/accounts_list_provider.dart';
import 'package:kibisis/providers/active_account_provider.dart';
import 'package:kibisis/providers/barcode_uri_provider.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/copy_to_clipboard.dart';
import 'package:kibisis/utils/save_qr_image.dart';

final selectedAccountProvider = StateProvider<String?>((ref) {
  final activeAccountId = ref.read(activeAccountProvider);
  return activeAccountId;
});

final currentPageProvider = StateProvider<int>((ref) => 0);
final sliderValueProvider = StateProvider<double>((ref) => 0);

final intervals = [
  {'label': '0', 'value': 0},
  {'label': '1', 'value': 3500},
  {'label': '2', 'value': 3000},
  {'label': '3', 'value': 2500},
  {'label': '4', 'value': 2000},
  {'label': '5', 'value': 1500},
  {'label': '6', 'value': 1000},
  {'label': '7', 'value': 750},
  {'label': '8', 'value': 500},
  {'label': '9', 'value': 250},
];

final intervalProvider = StateProvider<int>((ref) {
  final sliderValue = ref.watch(sliderValueProvider).toInt();
  return intervals[sliderValue]['value'] as int;
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startOrAdjustTimer();
    });
  }

  void startOrAdjustTimer() {
    final interval = ref.read(intervalProvider);
    if (interval == 0) {
      _timer?.cancel();
      return;
    }
    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: interval), (Timer timer) {
      final currentPage = ref.read(currentPageProvider);
      ref.read(currentPageProvider.notifier).state =
          (currentPage + 1) % qrKeys.length;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(ref.read(currentPageProvider));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final accounts =
        ref.watch(accountsListProvider.select((value) => value.accounts));
    final selectedAccountId = ref.watch(selectedAccountProvider) ?? '0';
    final qrDataAsyncValue = ref.watch(barcodeUriProvider(selectedAccountId));

    return Scaffold(
      appBar: AppBar(
        title: const Text(ExportAccountsScreen.title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
        child: Column(
          children: [
            const SizedBox(height: kScreenPadding),
            buildAccountDropDown(accounts, selectedAccountId),
            const SizedBox(height: kScreenPadding),
            buildQrCodeDisplay(qrDataAsyncValue),
            buildSlider(selectedAccountId),
            const SizedBox(height: kScreenPadding),
            buildActionRow(selectedAccountId),
          ],
        ),
      ),
    );
  }

  Widget buildAccountDropDown(
      List<Map<String, dynamic>> accounts, String selectedAccountId) {
    if (accounts.length <= 1) return const SizedBox.shrink();

    List<SelectItem> dropdownItems = accounts
        .map((account) => SelectItem(
              name: account['accountName'] ?? 'Unnamed Account',
              value: account['accountId'] ?? '0',
              icon: AppIcons.wallet,
            ))
        .toList();
    dropdownItems.insert(0,
        SelectItem(name: 'All Accounts', value: 'all', icon: AppIcons.group));

    return CustomDropDown(
      label: 'Account',
      items: dropdownItems,
      selectedValue: dropdownItems.firstWhere(
        (item) => item.value == selectedAccountId,
        orElse: () => dropdownItems[0],
      ),
      onChanged: (SelectItem? newValue) {
        if (newValue != null) {
          _timer?.cancel();
          ref.read(selectedAccountProvider.notifier).state = newValue.value;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            startOrAdjustTimer();
          });
        }
      },
    );
  }

  Widget buildQrCodeDisplay(AsyncValue<List<String>> qrDataAsyncValue) {
    return Expanded(
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
    );
  }

  Widget buildSlider(String selectedAccountId) {
    if (selectedAccountId != 'all') return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: SliderTheme(
        data: SliderTheme.of(context)
            .copyWith(overlayShape: SliderComponentShape.noThumb),
        child: Consumer(
          builder: (context, ref, child) {
            final sliderValue = ref.watch(sliderValueProvider);
            return Slider(
              value: sliderValue,
              min: 0,
              max: (intervals.length - 1).toDouble(),
              divisions: intervals.length - 1,
              label: intervals[sliderValue.toInt()]['label'].toString(),
              onChanged: (double value) {
                ref.read(sliderValueProvider.notifier).state = value;
                startOrAdjustTimer();
              },
            );
          },
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
        const SizedBox(height: kScreenPadding),
      ],
    );
  }

  void resetTimer() {
    _timer?.cancel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startOrAdjustTimer();
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
              : null,
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
                : null,
            tooltip: 'Download QR Image',
          ),
      ],
    );
  }
}
