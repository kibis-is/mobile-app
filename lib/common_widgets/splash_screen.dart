import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class SplashScreen extends ConsumerWidget {
  final String? message;

  const SplashScreen({super.key, this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size; // Get screen dimensions

    return Material(
      // Use Material instead of Scaffold for minimal rendering
      color: context.colorScheme.background,
      child: SizedBox(
        width: size.width, // Explicit width
        height: size.height, // Explicit height
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min, // Avoid unbounded height
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ConstrainedBox(
                // ignore: prefer_const_constructors
                constraints: BoxConstraints(
                  maxWidth: 100,
                  maxHeight: 100,
                ),
                child: SvgPicture.asset(
                  'assets/images/kibisis-animated.svg',
                  semanticsLabel: 'Kibisis Logo',
                  colorFilter: ColorFilter.mode(
                    context.colorScheme.primary,
                    BlendMode.srcATop,
                  ),
                ),
              ),
              if (message != null)
                Padding(
                  padding: const EdgeInsets.only(top: kScreenPadding),
                  child: Text(
                    message!,
                    style: context.textTheme.displayMedium,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
