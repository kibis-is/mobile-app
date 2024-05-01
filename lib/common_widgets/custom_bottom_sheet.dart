import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/constants/constants.dart';

Future<dynamic> customBottomSheet({
  required BuildContext context,
  required List<dynamic> items,
  required String header,
  bool isIcon = false,
  bool hasButton = false,
  String? buttonText,
  Function()? onPressed,
}) {
  return showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(kScreenPadding),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(kSizedBoxSpacing),
              child:
                  Text(header, style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(
              height: kScreenPadding,
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: kSizedBoxSpacing),
                      child: Row(
                        children: [
                          isIcon
                              ? Icon(IconData(
                                  int.tryParse(items[index].image) ?? 0xe237,
                                  fontFamily: 'MaterialIcons'))
                              : SvgPicture.asset(
                                  items[index].logoPath,
                                  semanticsLabel: items[index].name,
                                  height: kSizedBoxSpacing * 2,
                                  colorFilter: ColorFilter.mode(
                                      Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                      BlendMode.srcATop),
                                ),
                          const SizedBox(
                            width: kSizedBoxSpacing,
                          ),
                          Text(
                            items[index].name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            hasButton
                ? CustomButton(
                    text: "Add Network",
                    onPressed: () {
                      Navigator.of(context).pop();
                      GoRouter.of(context).go('/addWallet');
                    },
                    isFullWidth: true,
                  )
                : Container(),
          ],
        ),
      );
    },
  );
}
