import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_dialog_picker.dart';
import 'package:kibisis/common_widgets/top_snack_bar.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/scan_qr/qr_code_scanner_logic.dart';
import 'package:kibisis/features/scan_qr/widgets/progress_bar.dart';
import 'package:kibisis/features/scan_qr/widgets/scanner_overlay.dart';
import 'package:kibisis/providers/loading_provider.dart';
import 'package:kibisis/providers/multipart_scan_provider.dart';
import 'package:kibisis/providers/temporary_account_provider.dart';
import 'package:kibisis/providers/accounts_list_provider.dart';
import 'package:kibisis/routing/named_routes.dart';
import 'package:kibisis/theme/color_palette.dart';
import 'package:kibisis/utils/account_setup.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/refresh_account_data.dart';
import 'package:kibisis/utils/wallet_connect_manageer.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:kibisis/utils/theme_extensions.dart';
import 'package:walletconnect_flutter_v2/apis/core/pairing/utils/pairing_models.dart';
import 'package:walletconnect_flutter_v2/apis/sign_api/models/sign_client_events.dart';

final isPaginatedScanProvider = StateProvider<bool>((ref) => false);
final isTorchEnabledProvider = StateProvider<bool>((ref) => false);

class QrCodeScannerScreen extends ConsumerStatefulWidget {
  static const String title = 'Scan QR Code';
  final AccountFlow? accountFlow;
  final ScanMode scanMode;
  final void Function(String)? onScanned;

  const QrCodeScannerScreen({
    super.key,
    this.accountFlow,
    required this.scanMode,
    this.onScanned,
  });

  @override
  QrCodeScannerScreenState createState() => QrCodeScannerScreenState();
}

