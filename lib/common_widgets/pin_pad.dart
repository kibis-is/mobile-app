import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/authentication_provider.dart';
import 'package:kibisis/providers/loading_provider.dart';
import 'package:kibisis/providers/pin_entry_provider.dart';
import 'package:kibisis/providers/pin_provider.dart';
import 'package:kibisis/providers/storage_provider.dart';
import 'package:kibisis/utils/app_reset_util.dart';

class PinPad extends ConsumerStatefulWidget {
  final int pinLength;
  final PinPadMode mode;

  const PinPad({
    super.key,
    this.pinLength = 6,
    required this.mode,
  });

  @override
  PinPadState createState() => PinPadState();
}

class PinPadState extends ConsumerState<PinPad> {
  @override
  Widget build(BuildContext context) {
    final pinEntryProvider = ref.watch(pinEntryStateNotifierProvider);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
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
                        ? Colors.white
                        : Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
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
                          // Add reset button in debug mode
                          if (kDebugMode) {
                            return IconButton(
                              style: IconButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.error,
                              ),
                              icon: Icon(
                                Icons.refresh,
                                color: Theme.of(context).colorScheme.onError,
                              ),
                              onPressed: () {
                                _handleResetApp();
                              },
                              color: Theme.of(context).colorScheme.onSurface,
                              iconSize: kScreenPadding * 2,
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        }
                        if (index == 11) {
                          return IconButton(
                            icon: const Icon(Icons.backspace),
                            onPressed: () {
                              ref
                                  .read(pinEntryStateNotifierProvider.notifier)
                                  .removeLastKey();
                            },
                            color: Theme.of(context).colorScheme.onSurface,
                            iconSize: kScreenPadding * 2,
                          );
                        }
                        String key = index == 10 ? '0' : (index + 1).toString();
                        return Padding(
                          padding: const EdgeInsets.all(kScreenPadding / 2),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                backgroundColor:
                                    Theme.of(context).colorScheme.surface),
                            onPressed: () {
                              _handlePinKeyPressed(key);
                            },
                            child: Text(
                              key,
                              style: Theme.of(context).textTheme.titleLarge,
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
    ref.read(loadingProvider.notifier).startLoading();

    bool isPinComplete =
        ref.read(pinEntryStateNotifierProvider.notifier).addKey(key);

    if (isPinComplete) {
      await handlePinComplete();
    }

    ref.read(loadingProvider.notifier).stopLoading();
  }

  Future<void> handlePinComplete() async {
    final pinNotifier = ref.read(pinEntryStateNotifierProvider.notifier);
    pinNotifier.pinComplete(widget.mode);

    if (widget.mode == PinPadMode.setup) {
      await ref.refresh(storageProvider).accountExists();
      if (!mounted) return;
      _navigateToAddAccount();
    } else if (widget.mode == PinPadMode.unlock) {
      if (ref.read(isAuthenticatedProvider) && mounted) {
        // Optionally navigate to the home screen or another screen
      }
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
