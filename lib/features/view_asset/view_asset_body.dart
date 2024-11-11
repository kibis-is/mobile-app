import 'package:algorand_dart/algorand_dart.dart';
import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_text_field.dart';
import 'package:kibisis/common_widgets/top_snack_bar.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/generated/l10n.dart';
import 'package:kibisis/models/combined_asset.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/active_asset_provider.dart';
import 'package:kibisis/providers/algorand_provider.dart';
import 'package:kibisis/providers/algorand_service.dart';
import 'package:kibisis/providers/assets_provider.dart';
import 'package:kibisis/providers/balance_provider.dart';
import 'package:kibisis/providers/loading_provider.dart';
import 'package:kibisis/providers/network_provider.dart';
import 'package:kibisis/providers/storage_provider.dart';
import 'package:kibisis/routing/named_routes.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/copy_to_clipboard.dart';
import 'package:kibisis/utils/media_query_helper.dart';
import 'package:kibisis/utils/number_shortener.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/utils/refresh_account_data.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class ViewAssetBody extends ConsumerStatefulWidget {
  final CombinedAsset asset;
  final AssetScreenMode mode;
  final List<Widget>? actions;

  const ViewAssetBody({
    super.key,
    required this.asset,
    this.mode = AssetScreenMode.view,
    this.actions,
  });

  @override
  ViewAssetBodyState createState() => ViewAssetBodyState();
}

