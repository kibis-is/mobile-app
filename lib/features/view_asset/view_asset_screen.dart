import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/common_widgets/custom_text_field.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/active_asset_provider.dart';
import 'package:kibisis/providers/balance_provider.dart';
import 'package:kibisis/providers/loading_provider.dart';
import 'package:kibisis/providers/algorand_provider.dart';
import 'package:kibisis/routing/named_routes.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/copy_to_clipboard.dart';
import 'package:kibisis/utils/number_shortener.dart';
import 'package:kibisis/utils/refresh_account_data.dart';
import 'package:kibisis/utils/theme_extensions.dart';
import 'package:kibisis/common_widgets/top_snack_bar.dart';
import 'package:algorand_dart/algorand_dart.dart';
import 'package:go_router/go_router.dart';

class ViewAssetScreen extends ConsumerWidget {
  final AssetScreenMode mode;
  const ViewAssetScreen({
    super.key,
    this.mode = AssetScreenMode.view,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAsset = ref.watch(activeAssetProvider);
    final userBalance = activeAsset?.amount ?? 0;
    final totalSupply =
        double.parse(activeAsset?.params.total.toString() ?? '1');
    final publicKey = ref.watch(accountProvider).account?.publicAddress;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          mode == AssetScreenMode.view ? 'View Asset' : 'Add Asset',
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(kScreenPadding),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(kScreenPadding),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50.0,
                      backgroundColor: context.colorScheme.primary,
                      child: SvgPicture.asset(
                        '${AppIcons.svgBasePath}${AppIcons.voiCircleIcon}.svg',
                        width: 80,
                        height: 80,
                        semanticsLabel: 'Asset Icon',
                        colorFilter: ColorFilter.mode(
                            context.colorScheme.background, BlendMode.srcATop),
                      ),
                    ),
                    const SizedBox(height: kScreenPadding),
                    EllipsizedText(
                      NumberShortener.shortenNumber(userBalance.toDouble()),
                      style: context.textTheme.displayMedium?.copyWith(
                          color: context.colorScheme.secondary,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: kScreenPadding / 2),
                    EllipsizedText(
                      activeAsset?.params.name ?? 'Unnamed Asset',
                      style: context.textTheme.displayMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: kScreenPadding),
              EllipsizedText(
                publicKey ?? 'Not available',
                type: EllipsisType.middle,
              ),
              const SizedBox(height: kScreenPadding),
              CustomTextField(
                controller: TextEditingController(
                  text: activeAsset?.params.unitName ?? 'Not available',
                ),
                labelText: 'UnitName',
                isEnabled: false,
              ),
              const SizedBox(height: kScreenPadding / 2),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: TextEditingController(
                        text: activeAsset?.index.toString() ?? 'Not available',
                      ),
                      labelText: 'Application ID',
                      isEnabled: false,
                    ),
                  ),
                  const SizedBox(
                    width: kScreenPadding,
                  ),
                  IconButton(
                    icon: const Icon(AppIcons.copy),
                    onPressed: () {
                      copyToClipboard(
                          context, activeAsset?.index.toString() ?? '');
                    },
                  )
                ],
              ),
              const SizedBox(height: kScreenPadding / 2),
              CustomTextField(
                controller: TextEditingController(
                  text: activeAsset?.assetType == AssetType.arc200
                      ? 'ARC-0200'
                      : 'Algorand Standard Asset',
                ),
                labelText: 'Type',
                isEnabled: false,
              ),
              const SizedBox(height: kScreenPadding / 2),
              CustomTextField(
                controller: TextEditingController(
                  text: activeAsset?.params.decimals.toString() ?? '0',
                ),
                labelText: 'Decimals',
                isEnabled: false,
              ),
              const SizedBox(height: kScreenPadding / 2),
              CustomTextField(
                controller: TextEditingController(
                  text: NumberShortener.shortenNumber(totalSupply),
                ),
                labelText: 'Total Supply',
                isEnabled: false,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(kScreenPadding),
        child: CustomButton(
          text: mode == AssetScreenMode.view ? 'Send Asset' : 'Add Asset',
          isFullWidth: true,
          buttonType: ButtonType.secondary,
          onPressed: () => _handleButtonPress(context, ref),
        ),
      ),
    );
  }

  Future<void> _handleButtonPress(BuildContext context, WidgetRef ref) async {
    final asset = ref.read(activeAssetProvider);
    if (asset?.assetType == AssetType.arc200) {
      _handleGeneralException(
          "ARC200 assets not yet supported", StackTrace.current, context);
      return;
    }
    if (mode == AssetScreenMode.view) {
      context.pushNamed(sendTransactionRouteName,
          pathParameters: {'mode': 'asset'});
      return;
    }

    ref
        .read(loadingProvider.notifier)
        .startLoading(message: 'Opting in', withProgressBar: true);
    try {
      await _addAsset(context, ref);
    } on AlgorandException catch (algorandError) {
      if (!context.mounted) return;
      _handleAlgorandException(algorandError, context);
    } catch (e, stack) {
      if (!context.mounted) return;
      _handleGeneralException(e, stack, context);
      ref.read(loadingProvider.notifier).stopLoading();
    }
  }

  Future<void> _addAsset(BuildContext context, WidgetRef ref) async {
    final algorandService = ref.read(algorandServiceProvider);
    final account = ref.read(accountProvider).account;
    final activeAsset = ref.read(activeAssetProvider);
    final balanceState = ref.read(balanceProvider);

    if (account == null || activeAsset == null) {
      throw Exception('Account or active asset is null');
    }

    final balance = balanceState.maybeWhen(
      data: (balance) => balance,
      orElse: () => 0.0,
    );

    if (balance == 0) {
      showCustomSnackBar(
        context: context,
        snackType: SnackType.error,
        message: 'Please fund your account to proceed.',
      );
      return;
    }

    try {
      if (activeAsset.assetType == AssetType.arc200) {
        throw Exception('Asset type not yet supported');
      } else {
        await algorandService.optInAsset(activeAsset.index, account);
      }

      invalidateProviders(ref);

      if (context.mounted) {
        GoRouter.of(context).go('/');
        showCustomSnackBar(
          context: context,
          snackType: SnackType.success,
          message: 'Asset successfully opted in',
        );
      }
    } on AlgorandException catch (e) {
      if (!context.mounted) return;
      _handleAlgorandException(e, context);
    }
  }

  void _handleAlgorandException(AlgorandException e, BuildContext context) {
    String userFriendlyMessage = 'An error occurred with Algorand service';

    if (e.message.contains('overspend')) {
      userFriendlyMessage = 'Insufficient balance to opt-in to asset.';
    }

    debugPrint(e.message);
    showCustomSnackBar(
      context: context,
      snackType: SnackType.error,
      message: userFriendlyMessage,
    );
  }

  void _handleGeneralException(
      dynamic e, StackTrace stack, BuildContext context) {
    debugPrint('$e\n$stack');
    showCustomSnackBar(
      context: context,
      snackType: SnackType.error,
      message: e.toString(),
    );
  }
}
