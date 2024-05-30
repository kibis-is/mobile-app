import 'package:flutter/material.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class AnimatedDots extends StatefulWidget {
  const AnimatedDots({super.key});

  @override
  AnimatedDotsState createState() => AnimatedDotsState();
}

class AnimatedDotsState extends State<AnimatedDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _dotCount;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _dotCount = IntTween(begin: 1, end: 3).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dotCount,
      builder: (context, child) {
        String dots = '.' * _dotCount.value;
        return Text(
          'Init$dots',
          style: context.textTheme.bodySmall
              ?.copyWith(color: context.colorScheme.onBackground),
        );
      },
    );
  }
}
