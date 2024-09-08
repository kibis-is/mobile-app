import 'package:flutter/material.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/models/select_item.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/theme_extensions.dart';

Future<dynamic> customBottomSheet({
  required BuildContext context,
  List<dynamic>? items,
  required String header,
  bool hasButton = false,
  String? buttonText,
  Function(SelectItem)? onPressed,
  VoidCallback? buttonOnPressed,
  Widget? singleWidget,
}) {
  final isSingleWidgetMode = singleWidget != null;

  return showModalBottomSheet(
    context: context,
    isScrollControlled:
        true, // Allows the bottom sheet to shrinkwrap its content
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: kScreenPadding * 2, vertical: kScreenPadding),
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Ensure the column takes only needed space
          children: [
            _buildHeader(context, header),
            const SizedBox(height: kScreenPadding),
            if (isSingleWidgetMode)
              singleWidget
            else
              _buildItemList(context, items!, onPressed!),
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
            if (isSingleWidgetMode) const SizedBox(height: kScreenPadding),
          ],
        ),
      );
    },
  );
}

Widget _buildHeader(BuildContext context, String header) {
  return Padding(
    padding: const EdgeInsets.all(kSizedBoxSpacing),
    child: Text(header, style: context.textTheme.titleMedium),
  );
}

Widget _buildItemList(
  BuildContext context,
  List<dynamic> items,
  Function(SelectItem) onPressed,
) {
  // Removed the Expanded here to allow the ListView to shrinkwrap
  return ListView.builder(
    shrinkWrap: true, // Ensures the ListView takes up only the necessary space
    physics:
        const NeverScrollableScrollPhysics(), // Prevents scrolling inside the sheet
    itemCount: items.length,
    itemBuilder: (BuildContext context, int index) {
      return _buildListItem(context, items[index], onPressed);
    },
  );
}

Widget _buildListItem(
  BuildContext context,
  SelectItem item,
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
          AppIcons.icon(
            icon: item.icon,
            size: kSizedBoxSpacing * 2,
            color: context.colorScheme.onBackground,
          ),
          const SizedBox(width: kSizedBoxSpacing),
          Text(
            item.name,
            style: context.textTheme.displayMedium,
          ),
        ],
      ),
    ),
  );
}
