import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/models/select_item.dart';
import 'package:kibisis/theme/color_palette.dart';
import 'package:kibisis/utils/theme_extensions.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:kibisis/common_widgets/custom_dropdown.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/accounts_list_provider.dart';
import 'package:kibisis/providers/active_account_provider.dart';
import 'package:kibisis/providers/barcode_uri_provider.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/copy_to_clipboard.dart';

final selectedAccountProvider = StateProvider<String?>((ref) {
  return ref.read(activeAccountProvider);
});

final currentPageProvider = StateProvider<int>((ref) => 0);

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
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startOrAdjustTimer() {
    _timer?.cancel(); // Cancel any existing timer

    // Start the timer to switch pages every 2 seconds
    _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      final currentPage = ref.read(currentPageProvider);
      final nextPage = (currentPage + 1) % qrKeys.length; // Seamless looping

      ref.read(currentPageProvider.notifier).state = nextPage;

      if (_pageController.hasClients) {
        // Jump to the next page instantly without animation
        _pageController.jumpToPage(nextPage);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final exportableAccountsAsyncValue = ref.watch(exportableAccountsProvider);
    final selectedAccountId = ref.watch(selectedAccountProvider) ?? '0';
    final qrDataAsyncValue = ref.watch(barcodeUriProvider(selectedAccountId));

    return Scaffold(
      appBar: AppBar(
        title: const Text(ExportAccountsScreen.title),
        actions: [
          IconButton(
            icon: AppIcons.icon(icon: AppIcons.copy),
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
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
        child: exportableAccountsAsyncValue.when(
          data: (exportableAccounts) => _buildExportableAccountsView(
            context,
            exportableAccounts,
            selectedAccountId,
            qrDataAsyncValue,
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: kScreenPadding),
        _buildAccountDropDown(exportableAccounts, selectedAccountId),
        const SizedBox(height: kScreenPadding),
        Expanded(
          // This ensures the QR code takes the remaining space without causing overflow
          child: _buildQrCodeDisplay(qrDataAsyncValue, selectedAccountId),
        ),
      ],
    );
  }

  Widget _buildAccountDropDown(
    List<Map<String, String>> accounts,
    String selectedAccountId,
  ) {
    final dropdownItems = [
      SelectItem(name: 'All Accounts', value: 'all', icon: AppIcons.wallet),
      ...accounts.map((account) => SelectItem(
            name: account['accountName'] ?? 'Unnamed Account',
            value: account['accountId'] ?? '0',
            icon: AppIcons.wallet,
          )),
    ];

    final activeAccountId = ref.read(activeAccountProvider);
    final selectedValue = dropdownItems.firstWhere(
      (item) =>
          item.value == activeAccountId || item.value == selectedAccountId,
      orElse: () => dropdownItems[1],
    );

    return CustomDropDown(
      label: 'Account',
      items: dropdownItems,
      selectedValue: selectedValue,
      onChanged: (SelectItem? newValue) {
        if (newValue != null) {
          ref.read(selectedAccountProvider.notifier).state = newValue.value;

          // Automatically start/adjust the timer when "All Accounts" is selected
          if (newValue.value == 'all') {
            _startOrAdjustTimer();
          } else {
            _timer?.cancel(); // Stop the timer for individual accounts
          }
        }
      },
    );
  }

  Widget _buildQrCodeDisplay(
    AsyncValue<List<String>> qrDataAsyncValue,
    String selectedAccountId,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double padding = kScreenPadding + 16.0; // Adjust this for padding
        final double availableHeight = constraints.maxHeight - padding;
        final double qrCodeSize = min(constraints.maxWidth, availableHeight);

        return qrDataAsyncValue.when(
          data: (List<String> qrData) {
            qrKeys = List.generate(qrData.length, (index) => GlobalKey());

            if (selectedAccountId == 'all') {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _startOrAdjustTimer(); // Start the timer if "All Accounts" is selected
              });
            } else {
              _timer
                  ?.cancel(); // Ensure the timer stops if a single account is selected
            }

            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                height: qrCodeSize,
                width: qrCodeSize,
                child: qrData.length > 1
                    ? _buildQrCodeWithPagination(qrData, qrCodeSize)
                    : _buildSingleQrCodeView(qrData[0], qrCodeSize),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, stack) => const Center(
            child: Text(
              'This account cannot be exported, as it has no private key.',
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSingleQrCodeView(String qrData, double qrCodeSize) {
    return RepaintBoundary(
      key: qrKeys[0],
      child: QrImageView(
        backgroundColor: ColorPalette.lightThemeBackground,
        data: qrData,
        version: QrVersions.auto,
        size: qrCodeSize,
      ),
    );
  }

  Widget _buildQrCodeWithPagination(List<String> qrData, double qrCodeSize) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableHeight = constraints.maxHeight;

        return SizedBox(
          height: qrCodeSize,
          width: qrCodeSize,
          child: PageView.builder(
            controller: _pageController,
            itemCount: qrData.length,
            itemBuilder: (context, index) =>
                _buildQrCodePage(qrData[index], index, qrCodeSize),
          ),
        );
      },
    );
  }

  Widget _buildQrCodePage(String qrData, int index, double qrCodeSize) {
    return RepaintBoundary(
      key: qrKeys[index],
      child: QrImageView(
        backgroundColor: ColorPalette.lightThemeBackground,
        data: qrData,
        version: QrVersions.auto,
        size: qrCodeSize, // Make sure each page has the correct size
      ),
    );
  }
}
