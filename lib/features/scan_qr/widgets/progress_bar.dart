import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/utils/theme_extensions.dart';

final progressBarProvider = StateProvider<double>((ref) => 0.0);

class AnimatedProgressBar extends ConsumerWidget {
  const AnimatedProgressBar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressBarProvider);
    return Container(
      width: double.infinity,
      height: kScreenPadding * 2,
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(kWidgetRadius),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  color: context.colorScheme.primary,
                  borderRadius: BorderRadius.circular(kWidgetRadius),
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: TextStyle(color: context.colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