class QrCodeScannerScreenState extends ConsumerState<QrCodeScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  MobileScannerController scanController = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
  );
  Timer? _debounceTimer;
  bool isProcessing = false;

  late WalletConnectManager walletConnectManager;

  @override
  void initState() {
    super.initState();
    walletConnectManager = WalletConnectManager();
  }

  @override
  void reassemble() {
    super.reassemble();
    scanController.stop();
    if (mounted) {
      !scanController.value.isRunning;
      scanController.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPaginatedScan = ref.watch(isPaginatedScanProvider);

    // Calculate the dimensions of the scan window
    double screenWidth = MediaQuery.of(context).size.width;
    double scanWindowWidth = screenWidth * 0.8; // 80% of the screen width
    double scanWindowHeight = scanWindowWidth; // 1:1 aspect ratio
    double scanWindowTop =
        (MediaQuery.of(context).size.height - scanWindowHeight) / 2;
    double scanWindowLeft = (screenWidth - scanWindowWidth) / 2;

    Rect scanWindowRect = Rect.fromLTWH(
      scanWindowLeft,
      scanWindowTop,
      scanWindowWidth,
      scanWindowHeight,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: Stack(
              fit: StackFit.loose,
              alignment: Alignment.center,
              children: [
                _buildScannerView(scanWindowRect),
                SizedBox(
                  width: constraints.maxWidth * kDialogWidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isPaginatedScan) ...[
                        const AnimatedProgressBar(),
                        const SizedBox(height: kScreenPadding),
                      ],
                      if (isPaginatedScan) ...[
                        const SizedBox(height: kScreenPadding),
                        _buildNextQrCodeText(),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    final isTorchEnabled = ref.watch(isTorchEnabledProvider);
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        _getAppBarTitle(),
        style: const TextStyle(color: ColorPalette.lightThemeAntiFlashWhite),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back,
            color: ColorPalette.lightThemeAntiFlashWhite),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      actions: [
        IconButton(
          icon: Icon(
            isTorchEnabled ? Icons.flash_on : Icons.flash_off,
            color: ColorPalette.lightThemeAntiFlashWhite,
          ),
          onPressed: () {
            scanController.toggleTorch();
            ref.read(isTorchEnabledProvider.notifier).state = !isTorchEnabled;
          },
        ),
      ],
    );
  }

  String _getAppBarTitle() {
    switch (widget.scanMode) {
      case ScanMode.privateKey:
        return 'Import Account';
      case ScanMode.publicKey:
        return 'Scan Address';
      case ScanMode.session:
        return 'Connect';
      case ScanMode.general:
      default:
        return QrCodeScannerScreen.title;
    }
  }

  Widget _buildScannerView(Rect scanWindowRect) {
    return MobileScanner(
      key: qrKey,
      controller: scanController,
      scanWindow: scanWindowRect,
      overlayBuilder: (BuildContext context, BoxConstraints constraints) {
        return ScannerOverlay(scanWindowRect: scanWindowRect);
      },
      onDetect: (BarcodeCapture capture) {
        if (_debounceTimer?.isActive ?? false || isProcessing) {
          return;
        }
        ref
            .read(loadingProvider.notifier)
            .startLoading(message: 'Processing QR Code');
        isProcessing = true;
        scanController.stop();

        _debounceTimer = Timer(const Duration(milliseconds: 2000), () async {
          var scannerLogic = QRCodeScannerLogic(
            accountFlow: (widget.accountFlow ??
                (widget.scanMode == ScanMode.general
                    ? AccountFlow.general
                    : AccountFlow.setup)),
            scanMode: widget.scanMode,
          );
          try {
            dynamic scanResult = await scannerLogic.handleBarcode(capture);
            await _handleScanResult(scanResult);
          } catch (e) {
            !scanController.value.isRunning;
            scanController.start();
            if (mounted) {
              showCustomSnackBar(
                context: context,
                snackType: SnackType.error,
                message: e.toString(),
              );
            }
          } finally {
            isProcessing = false;
            ref.read(loadingProvider.notifier).stopLoading();
          }
        });
      },
    );
  }

  Future<void> _handleScanResult(dynamic scanResult) async {
    if (scanResult is Set<Map<String, dynamic>>) {
      await _handleAccountImportResult(scanResult);
    } else if (scanResult is String) {
      await _handleStringResult(scanResult);
    } else if (scanResult is Uri) {
      await _handleWalletConnectResult(scanResult);
    } else {
      debugPrint('Invalid scan result: $scanResult');
      throw Exception('Invalid scan result');
    }
  }

  Future<void> _handleWalletConnectResult(Uri uri) async {
    try {
      debugPrint('Starting WalletConnect process...');

      if (!walletConnectManager.isInitialized) {
        await walletConnectManager.initialize();
        debugPrint('WalletConnectManager initialized');
      }

      final PairingInfo pairingInfo = await walletConnectManager.pair(uri);
      debugPrint('WalletConnect pairing successful: ${pairingInfo.topic}');

      await walletConnectManager.listenForSessionProposals(
        (SessionProposalEvent proposal) async {
          debugPrint('Session proposal received: ${proposal.id}');

          try {
            scanController.stop();
            String? selectedAccount =
                await _showAccountSelectionDialog(proposal);

            if (selectedAccount != null) {
              debugPrint(
                  'Selected account: $selectedAccount, approving session');
              await walletConnectManager.approveSession(
                  proposal, selectedAccount);
              debugPrint('Session approved successfully!');
              _navigateToSessions();
            } else {
              debugPrint('User canceled the WalletConnect process.');
            }
          } catch (e) {
            debugPrint('Error during session approval: $e');
            !scanController.value.isRunning;
            scanController.start();
          }
          return null;
        },
      );
    } catch (e) {
      debugPrint('Failed to handle WalletConnect URI: $e');
      if (!mounted) return;
      showCustomSnackBar(
        context: context,
        snackType: SnackType.error,
        message: 'Failed to connect via WalletConnect: $e',
      );
      !scanController.value.isRunning;
      scanController.start();
    }
  }

  Future<String?> _showAccountSelectionDialog(
      SessionProposalEvent proposal) async {
    try {
      await ref.read(accountsListProvider.notifier).loadAccounts();

      if (!mounted) return null;

      final accounts = ref.read(accountsListProvider).accounts;

      if (accounts.isEmpty) {
        await _showErrorDialog('No accounts available.');
        return null;
      }

      final selectedAccount = await showDialog<Map<String, String>>(
        context: context,
        builder: (context) {
          return CustomAlertDialog(
            title: 'Connect to:',
            subtitle: '${proposal.params.proposer.metadata.name}?',
            icon: AppIcons.connect,
            items: accounts,
            onCancel: () {
              Navigator.pop(context);
              !scanController.value.isRunning;
              scanController.start();
            },
          );
        },
      );

      return selectedAccount?['publicKey'];
    } catch (e) {
      debugPrint('Error loading accounts: $e');
      return null;
    }
  }

  Future<void> _showErrorDialog(String message) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          titlePadding: const EdgeInsets.all(kScreenPadding),
          title: const Text('Error'),
          content: Text(message),
        );
      },
    );
  }

  Future<void> _handleAccountImportResult(
      Set<Map<String, dynamic>> accounts) async {
    try {
      for (var account in accounts) {
        final String name = account['name'];
        final Uint8List seed = account['seed'];

        bool accountExists;
        try {
          accountExists = await ref
              .read(temporaryAccountProvider.notifier)
              .accountAlreadyExists(seed.toString());
        } catch (e) {
          debugPrint('Error checking if account exists for key $seed: $e');
          throw Exception('Failed to check existing accounts.');
        }

        if (accountExists) {
          debugPrint('Account already exists for key: $seed');
          throw Exception('Account already exists.');
        }

        try {
          await ref
              .read(temporaryAccountProvider.notifier)
              .restoreAccountFromSeed(seed, name: name);
        } catch (e) {
          debugPrint('Error restoring account for $name: $e');
          throw Exception('Failed to restore account.');
        }

        try {
          await AccountSetupUtility.completeAccountSetup(
            ref: ref,
            accountFlow: widget.accountFlow ?? AccountFlow.general,
            accountName: name,
            setFinalState: account == accounts.last,
          );
        } catch (e) {
          debugPrint('Error completing account setup for $name: $e');
          throw Exception('Failed to complete account setup.');
        }
      }

      try {
        invalidateProviders(ref);
        _navigateToAccountPage(accounts.length);
      } catch (e) {
        debugPrint('Error invalidating providers: $e');
        throw Exception('Failed to invalidate providers.');
      }
    } catch (e) {
      debugPrint('Error processing scan result: $e');
      rethrow;
    }
  }

  Future<void> _handleStringResult(String result) async {
    try {
      if (widget.onScanned != null) {
        widget.onScanned!(result);
      }
      Navigator.of(context).pop(result);
    } catch (e) {
      debugPrint('Error handling public key: $e');
      throw Exception('Error processing public key');
    }
  }

  void _navigateToAccountPage(int numberOfImportedAccounts) {
    if (numberOfImportedAccounts == 1) {
      if (mounted) {
        GoRouter.of(context).go('/');
      }
    } else {
      if (mounted) {
        GoRouter.of(context).push('/$accountListRouteName');
      }
    }
  }

  void _navigateToSessions() {
    showCustomSnackBar(
      context: context,
      snackType: SnackType.success,
      message: 'Successfully connected',
    );
    GoRouter.of(context).goNamed(sessionsRouteName);
  }

  Widget _buildNextQrCodeText() {
    final nextQrCodeNumber =
        ref.watch(multipartScanProvider.notifier).getRemainingParts();
    debugPrint('Next QR: $nextQrCodeNumber');
    return Column(
      children: [
        Text('Next QR:', style: context.textTheme.displaySmall),
        Chip(
          label: Text(
            'Part $nextQrCodeNumber',
            style: context.textTheme.displayMedium
                ?.copyWith(color: context.colorScheme.onSecondary),
          ),
          color: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              return context.colorScheme.secondary;
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    scanController.dispose();
    super.dispose();
  }
}
