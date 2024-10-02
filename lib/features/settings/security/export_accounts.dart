import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/models/select_item.dart';
import 'package:kibisis/utils/theme_extensions.dart';
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
final sliderValueProvider = StateProvider<double>((ref) => 4);

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
      ref.read(accountsListProvider.notifier).loadAccounts();
      startOrAdjustTimer();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startOrAdjustTimer() {
    final interval = ref.read(intervalProvider);
    if (interval == 0) {
      _timer?.cancel();
      return;
    }
    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: interval), (Timer timer) {
      if (!mounted) return;
      _updateCurrentPage();
    });
  }

  void _updateCurrentPage() {
    final currentPage = ref.read(currentPageProvider);
    ref.read(currentPageProvider.notifier).state =
        (currentPage + 1) % qrKeys.length;
    if (_pageController.hasClients) {
      _pageController.jumpToPage(ref.read(currentPageProvider));
    }
  }

  @override
  Widget build(BuildContext context) {
    final exportableAccountsAsyncValue = ref.watch(exportableAccountsProvider);
    final selectedAccountId = ref.watch(selectedAccountProvider) ?? '0';
    final qrDataAsyncValue = ref.watch(barcodeUriProvider(selectedAccountId));

    return Scaffold(
      appBar: AppBar(
        title: const Text(ExportAccountsScreen.title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
        child: exportableAccountsAsyncValue.when(
          data: (exportableAccounts) => _buildExportableAccountsView(
              context, exportableAccounts, selectedAccountId, qrDataAsyncValue),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error: $error'),
          ),
        ),
      ),
    );
  }

  Widget _buildExportableAccountsView(
    BuildContext context,
    List<Map<String, String>> exportableAccounts,
    String selectedAccountId,
    AsyncValue<List<String>> qrDataAsyncValue,
  ) {
    if (exportableAccounts.isEmpty) {
      return Center(
        child: Text(
          'No accounts available for export.',
          style: context.textTheme.bodyLarge,
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: kScreenPadding),
        _buildAccountDropDown(exportableAccounts, selectedAccountId),
        const SizedBox(height: kScreenPadding),
        _buildQrCodeDisplay(qrDataAsyncValue),
        const SizedBox(height: kScreenPadding),
        if (exportableAccounts.length > 5) ...[
          _buildSlider(selectedAccountId),
          const SizedBox(height: kScreenPadding),
        ],
        _buildActionRow(selectedAccountId),
      ],
    );
  }

  Widget _buildAccountDropDown(
      List<Map<String, String>> accounts, String selectedAccountId) {
    final dropdownItems = accounts
        .map((account) => SelectItem(
              name: account['accountName'] ?? 'Unnamed Account',
              value: account['accountId'] ?? '0',
              icon: AppIcons.wallet,
            ))
        .toList();

    _autoSelectFirstAccount(dropdownItems, selectedAccountId);

    final selectedValue = dropdownItems.firstWhere(
      (item) => item.value == selectedAccountId,
      orElse: () => dropdownItems[0],
    );

    return CustomDropDown(
      label: 'Account',
      items: dropdownItems,
      selectedValue: selectedValue,
      onChanged: (SelectItem? newValue) {
        if (newValue != null) {
          ref.read(selectedAccountProvider.notifier).state = newValue.value;
          _restartTimer();
        }
      },
    );
  }

  void _autoSelectFirstAccount(
      List<SelectItem> dropdownItems, String selectedAccountId) {
    if (selectedAccountId == '0') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final firstAccount = dropdownItems[0];
        ref.read(selectedAccountProvider.notifier).state = firstAccount.value;
      });
    }
  }

  Widget _buildQrCodeDisplay(AsyncValue<List<String>> qrDataAsyncValue) {
    return Flexible(
      child: qrDataAsyncValue.when(
        data: (List<String> qrData) {
          if (!mounted) {
            return const SizedBox.shrink();
          }
          qrKeys = List.generate(qrData.length, (index) => GlobalKey());
          resetTimer();
          return qrData.length > 1
              ? _buildSlideshow(qrData)
              : _buildSingleQrView(qrData[0]);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => const Center(
          child: Text(
            'This account cannot be exported, as it has no private key.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildSlider(String selectedAccountId) {
    if (selectedAccountId != 'all') return const SizedBox.shrink();
    return SliderTheme(
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
    );
  }

  Widget _buildSlideshow(List<String> qrData) {
    return Column(
      children: [
        Flexible(
          child: PageView.builder(
            controller: _pageController,
            itemCount: qrData.length,
            itemBuilder: (context, index) {
              return _buildQrPage(qrData[index], index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQrPage(String qrData, int index) {
    return Container(
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.topCenter,
      child: RepaintBoundary(
        key: qrKeys[index],
        child: QrImageView(
          backgroundColor: Colors.white,
          data: qrData,
          version: QrVersions.auto,
        ),
      ),
    );
  }

  Widget _buildSingleQrView(String qrData) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          fit: FlexFit.tight,
          child: Container(
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.topCenter,
            child: RepaintBoundary(
              key: qrKeys[0],
              child: QrImageView(
                backgroundColor: Colors.white,
                data: qrData,
                version: QrVersions.auto,
              ),
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

  void _restartTimer() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startOrAdjustTimer();
    });
  }

  Widget _buildActionRow(String selectedAccountId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          icon: AppIcons.icon(
            icon: AppIcons.copy,
            size: AppIcons.xlarge,
          ),
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
            icon: AppIcons.icon(
              icon: AppIcons.download,
              size: AppIcons.xlarge,
            ),
            onPressed: qrKeys.isNotEmpty
                ? () => QRCodeUtils.saveQrImage(qrKeys[0])
                : null,
            tooltip: 'Download QR Image',
          ),
      ],
    );
  }
}
