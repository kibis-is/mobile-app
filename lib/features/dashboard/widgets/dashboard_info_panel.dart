import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kibisis/common_widgets/custom_bottom_sheet.dart';
import 'package:kibisis/common_widgets/models/menu_item.dart';
import 'package:kibisis/constants/constants.dart';

class DashboardInfoPanel extends StatelessWidget {
  const DashboardInfoPanel({
    super.key,
    required this.networks,
  });

  final List<MenuItem> networks;

  List<MenuItem> get items => [
        MenuItem(
          name: "Copy",
          image: '0xe190',
        ),
        MenuItem(
          name: "Scan",
          image: '0xe4f7',
        ),
        MenuItem(
          name: "Delete",
          image: '0xe1bb',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: Text('Personal',
                    style: Theme.of(context).textTheme.bodyLarge)),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: EllipsizedText(
                      "TESTKHUQASDHASDHASDSDJAFDFSDCSDCSDDJ",
                      type: EllipsisType.middle,
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        customBottomSheet(
                            context: context,
                            items: items,
                            header: "Edit",
                            isIcon: true);
                      },
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(kScreenPadding / 3,
                            kScreenPadding / 3, 0, kScreenPadding / 3),
                        child: Icon(Icons.more_vert),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text('Balance:',
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall!
                      .copyWith(fontWeight: FontWeight.bold)),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  color: Theme.of(context).colorScheme.primary,
                  iconSize: kScreenPadding,
                  onPressed: () {
                    customBottomSheet(
                        context: context,
                        items: [],
                        header: "Info",
                        isIcon: true);
                  },
                ),
                const SizedBox(
                  width: kScreenPadding,
                ),
                Text(
                  "0.999",
                  style: Theme.of(context).textTheme.displaySmall!.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  width: kScreenPadding / 2,
                ),
                SvgPicture.asset(
                  networks[0].image,
                  semanticsLabel: networks[0].name,
                  height: kSizedBoxSpacing / 2 * 3,
                  colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.primary, BlendMode.srcATop),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
