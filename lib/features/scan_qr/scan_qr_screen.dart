import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/top_snack_bar.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/scan_qr/qr_code_scanner_logic.dart';
import 'package:kibisis/features/scan_qr/widgets/progress_bar.dart';
import 'package:kibisis/providers/loading_provider.dart';
import 'package:kibisis/providers/multipart_scan_provider.dart';
import 'package:kibisis/providers/temporary_account_provider.dart';
import 'package:kibisis/routing/named_routes.dart';
import 'package:kibisis/theme/color_palette.dart';
import 'package:kibisis/utils/account_setup.dart';
import 'package:kibisis/utils/refresh_account_data.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:kibisis/utils/theme_extensions.dart';

final isPaginatedScanProvider = StateProvider<bool>((ref) => false);

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
  MobileScannerController controller = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
  );

  Timer? _debounceTimer;
  bool isProcessing = false;

  @override
  void reassemble() {
    super.reassemble();
    controller.stop();
    if (mounted) {
      controller.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPaginatedScan = ref.watch(isPaginatedScanProvider);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: Stack(
              fit: StackFit.loose,
              alignment: Alignment.center,
              children: [
                _buildScannerView(),
                SizedBox(
                  width: constraints.maxWidth * kDialogWidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isPaginatedScan) ...[
                        const AnimatedProgressBar(),
                        const SizedBox(height: kScreenPadding),
                      ],
                      _buildScanTargetIndicator(),
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
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text(QrCodeScannerScreen.title,
          style: TextStyle(color: ColorPalette.lightThemeAntiFlashWhite)),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back,
            color: ColorPalette.lightThemeAntiFlashWhite),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _buildScannerView() {
    return MobileScanner(
      key: qrKey,
      controller: controller,
      onDetect: (BarcodeCapture capture) {
        if (_debounceTimer?.isActive ?? false || isProcessing) {
          return;
        }
        ref
            .read(loadingProvider.notifier)
            .startLoading(message: 'Processing QR Code');
        isProcessing = true;
        controller.stop();

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
            controller.start();
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
      try {
        for (var account in scanResult) {
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
              setFinalState: account == scanResult.last,
            );
          } catch (e) {
            debugPrint('Error completing account setup for $name: $e');
            throw Exception('Failed to complete account setup.');
          }
        }
        try {
          invalidateProviders(ref);
          _navigateToAccountPage(scanResult.length);
        } catch (e) {
          debugPrint('Error invalidating providers: $e');
          throw Exception('Failed to invalidate providers.');
        }
      } catch (e) {
        debugPrint('Error processing scan result: $e');
        rethrow;
      }
    } else if (scanResult is String) {
      try {
        if (widget.onScanned != null) {
          widget.onScanned!(scanResult);
        }
        Navigator.of(context).pop(scanResult);
      } catch (e) {
        debugPrint('Error handling public key: $e');
        throw Exception('Error processing public key');
      }
    } else {
      debugPrint('Invalid scan result: $scanResult');
      throw Exception('Invalid scan result');
    }
  }

  void _navigateToAccountPage(int numberOfImportedAccounts) {
    if (numberOfImportedAccounts == 1) {
      if (context.mounted) {
        GoRouter.of(context).go('/');
      }
    } else {
      if (context.mounted) {
        GoRouter.of(context).push('/$accountListRouteName');
      }
    }
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

  Widget _buildScanTargetIndicator() {
    return AspectRatio(
      aspectRatio: 1 / 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: context.colorScheme.primary, width: 2),
          borderRadius: BorderRadius.circular(kWidgetRadius),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    controller.dispose();
    super.dispose();
  }
}
