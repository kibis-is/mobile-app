import 'package:flutter/material.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/utils/theme_extensions.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class CustomLoadingOverlay extends StatelessWidget {
  final String text;
  final double? percent;
  final bool fullScreen;

  const CustomLoadingOverlay({
    super.key,
    required this.text,
    this.percent,
    this.fullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width / 2;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(kScreenPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kWidgetRadius),
          color: fullScreen
              ? context.colorScheme.background
              : context.colorScheme.surface,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: kScreenPadding),
            Text(
              text,
              style: context.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (percent != null) ...[
              const SizedBox(height: kScreenPadding),
              SizedBox(
                width: width,
                child: LinearPercentIndicator(
                    lineHeight: kScreenPadding,
                    percent: percent!.clamp(0.0, 1.0),
                    backgroundColor: fullScreen
                        ? context.colorScheme.surface
                        : context.colorScheme.background,
                    progressColor: percent!.clamp(0.0, 1.0) >= 1
                        ? context.colorScheme.secondary
                        : context.colorScheme.primary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
