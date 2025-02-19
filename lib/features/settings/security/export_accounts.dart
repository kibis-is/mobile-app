import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/generated/l10n.dart';
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
  static String title = S.current.exportAccounts;

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
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      final currentPage = ref.read(currentPageProvider);
      final nextPage = (currentPage + 1) % qrKeys.length;

      ref.read(currentPageProvider.notifier).state = nextPage;

      if (_pageController.hasClients) {
        _pageController.jumpToPage(nextPage);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final exportableAccountsAsyncValue = ref.watch(privateKeyAccountsProvider);
    final selectedAccountId = ref.watch(selectedAccountProvider) ?? '0';
    final qrDataAsyncValue = ref.watch(barcodeUriProvider(selectedAccountId));

    return Scaffold(
      appBar: AppBar(
        title: Text(ExportAccountsScreen.title),
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
            tooltip: S.of(context).copyUri,
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
          error: (error, stack) =>
              Center(child: Text('${S.of(context).error}: $error')),
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
          S.of(context).noAccountsForExport,
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
      SelectItem(
          name: S.of(context).allAccounts, value: 'all', icon: AppIcons.wallet),
      ...accounts.map((account) => SelectItem(
            name: account['accountName'] ?? S.of(context).unnamedAccount,
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
      label: S.of(context).account,
      items: dropdownItems,
      selectedValue: selectedValue,
      onChanged: (SelectItem? newValue) {
        if (newValue != null) {
          ref.read(selectedAccountProvider.notifier).state = newValue.value;

          if (newValue.value == 'all') {
            _startOrAdjustTimer();
          } else {
            _timer?.cancel();
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
        const double padding = kScreenPadding + 16.0;
        final double availableHeight = constraints.maxHeight - padding;
        final double qrCodeSize = min(constraints.maxWidth, availableHeight);

        return qrDataAsyncValue.when(
          data: (List<String> qrData) {
            qrKeys = List.generate(qrData.length, (index) => GlobalKey());

            if (selectedAccountId == 'all') {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _startOrAdjustTimer();
              });
            } else {
              _timer?.cancel();
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
          error: (e, stack) => Center(
            child: Text(
              S.of(context).accountCannotBeExported,
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
        size: qrCodeSize,
      ),
    );
  }
}
