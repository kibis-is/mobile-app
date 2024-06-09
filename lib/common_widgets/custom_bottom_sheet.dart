import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/common_widgets/custom_dropdown.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/utils/theme_extensions.dart';

Future<dynamic> customBottomSheet({
  required BuildContext context,
  required List<dynamic> items,
  required String header,
  bool isIcon = false,
  bool hasButton = false,
  String? buttonText,
  required Function(SelectItem) onPressed,
  VoidCallback? buttonOnPressed,
}) {
  return showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(kScreenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, header),
            const SizedBox(height: kScreenPadding),
            _buildItemList(context, items, isIcon, onPressed),
            if (hasButton)
              CustomButton(
                text: buttonText ?? "Confirm",
                onPressed: () {
                  if (buttonOnPressed != null) {
                    buttonOnPressed();
                  }
                  Navigator.of(context).pop();
                },
                isFullWidth: true,
              ),
          ],
        ),
      );
    },
  );
}

Widget _buildHeader(BuildContext context, String header) {
  return Padding(
    padding: const EdgeInsets.all(kSizedBoxSpacing),
    child: Text(header, style: context.textTheme.titleLarge),
  );
}

Widget _buildItemList(
  BuildContext context,
  List<dynamic> items,
  bool isIcon,
  Function(SelectItem) onPressed,
) {
  return Expanded(
    child: ListView.builder(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return _buildListItem(context, items[index], isIcon, onPressed);
      },
    ),
  );
}

Widget _buildListItem(
  BuildContext context,
  dynamic item,
  bool isIcon,
  Function(SelectItem) onPressed,
) {
  return InkWell(
    onTap: () {
      onPressed(item);
      Navigator.of(context).pop(item.name);
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: kSizedBoxSpacing),
      child: Row(
        children: [
          isIcon
              ? const Icon(Icons.widgets)
              : SvgPicture.asset(
                  item.icon,
                  semanticsLabel: item.name,
                  height: kSizedBoxSpacing * 2,
                  colorFilter: ColorFilter.mode(
                      context.colorScheme.onBackground, BlendMode.srcATop),
                ),
          const SizedBox(width: kSizedBoxSpacing),
          Text(
            item.name,
            style: context.textTheme.titleLarge,
          ),
        ],
      ),
    ),
  );
}