class ViewAssetBodyState extends ConsumerState<ViewAssetBody>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<Offset>> _offsetAnimations;
  late final List<Animation<double>> _opacityAnimations;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(6, (index) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      );
    });

    _offsetAnimations = _controllers.map((controller) {
      return Tween<Offset>(
        begin: const Offset(0, 4),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOut),
      );
    }).toList();

    _opacityAnimations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeIn),
      );
    }).toList();

    _triggerAnimations();
  }

  Future<void> _triggerAnimations() async {
    await Future.delayed(const Duration(milliseconds: 60));
    for (var i = 0; i < _controllers.length; i++) {
      await Future.delayed(const Duration(milliseconds: 60), () {
        _controllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userBalance = widget.asset.amount;
    final totalSupply = double.parse(widget.asset.params.total.toString());
    final mediaQueryHelper = MediaQueryHelper(context);
    final network = ref.watch(networkProvider)?.value;
    final networkIcon = network?.startsWith('network-voi') ?? false
        ? AppIcons.voiCircleIcon
        : AppIcons.algorandCircleIcon;

    final publicAddress = ref.watch(accountProvider).account?.address ?? '';
    final assetsState = ref.watch(assetsProvider(publicAddress));

    bool isOwned = assetsState.maybeWhen(
      data: (assets) =>
          assets.any((asset) => asset.index == widget.asset.index),
      orElse: () => false,
    );

    return Column(
      children: [
        if (widget.actions != null && mediaQueryHelper.isWideScreen())
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: kScreenPadding / 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: widget.actions!,
            ),
          ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: kScreenPadding / 2, vertical: kScreenPadding),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: kScreenPadding / 2, vertical: kScreenPadding),
              child: Column(
                children: [
                  Column(
                    children: [
                      _buildHeroOrChild(
                        condition: !mediaQueryHelper.isWideScreen(),
                        tag: '${widget.asset.index}-icon',
                        child: CircleAvatar(
                          radius: 50.0,
                          backgroundColor: context.colorScheme.primary,
                          child: SvgPicture.asset(
                            '${AppIcons.svgBasePath}$networkIcon.svg',
                            width: 80,
                            height: 80,
                            colorFilter: const ColorFilter.mode(
                                Colors.white, BlendMode.srcATop),
                          ),
                        ),
                      ),
                      const SizedBox(height: kScreenPadding),
                      _buildHeroOrChild(
                        condition: !mediaQueryHelper.isWideScreen(),
                        tag: '${widget.asset.index}-name',
                        child: Text(
                          widget.asset.params.name ?? S.of(context).unknown,
                          textAlign: TextAlign.center,
                          style: context.textTheme.displayMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: kScreenPadding / 2),
                      _buildHeroOrChild(
                        condition: !mediaQueryHelper.isWideScreen(),
                        tag: '${widget.asset.index}-amount',
                        child: Text(
                          NumberFormatter.shortenNumber(userBalance.toDouble()),
                          style: context.textTheme.displayMedium?.copyWith(
                            color: context.colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: kScreenPadding),
                  EllipsizedText(
                    type: EllipsisType.middle,
                    publicAddress,
                    style: context.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: kScreenPadding),
                  _buildAnimatedItem(
                    0,
                    CustomTextField(
                      leadingIcon: AppIcons.unitName,
                      controller: TextEditingController(
                        text: widget.asset.params.unitName ??
                            S.of(context).notAvailable,
                      ),
                      labelText: S.current.notAvailable,
                      isEnabled: false,
                    ),
                  ),
                  const SizedBox(height: kScreenPadding / 2),
                  _buildAnimatedItem(
                    1,
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            leadingIcon: AppIcons.applicationId,
                            controller: TextEditingController(
                              text: widget.asset.index.toString(),
                            ),
                            labelText: S.current.applicationId,
                            isEnabled: false,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(AppIcons.copy),
                          onPressed: () {
                            copyToClipboard(
                                context, widget.asset.index.toString());
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: kScreenPadding / 2),
                  _buildAnimatedItem(
                    2,
                    CustomTextField(
                      leadingIcon: AppIcons.assetType,
                      controller: TextEditingController(
                        text: widget.asset.assetType == AssetType.arc200
                            ? 'ARC-0200'
                            : S.current.algorandStandardAsset,
                      ),
                      labelText: S.current.type,
                      isEnabled: false,
                    ),
                  ),
                  const SizedBox(height: kScreenPadding / 2),
                  _buildAnimatedItem(
                    3,
                    CustomTextField(
                      leadingIcon: AppIcons.decimals,
                      controller: TextEditingController(
                        text: widget.asset.params.decimals.toString(),
                      ),
                      labelText: S.current.decimals,
                      isEnabled: false,
                    ),
                  ),
                  const SizedBox(height: kScreenPadding / 2),
                  _buildAnimatedItem(
                    4,
                    CustomTextField(
                      leadingIcon: AppIcons.totalSupply,
                      controller: TextEditingController(
                        text: NumberFormatter.shortenNumber(totalSupply),
                      ),
                      labelText: S.current.totalSupply,
                      isEnabled: false,
                    ),
                  ),
                  const SizedBox(height: kScreenPadding),
                  _buildAnimatedItem(
                    5,
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CustomButton(
                        text:
                            isOwned ? S.current.sendAsset : S.current.addAsset,
                        isFullWidth: !mediaQueryHelper.isWideScreen(),
                        buttonType: ButtonType.secondary,
                        onPressed: () async {
                          if (isOwned) {
                            ref
                                .read(activeAssetProvider.notifier)
                                .setActiveAsset(widget.asset);
                            context.pushNamed(sendTransactionRouteName,
                                pathParameters: {'mode': 'asset'});
                          } else {
                            await _optInAsset();
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _optInAsset() async {
    final loadingNotifier = ref.read(loadingProvider.notifier);
    loadingNotifier.startLoading(message: S.current.optingInMessage);

    final algorandService = ref.read(algorandServiceProvider);
    final activeAsset = ref.read(activeAssetProvider);
    final balanceState = ref.read(balanceProvider);

    final asset = await _validatePrerequisites(activeAsset, balanceState);
    if (asset == null) return;

    try {
      final privateKey = await _retrievePrivateKey();
      await _performOptIn(privateKey, asset, algorandService);
      _onOptInSuccess();
    } on AlgorandException catch (e) {
      if (mounted) _handleAlgorandException(e, context);
    } catch (e) {
      if (mounted) _showErrorSnackBar(e.toString());
    } finally {
      loadingNotifier.stopLoading();
    }
  }

  Future<CombinedAsset?> _validatePrerequisites(
      CombinedAsset? activeAsset, AsyncValue<double> balanceState) async {
    if (activeAsset == null) {
      ref.read(loadingProvider.notifier).stopLoading();
      throw Exception(S.current.activeAssetNullError);
    }

    final balance = balanceState.maybeWhen(
      data: (balance) => balance,
      orElse: () => 0.0,
    );

    if (balance == 0) {
      ref.read(loadingProvider.notifier).stopLoading();
      showCustomSnackBar(
        context: context,
        snackType: SnackType.error,
        message: S.current.fundAccountError,
      );
      return null;
    }

    return activeAsset;
  }

  Future<String> _retrievePrivateKey() async {
    final privateKey = await ref.read(accountProvider.notifier).getPrivateKey();
    if (privateKey.isEmpty) {
      ref.read(loadingProvider.notifier).stopLoading();
      throw Exception(S.current.privateKeyNotFoundError);
    }
    return privateKey;
  }

  Future<void> _performOptIn(String privateKey, CombinedAsset activeAsset,
      AlgorandService algorandService) async {
    final accountNotifier = ref.read(accountProvider.notifier);
    final accountId = await accountNotifier.getAccountId();
    final publicAddress = await accountNotifier.getPublicAddress();
    final storageService = ref.read(storageProvider);

    if (accountId == null || publicAddress.isEmpty) {
      throw Exception(S.current.accountIdOrAddressNotAvailable);
    }

    try {
      await algorandService.optInAsset(
        asset: activeAsset,
        privateKey: privateKey,
        accountId: accountId,
        publicAddress: publicAddress,
        storageService: storageService,
      );
    } catch (e) {
      debugPrint('Error during opt-in: $e');
      throw Exception(S.current.failedToOptInError);
    }
  }

  void _onOptInSuccess() {
    invalidateProviders(ref);

    if (mounted) {
      GoRouter.of(context).go('/');
      showCustomSnackBar(
        context: context,
        snackType: SnackType.success,
        showConfetti: false,
        message: S.current.assetOptInSuccess,
      );
    }
  }

  void _showErrorSnackBar(String message) {
    showCustomSnackBar(
      context: context,
      snackType: SnackType.error,
      message: message,
    );
  }

  void _handleAlgorandException(AlgorandException e, BuildContext context) {
    String userFriendlyMessage = S.current.algorandServiceError;

    if (e.message.contains('overspend')) {
      userFriendlyMessage = S.current.insufficientBalance;
    }

    debugPrint(e.message);
    showCustomSnackBar(
      context: context,
      snackType: SnackType.error,
      message: userFriendlyMessage,
    );
  }

  Widget _buildHeroOrChild(
      {required bool condition, required String tag, required Widget child}) {
    if (condition) {
      return Hero(
        tag: tag,
        child: child,
      );
    } else {
      return child;
    }
  }

  Widget _buildAnimatedItem(int index, Widget child) {
    return FadeTransition(
      opacity: _opacityAnimations[index],
      child: SlideTransition(
        position: _offsetAnimations[index],
        child: child,
      ),
    );
  }
}
