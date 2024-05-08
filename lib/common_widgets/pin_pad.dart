import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/pin_entry_provider.dart';

class PinPad extends ConsumerWidget {
  final int pinLength;
  final PinPadMode mode;

  const PinPad({
    super.key,
    this.pinLength = 6,
    required this.mode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              children: List.generate(pinLength, (index) {
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
                double height =
                    width * 4 / 3; // Height based on the aspect ratio

                if (height > constraints.maxHeight) {
                  height = constraints.maxHeight;
                  width = height * 3 / 4; // Width based on the adjusted height
                }

                return Center(
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: GridView.builder(
                      physics:
                          const NeverScrollableScrollPhysics(), // To prevent scrolling inside GridView
                      itemCount: 12, // 0-9 + empty + backspace
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                      ),
                      itemBuilder: (context, index) {
                        if (index == 9) {
                          return const SizedBox.shrink();
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
                            onPressed: () {
                              bool isPinComplete = ref
                                  .read(pinEntryStateNotifierProvider.notifier)
                                  .addKey(key);
                              isPinComplete
                                  ? ref
                                      .read(pinEntryStateNotifierProvider
                                          .notifier)
                                      .pinComplete(mode)
                                  : null;
                              if (mode == PinPadMode.setup && isPinComplete) {
                                GoRouter.of(context).go('/setup/addAccount');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                backgroundColor:
                                    Theme.of(context).colorScheme.surface),
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
}
