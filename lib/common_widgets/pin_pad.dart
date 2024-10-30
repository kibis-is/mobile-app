import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/confirmation_dialog.dart';
import 'package:kibisis/common_widgets/top_snack_bar.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/pin_pad/providers/pin_title_provider.dart';
import 'package:kibisis/models/pin_state.dart';
import 'package:kibisis/providers/authentication_provider.dart';
import 'package:kibisis/providers/loading_provider.dart';
import 'package:kibisis/providers/pin_entry_provider.dart';
import 'package:kibisis/providers/pin_provider.dart';
import 'package:kibisis/providers/storage_provider.dart';
import 'package:kibisis/routing/named_routes.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/app_reset_util.dart';
import 'package:kibisis/utils/theme_extensions.dart';
import 'package:vibration/vibration.dart';

class PinPad extends ConsumerStatefulWidget {
  final int pinLength;
  final PinPadMode mode;
  final VoidCallback? onPinVerified;

  const PinPad({
    super.key,
    this.pinLength = 6,
    required this.mode,
    this.onPinVerified,
  });

  @override
  PinPadState createState() => PinPadState();
}

class PinPadState extends ConsumerState<PinPad> with TickerProviderStateMixin {
  bool isConfirmingPin = false;
  bool isPinCompleted = false;
  late AnimationController _controller;
  late List<Animation<Offset>> _positionAnimations;
  late List<Animation<double>> _opacityAnimations;
  String? _activeAccountId;
  String? _accountName;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 750),
      vsync: this,
    );

    _initializeAnimations();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _triggerAnimation();
      ref.read(pinEntryStateNotifierProvider.notifier).reset();

      await ref.read(pinProvider.notifier).preloadStoredHashedPin();

      final storageService = ref.read(storageProvider);
      _activeAccountId = await storageService.getActiveAccount();

      if (_activeAccountId != null) {
        _accountName = await storageService.getAccountData(
            _activeAccountId!, 'accountName');
      }
    });
  }

  void _initializeAnimations() {
    final random = Random();

    _positionAnimations = List.generate(
      widget.pinLength,
      (index) {
        double startDelay = index * 0.05 + random.nextDouble() * 0.04;
        double endDelay = (startDelay + 0.7).clamp(0.0, 1.0);

        return Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              startDelay,
              endDelay,
              curve: Curves.easeOutBack,
            ),
          ),
        );
      },
    );

    _opacityAnimations = List.generate(
      widget.pinLength,
      (index) {
        return Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(
              0.0,
              0.5,
              curve: Curves.easeIn,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _triggerAnimation() {
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final pinEntryProvider = ref.watch(pinEntryStateNotifierProvider);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: kScreenPadding),
        Padding(
          padding: const EdgeInsets.all(kScreenPadding),
          child: Visibility(
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            visible: pinEntryProvider.error.isNotEmpty,
            child: Text(
              pinEntryProvider.error,
              style: TextStyle(color: context.colorScheme.error),
            ),
          ),
        ),
        const SizedBox(height: kScreenPadding),
        FittedBox(
          fit: BoxFit.fitWidth,
          child: Padding(
            padding: const EdgeInsets.all(kScreenPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.pinLength, (index) {
                return isPinCompleted
                    ? _buildStaticCircle(context, pinEntryProvider, index)
                    : _buildAnimatedCircle(context, pinEntryProvider, index);
              }),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: kScreenPadding * 4),
            child: LayoutBuilder(
              builder: (context, constraints) {
                double width = constraints.maxWidth;
                double height = width * 4 / 3;

                if (height > constraints.maxHeight) {
                  height = constraints.maxHeight;
                  width = height * 3 / 4;
                }

                return Center(
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 12,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                      ),
                      itemBuilder: (context, index) {
                        if (index == 9) {
                          if (kDebugMode) {
                            return Padding(
                              padding: const EdgeInsets.all(kScreenPadding / 4),
                              child: IconButton(
                                style: IconButton.styleFrom(
                                  backgroundColor: context.colorScheme.error,
                                  shape: const CircleBorder(),
                                ),
                                icon: AppIcons.icon(
                                    icon: AppIcons.refresh,
                                    size: AppIcons.large,
                                    color: context.colorScheme.onError),
                                onPressed: isPinCompleted
                                    ? null
                                    : () async {
                                        bool confirm = await showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return const ConfirmationDialog(
                                                  yesText: 'Reset',
                                                  noText: 'Cancel',
                                                  content:
                                                      'Are you sure you want to reset this device? This will remove all accounts, settings, and security information.',
                                                );
                                              },
                                            ) ??
                                            false;
                                        if (confirm) {
                                          _handleResetApp();
                                        }
                                      },
                                color: context.colorScheme.onSurface,
                                iconSize: kScreenPadding * 2,
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        }
                        if (index == 11) {
                          return Padding(
                            padding: const EdgeInsets.all(kScreenPadding / 4),
                            child: IconButton(
                              style: IconButton.styleFrom(
                                  shape: const CircleBorder()),
                              icon: AppIcons.icon(
                                  icon: AppIcons.backspace,
                                  size: AppIcons.large),
                              onPressed: isPinCompleted
                                  ? null
                                  : () {
                                      ref
                                          .read(pinEntryStateNotifierProvider
                                              .notifier)
                                          .removeLastKey();
                                    },
                              iconSize: kScreenPadding * 2,
                            ),
                          );
                        }
                        String key = index == 10 ? '0' : (index + 1).toString();
                        return Padding(
                          padding: const EdgeInsets.all(kScreenPadding / 4),
                          child: MaterialButton(
                            onPressed: isPinCompleted
                                ? null
                                : () {
                                    _handlePinKeyPressed(key);
                                  },
                            textColor: context.colorScheme.secondary,
                            elevation: 0,
                            shape: const CircleBorder(),
                            child: Text(
                              key,
                              style: context.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedCircle(
      BuildContext context, PinState pinEntryProvider, int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: _positionAnimations[index].value * 50,
          child: Opacity(
            opacity: _opacityAnimations[index].value,
            child: child,
          ),
        );
      },
      child: _buildCircle(context, pinEntryProvider, index),
    );
  }

  Widget _buildStaticCircle(
      BuildContext context, PinState pinEntryProvider, int index) {
    return Padding(
      padding: const EdgeInsets.all(kScreenPadding / 2),
      child: CircleAvatar(
        radius: 10,
        backgroundColor: index < pinEntryProvider.pin.length
            ? context.colorScheme.onSurface
            : Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: context.colorScheme.onSurfaceVariant, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildCircle(
      BuildContext context, PinState pinEntryProvider, int index) {
    return Padding(
      padding: const EdgeInsets.all(kScreenPadding / 2),
      child: CircleAvatar(
        radius: 10,
        backgroundColor: index < pinEntryProvider.pin.length
            ? context.colorScheme.onSurface
            : Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: context.colorScheme.onSurface, width: 2),
          ),
        ),
      ),
    );
  }

  void _handlePinKeyPressed(String key) {
    if (isPinCompleted) return;

    _handleVibration(kHapticButtonPressDuration);
    final pinPadProvider = ref.read(pinEntryStateNotifierProvider.notifier);
    final pinTitleNotifier = ref.read(pinTitleProvider.notifier);

    pinPadProvider.addKey(key);

    if (pinPadProvider.isPinComplete()) {
      isPinCompleted = true;
      if ((widget.mode == PinPadMode.setup ||
              widget.mode == PinPadMode.changePin) &&
          !isConfirmingPin) {
        isConfirmingPin = true;
        pinTitleNotifier.setConfirmPinTitle();
        pinPadProvider.setFirstPin(pinPadProvider.getPin());
        _controller.reset();
        _triggerAnimation();
        pinPadProvider.reset();
        pinPadProvider.clearError();
        isPinCompleted = false;
      } else {
        _processCompletePin();
      }
    }
  }

  void _handleResetApp() async {
    try {
      ref.read(loadingProvider.notifier).startLoading(message: 'Resetting App');
      await AppResetUtil.resetApp(ref);
      if (!mounted) return;
      GoRouter.of(context).go('/setup');
    } catch (e) {
      debugPrint(e.toString());
      showCustomSnackBar(
        context: context,
        snackType: SnackType.error,
        message: e.toString(),
      );
      ref.read(loadingProvider.notifier).stopLoading();
    }
  }

  Future<void> _processCompletePin() async {
    try {
      await _handlePinComplete();
      if (mounted) {
        _cleanupAfterPin();
      }
    } catch (e) {
      debugPrint('Error during PIN completion: $e');
      ref.read(loadingProvider.notifier).stopLoading();
    } finally {
      if (mounted) {
        isPinCompleted = false;
      }
    }
  }

  Future<void> _handlePinComplete() async {
    final pinNotifier = ref.read(pinEntryStateNotifierProvider.notifier);
    final pinTitleNotifier = ref.read(pinTitleProvider.notifier);
    final pin = pinNotifier.getPin();
    const pinErrorString = 'PIN does not match.';

    switch (widget.mode) {
      case PinPadMode.setup:
        if (isConfirmingPin) {
          if (pinNotifier.getFirstPin() == pin) {
            await pinNotifier.pinComplete(
                widget.mode, _activeAccountId, _accountName);
            if (mounted) {
              ref.read(isAuthenticatedProvider.notifier).state = true;
              isConfirmingPin = false;
              pinTitleNotifier.setCreatePinTitle();
              _navigateToNextScreen();
            }
          } else {
            if (mounted) {
              pinNotifier.setError(pinErrorString);
              _triggerAnimation();
              pinNotifier.reset();
              pinNotifier.setFirstPin('');
              isConfirmingPin = false;
              pinTitleNotifier.setCreatePinTitle();
            }
          }
        }
        break;
      case PinPadMode.unlock:
        await _handleUnlockMode(pinNotifier);
        break;
      case PinPadMode.verifyTransaction:
        await _handleVerifyTransactionMode(pinNotifier, pin);
        break;
      case PinPadMode.changePin:
      default:
        debugPrint('Unhandled mode in _handlePinComplete');
        break;
    }
  }

  Future<void> _handleVibration(int duration) async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: duration);
    }
  }

  void _navigateToNextScreen() {
    GoRouter.of(context).go('/$welcomeRouteName/$setupAddAccountRouteName');
  }

  Future<void> _handleUnlockMode(PinEntryStateNotifier pinNotifier) async {
    try {
      await pinNotifier.pinComplete(
          PinPadMode.unlock, _activeAccountId ?? '', _accountName ?? '');
      if (mounted) {
        bool isAuthenticated = ref.read(isAuthenticatedProvider);
        debugPrint('User is authenticated: $isAuthenticated');
        if (isAuthenticated) {
          _navigateToDashboard();
        }
      }
    } catch (e) {
      debugPrint('Error during unlocking mode: $e');
    }
  }

  Future<void> _handleVerifyTransactionMode(
      PinEntryStateNotifier pinNotifier, String pin) async {
    try {
      bool isPinValid = await ref.read(pinProvider.notifier).verifyPin(pin);
      if (mounted) {
        debugPrint('PIN is valid: $isPinValid');
        if (isPinValid) {
          pinNotifier.clearError();
          widget.onPinVerified?.call();
        } else {
          pinNotifier.setError('Incorrect PIN. Try again.');
        }
      }
    } catch (e) {
      debugPrint('Error during PIN verification: $e');
    }
  }

  void _cleanupAfterPin() {
    final pinPadProvider = ref.read(pinEntryStateNotifierProvider.notifier);
    pinPadProvider.reset();
    _triggerAnimation();
    ref.read(isPinCompleteProvider.notifier).state = false;
  }

  void _navigateToDashboard() {
    GoRouter.of(context).go('/');
  }
}
