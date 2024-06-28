import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/confirmation_dialog.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/authentication_provider.dart';
import 'package:kibisis/providers/pin_entry_provider.dart';
import 'package:kibisis/providers/pin_provider.dart';
import 'package:kibisis/providers/storage_provider.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/app_reset_util.dart';
import 'package:kibisis/utils/theme_extensions.dart';

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

class PinPadState extends ConsumerState<PinPad> {
  @override
  Widget build(BuildContext context) {
    final pinEntryProvider = ref.watch(pinEntryStateNotifierProvider);
    final pinState = ref.watch(pinEntryStateNotifierProvider);

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
            visible: pinState.error.isNotEmpty,
            child: Text(
              pinState.error,
              style: TextStyle(color: context.colorScheme.error),
            ),
          ),
        ),
        FittedBox(
          fit: BoxFit.fitWidth,
          child: Padding(
            padding: const EdgeInsets.all(kScreenPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.pinLength, (index) {
                return Padding(
                  padding: const EdgeInsets.all(kScreenPadding / 2),
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: index < pinEntryProvider.pin.length
                        ? context.colorScheme.onSurfaceVariant
                        : Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: context.colorScheme.onSurfaceVariant,
                            width: 2),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
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
                            return IconButton(
                              style: IconButton.styleFrom(
                                backgroundColor: context.colorScheme.error,
                              ),
                              icon: AppIcons.icon(
                                  icon: AppIcons.refresh,
                                  size: AppIcons.large,
                                  color: context.colorScheme.onError),
                              onPressed: () async {
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
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        }
                        if (index == 11) {
                          return IconButton(
                            icon: AppIcons.icon(
                                icon: AppIcons.backspace, size: AppIcons.large),
                            onPressed: () {
                              ref
                                  .read(pinEntryStateNotifierProvider.notifier)
                                  .removeLastKey();
                            },
                            color: context.colorScheme.onSurface,
                            iconSize: kScreenPadding * 2,
                          );
                        }
                        String key = index == 10 ? '0' : (index + 1).toString();
                        return Padding(
                          padding: const EdgeInsets.all(kScreenPadding / 2),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                backgroundColor: context.colorScheme.surface),
                            onPressed: () {
                              _handlePinKeyPressed(key);
                            },
                            child: Text(
                              key,
                              style: context.textTheme.titleLarge,
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

  void _handleResetApp() async {
    await AppResetUtil.resetApp(ref);
    if (!mounted) return;
    _navigateToSetup();
  }

  void _navigateToSetup() {
    if (!mounted) return;
    GoRouter.of(context).go('/setup');
  }

  void _handlePinKeyPressed(String key) async {
    bool isPinComplete =
        ref.read(pinEntryStateNotifierProvider.notifier).addKey(key);

    if (isPinComplete) {
      await handlePinComplete();
    }
  }

  Future<void> handlePinComplete() async {
    final pinNotifier = ref.read(pinEntryStateNotifierProvider.notifier);
    final pin = pinNotifier.getPin();

    switch (widget.mode) {
      case PinPadMode.setup:
        pinNotifier.pinComplete(widget.mode);
        await ref.refresh(storageProvider).accountExists();
        if (!mounted) return;
        _navigateToAddAccount();
        break;
      case PinPadMode.unlock:
        pinNotifier.pinComplete(widget.mode);
        if (ref.read(isAuthenticatedProvider) && mounted) {
          GoRouter.of(context).go('/');
        }
        break;
      case PinPadMode.verifyTransaction:
        final isPinValid = await ref.read(pinProvider.notifier).verifyPin(pin);
        if (isPinValid) {
          pinNotifier.clearError();
          if (widget.onPinVerified != null) {
            widget.onPinVerified!();
          }
        } else {
          pinNotifier.setError('Incorrect PIN. Try again.');
        }
        break;
      default:
        break;
    }

    if (widget.mode != PinPadMode.setup) {
      ref.read(pinProvider.notifier).clearPinState();
    }
    pinNotifier.clearPin();
  }

  void _navigateToAddAccount() {
    if (!mounted) return;
    GoRouter.of(context).push('/setup/setupAddAccount');
  }
}
