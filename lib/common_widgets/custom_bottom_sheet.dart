import 'package:flutter/material.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/common_widgets/custom_dropdown.dart';
import 'package:kibisis/constants/constants.dart';
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
  Widget? singleWidget, // Optional parameter for a single widget
}) {
  // Determine if we are using a list or a single widget
  final isSingleWidgetMode = singleWidget != null;

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
            if (isSingleWidgetMode)
              singleWidget
            else
              _buildItemList(context, items!,
                  onPressed!), // Use the list if singleWidget is not provided
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
  Function(SelectItem) onPressed,
) {
  return Expanded(
    child: ListView.builder(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return _buildListItem(context, items[index], onPressed);
      },
    ),
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
            style: context.textTheme.titleLarge,
          ),
        ],
      ),
    ),
  );
}
