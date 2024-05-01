import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter/material.dart';
import 'package:kibisis/common_widgets/custom_bottom_sheet.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/models/menu_item.dart';
import 'package:kibisis/models/network.dart';

class DashboardInfoPanel extends StatelessWidget {
  const DashboardInfoPanel({
    super.key,
    required this.networks,
  });

  final List<Network> networks;

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
                  style: Theme.of(context).textTheme.bodyLarge),
            ),
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
      ],
    );
  }
}
