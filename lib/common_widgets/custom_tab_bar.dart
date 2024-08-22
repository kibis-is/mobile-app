import 'package:flutter/material.dart';
import 'package:kibisis/common_widgets/custom_tab.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class CustomTabBar extends StatelessWidget {
  const CustomTabBar({
    super.key,
    required this.tabs,
  });

  final List<String> tabs;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      tabAlignment: TabAlignment.start,
      isScrollable: true,
      dividerHeight: 0,
      indicator: const BoxDecoration(),
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorWeight: 0,
      overlayColor: MaterialStateProperty.all(Colors.transparent),
      labelPadding: const EdgeInsets.only(right: kScreenPadding / 2),
      padding: EdgeInsets.zero,
      indicatorPadding: EdgeInsets.zero,
      labelStyle: TextStyle(
          fontSize: context.textTheme.labelLarge!.fontSize,
          fontWeight: FontWeight.bold),
      tabs: [
        for (var i in tabs) CustomTab(text: i),
      ],
    );
  }
}
