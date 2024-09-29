import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_text_field.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/models/combined_asset.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/loading_provider.dart';
import 'package:kibisis/routing/named_routes.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/copy_to_clipboard.dart';
import 'package:kibisis/utils/media_query_helper.dart';
import 'package:kibisis/utils/number_shortener.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class ViewAssetBody extends ConsumerStatefulWidget {
  final CombinedAsset asset;
  final AssetScreenMode mode;

  const ViewAssetBody({
    super.key,
    required this.asset,
    this.mode = AssetScreenMode.view,
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
  @override
  Widget build(BuildContext context) {
    final userBalance = widget.asset.amount;
    final totalSupply = double.parse(widget.asset.params.total.toString());
    final String publicKey = ref.watch(accountProvider).account?.publicAddress;
    final mediaQueryHelper = MediaQueryHelper(context);

    return SingleChildScrollView(
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
                      '${AppIcons.svgBasePath}${AppIcons.voiCircleIcon}.svg',
                      width: 80,
                      height: 80,
                      semanticsLabel: 'Asset Icon',
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
                    widget.asset.params.name ?? 'Unnamed Asset',
                    style: context.textTheme.displayMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: kScreenPadding / 2),
                _buildHeroOrChild(
                  condition: !mediaQueryHelper.isWideScreen(),
                  tag: '${widget.asset.index}-amount',
                  child: Text(
                    NumberShortener.shortenNumber(userBalance.toDouble()),
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
              publicKey,
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: kScreenPadding),
            _buildAnimatedItem(
              0,
              CustomTextField(
                leadingIcon: AppIcons.unitName,
                controller: TextEditingController(
                  text: widget.asset.params.unitName ?? 'Not available',
                ),
                labelText: 'UnitName',
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
                      labelText: 'Application ID',
                      isEnabled: false,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(AppIcons.copy),
                    onPressed: () {
                      copyToClipboard(context, widget.asset.index.toString());
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
                      : 'Algorand Standard Asset',
                ),
                labelText: 'Type',
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
                labelText: 'Decimals',
                isEnabled: false,
              ),
            ),
            const SizedBox(height: kScreenPadding / 2),
            _buildAnimatedItem(
              4,
              CustomTextField(
                leadingIcon: AppIcons.totalSupply,
                controller: TextEditingController(
                  text: NumberShortener.shortenNumber(totalSupply),
                ),
                labelText: 'Total Supply',
                isEnabled: false,
              ),
            ),
            const SizedBox(height: kScreenPadding),
            _buildAnimatedItem(
              5,
              Align(
                alignment: Alignment.centerLeft,
                child: CustomButton(
                  text: widget.mode == AssetScreenMode.view
                      ? 'Send Asset'
                      : 'Add Asset',
                  isFullWidth: !mediaQueryHelper.isWideScreen(),
                  buttonType: ButtonType.secondary,
                  onPressed: () async {
                    if (widget.mode == AssetScreenMode.view) {
                      context
                          .pushNamed(sendTransactionRouteName, pathParameters: {
                        'mode': 'asset',
                      });
                    } else if (widget.mode == AssetScreenMode.add) {
                      await _optInAsset(context, ref, widget.asset);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _optInAsset(
      BuildContext context, WidgetRef ref, CombinedAsset asset) async {
    try {
      ref
          .read(loadingProvider.notifier)
          .startLoading(message: 'Opting in', withProgressBar: true);

      await Future.delayed(const Duration(seconds: 2));

      ref.read(loadingProvider.notifier).stopLoading();

      if (context.mounted) {
        context.go('/');
      }
    } catch (e) {
      ref.read(loadingProvider.notifier).stopLoading();
      debugPrint('Failed to opt-in: $e');
    }
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
