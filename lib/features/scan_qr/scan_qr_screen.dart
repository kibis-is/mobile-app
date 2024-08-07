import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/common_widgets/top_snack_bar.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/scan_qr/widgets/progress_bar.dart';
import 'package:kibisis/providers/loading_provider.dart';
import 'package:kibisis/providers/multipart_scan_provider.dart';
import 'package:kibisis/utils/barcode_scanner.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:kibisis/utils/theme_extensions.dart';

final isPaginatedScanProvider = StateProvider<bool>((ref) => false);

class QrCodeScannerScreen extends ConsumerStatefulWidget {
  static const String title = 'Scan QR';
  final AccountFlow? accountFlow;
  final ScanMode scanMode;

  const QrCodeScannerScreen({
    super.key,
    this.accountFlow,
    required this.scanMode,
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
      body: Center(
        // Add Center here
        child: Stack(
          fit: StackFit.loose,
          alignment: Alignment.center,
          children: [
            _buildScannerView(),
            SizedBox(
              width: MediaQuery.of(context).size.width * kDialogWidth,
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
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text(QrCodeScannerScreen.title),
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
            .startLoading(message: 'Importing Accounts', fullScreen: false);
        isProcessing = true;
        controller.stop();
        _debounceTimer = Timer(const Duration(milliseconds: 2000), () async {
          var scannerLogic = QRCodeScannerLogic(
            context: context,
            ref: ref,
            scanMode: widget.scanMode,
            controller: controller,
            accountFlow: widget.accountFlow,
          );
          try {
            await scannerLogic.handleBarcode(capture);
          } catch (e) {
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
          borderRadius: BorderRadius.circular(12),
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
