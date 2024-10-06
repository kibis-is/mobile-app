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

final isAnimatingProvider = StateProvider<bool>((ref) => false);

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
      startOrAdjustTimer();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startOrAdjustTimer() {
    if (!ref.read(isAnimatingProvider)) {
      _timer?.cancel();
      return;
    }
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 2000), (Timer timer) {
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
        _buildQrCodeDisplay(
            qrDataAsyncValue, selectedAccountId), // QR code with play/pause
        const SizedBox(height: kScreenPadding),
        _buildActionRow(selectedAccountId),
      ],
    );
  }

  Widget _buildAccountDropDown(
      List<Map<String, String>> accounts, String selectedAccountId) {
    // Add "All Accounts" option
    final dropdownItems = [
      SelectItem(
        name: 'All Accounts',
        value: 'all', // Make sure 'all' is unique from account IDs
        icon: AppIcons.wallet,
      ),
      ...accounts.map((account) => SelectItem(
            name: account['accountName'] ?? 'Unnamed Account',
            value: account['accountId'] ?? '0', // Ensure this is unique
            icon: AppIcons.wallet,
          ))
    ];

    // Check if the active account is in the exportable list
    final activeAccountId = ref.read(activeAccountProvider);
    final selectedValue = dropdownItems.firstWhere(
      (item) =>
          item.value == activeAccountId || item.value == selectedAccountId,
      orElse: () => dropdownItems[
          1], // If the active account isn't in the list, select the first account (not "All Accounts")
    );

    return CustomDropDown(
      label: 'Account',
      items: dropdownItems,
      selectedValue: selectedValue,
      onChanged: (SelectItem? newValue) {
        if (newValue != null) {
          ref.read(selectedAccountProvider.notifier).state = newValue.value;
          if (newValue.value == 'all') {
            ref.read(isAnimatingProvider.notifier).state =
                true; // Start animation if "All Accounts" is selected
          }
          _restartTimer(); // Restart the timer when a new account is selected
        }
      },
    );
  }

  Widget _buildQrCodeDisplay(
      AsyncValue<List<String>> qrDataAsyncValue, String selectedAccountId) {
    final hasMultiplePages = (qrDataAsyncValue.asData?.value.length ?? 0) > 1;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min, // Shrink-wrap the content
        children: [
          qrDataAsyncValue.when(
            data: (List<String> qrData) {
              if (!mounted) {
                return const SizedBox.shrink();
              }
              qrKeys = List.generate(qrData.length, (index) => GlobalKey());
              resetTimer();
              return qrData.length > 1
                  ? _buildQrCodeWithPlayPause(qrData)
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
          if (selectedAccountId == 'all' && hasMultiplePages)
            _buildPlayPauseButton(),
        ],
      ),
    );
  }

  Widget _buildQrCodeWithPlayPause(List<String> qrData) {
    return Column(
      children: [
        SizedBox(
          height: 300, // Define a height constraint for the QR code container
          child: PageView.builder(
            controller: _pageController,
            itemCount: qrData.length,
            itemBuilder: (context, index) {
              return Container(
                alignment: Alignment.topCenter,
                child: RepaintBoundary(
                  key: qrKeys[index],
                  child: QrImageView(
                    backgroundColor: Colors.white,
                    data: qrData[index],
                    version: QrVersions.auto,
                    size: 300, // Define the size of the QR code
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16), // Add some space between QR and button
      ],
    );
  }

  Widget _buildSingleQrView(String qrData) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 300, // Define a fixed height
          child: Container(
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

  Widget _buildPlayPauseButton() {
    return IconButton(
      icon:
          Icon(ref.watch(isAnimatingProvider) ? Icons.pause : Icons.play_arrow),
      onPressed: () {
        ref.read(isAnimatingProvider.notifier).state =
            !ref.read(isAnimatingProvider); // Toggle play/pause state
        _restartTimer(); // Restart the timer based on the play/pause toggle
      },
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
