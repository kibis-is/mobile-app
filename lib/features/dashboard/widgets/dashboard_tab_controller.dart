import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_tab_bar.dart';
import 'package:kibisis/models/asset.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class DashboardTabController extends StatelessWidget {
  const DashboardTabController({
    super.key,
    required this.tabs,
    required this.assets,
  });

  final List<String> tabs;
  final List<AccountAsset> assets;

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
                  AssetsTab(assets: assets),
                  const Center(
                    child: Text('No NFTs'),
                  ),
                  const Center(
                    child: Text('No Activity'),
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

class AssetsTab extends StatelessWidget {
  const AssetsTab({
    super.key,
    required this.assets,
  });

  final List<AccountAsset> assets;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
                style: ButtonStyle(
                  side: MaterialStateProperty.all(
                    BorderSide(color: context.colorScheme.primary),
                  ),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kWidgetRadius),
                    ),
                  ),
                ),
                onPressed: () => GoRouter.of(context).go('/addAsset'),
                child: Row(
                  children: [
                    const Text('Add Asset'),
                    Icon(
                      Icons.add,
                      color: context.colorScheme.primary,
                    ),
                  ],
                )),
            // IconButton(
            //   onPressed: () => GoRouter.of(context).go('/addAsset'),
            //   icon: Icon(
            //     Icons.add,
            //     color: context.colorScheme.primary,
            //   ),
            // ),
          ],
        ),
        Expanded(
          child: assets.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/empty.svg',
                      semanticsLabel: 'Kibisis Logo',
                      fit: BoxFit.fitHeight,
                      width: MediaQuery.of(context).size.width / 4,
                    ),
                    const SizedBox(
                      height: kScreenPadding / 2,
                    ),
                    Text(
                      'No Assets Found',
                      style: context.textTheme.titleMedium,
                    ),
                    const SizedBox(
                      height: kScreenPadding / 2,
                    ),
                    Text(
                      'You have not added any assets. Try adding one now.',
                      style: context.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: kScreenPadding,
                    ),
                    // CustomButton(
                    //   text: "Add",
                    //   prefixIcon: const Icon(Icons.add),
                    //   isOutline: true,
                    //   buttonType: ButtonType.primary,
                    //   onPressed: () {
                    //     GoRouter.of(context).go('/addAsset');
                    //   },
                    // ),
                  ],
                )
              : ListView.separated(
                  itemCount: assets.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    debugPrint('Assets length: ${assets.length}');
                    return ListTile(
                      contentPadding: const EdgeInsets.all(kScreenPadding / 2),
                      leading: SvgPicture.asset(
                        assets[index].image,
                        width: kScreenPadding * 3,
                      ),
                      title: Text(
                        assets[index].name,
                        style: context.textTheme.titleMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        assets[index].subtitle,
                        style: context.textTheme.titleSmall!
                            .copyWith(color: context.colorScheme.onSurface),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox(height: kScreenPadding / 2);
                  },
                ),
        ),
      ],
    );
  }
}
