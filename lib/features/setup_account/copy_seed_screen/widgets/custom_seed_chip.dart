import 'package:flutter/material.dart';
import 'package:kibisis/constants/constants.dart';

class CustomSeedChip extends StatelessWidget {
  final String word;
  final int index;

  const CustomSeedChip({
    super.key,
    required this.word,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width / 2) - 20,
      padding: const EdgeInsets.symmetric(
          vertical: kScreenPadding / 4, horizontal: kScreenPadding / 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(kWidgetRadius),
      ),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Center(
            child: Text(
              word,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: kScreenPadding / 2),
            child: Text(
              (index + 1).toString(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).disabledColor,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
