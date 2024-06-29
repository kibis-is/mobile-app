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
    return Scaffold(
      backgroundColor: context.colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/kibisis-animated.svg',
              semanticsLabel: 'Kibisis Logo',
              fit: BoxFit.fitHeight,
              height: 100,
              width: 100,
              colorFilter: ColorFilter.mode(
                context.colorScheme.primary,
                BlendMode.srcATop,
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
    );
  }
}
