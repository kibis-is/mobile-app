import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/common_widgets/custom_tab_bar.dart';
import 'package:kibisis/common_widgets/models/asset.dart';
import 'package:kibisis/constants/constants.dart';

class DashboardTabController extends StatelessWidget {
  const DashboardTabController({
    super.key,
    required this.tabs,
    required this.assets,
  });

  final List<String> tabs;
  final List<Asset> assets;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Container(
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTabBar(
              tabs: tabs,
            ),
            const SizedBox(
              height: kScreenPadding,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          itemCount: assets.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return ListTile(
                              contentPadding:
                                  const EdgeInsets.all(kScreenPadding / 2),
                              leading: SvgPicture.asset(
                                assets[index].image,
                                width: kScreenPadding * 3,
                              ),
                              title: Text(
                                assets[index].name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                assets[index].subtitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return const SizedBox(height: kScreenPadding / 2);
                          },
                        ),
                      ),
                      CustomButton(
                          text: "Add",
                          isFullWidth: true,
                          onPressed: () {
                            GoRouter.of(context).go('/addAsset');
                          }),
                    ],
                  ),
                  const Center(
                    child: Text('NFTs Tab'),
                  ),
                  const Center(
                    child: Text('Activity Tab'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
