import 'package:algorand_dart/algorand_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/theme/color_palette.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class AssetsTab extends StatelessWidget {
  const AssetsTab({
    super.key,
    required this.assets,
  });

  final List<AssetHolding> assets;

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
        const SizedBox(
          height: kScreenPadding,
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
                    return Stack(
                      alignment: Alignment.topRight,
                      children: [
                        assets[index].isFrozen
                            ? const Padding(
                                padding: EdgeInsets.all(kScreenPadding / 2),
                                child: Icon(
                                  Icons.ac_unit,
                                  size: kScreenPadding,
                                ),
                              )
                            : Container(),
                        ListTile(
                          horizontalTitleGap: kScreenPadding * 2,
                          leading: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: ColorPalette.voiPurple,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(kScreenPadding),
                              child: SvgPicture.asset(
                                'assets/images/voi-asset-icon.svg',
                                semanticsLabel: 'VOI Logo',
                                width: kScreenPadding,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcATop,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            assets[index].assetId.toString(),
                            style: context.textTheme.titleMedium!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            assets[index].creator ?? 'Unknown',
                            style: context.textTheme.titleSmall!
                                .copyWith(color: context.colorScheme.onSurface),
                          ),
                          trailing: SizedBox(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  assets[index].amount.toString(),
                                  style: context.textTheme.titleSmall?.copyWith(
                                      color: context.colorScheme.secondary),
                                ),
                                const Icon(Icons.arrow_forward_ios),
                              ],
                            ),
                          ),
                        ),
                      ],
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
