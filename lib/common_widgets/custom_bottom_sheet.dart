import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter/material.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/generated/l10n.dart'; // Import localization
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
    isScrollControlled: true,
    builder: (BuildContext context) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final double maxHeight = constraints.maxHeight * 0.9;
          return Container(
            constraints: BoxConstraints(
              maxHeight: maxHeight,
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: kScreenPadding * 2, vertical: kScreenPadding),
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                _buildHeader(context, header),
                const SizedBox(height: kScreenPadding),
                if (isSingleWidgetMode)
                  singleWidget
                else
                  _buildItemList(context, items!, onPressed!, maxHeight),
                if (hasButton)
                  Padding(
                    padding: const EdgeInsets.only(top: kScreenPadding),
                    child: CustomButton(
                      text: buttonText ?? S.of(context).confirm,
                      onPressed: () {
                        if (buttonOnPressed != null) {
                          buttonOnPressed();
                        }
                        Navigator.of(context).pop();
                      },
                      isFullWidth: true,
                    ),
                  ),
                if (isSingleWidgetMode) const SizedBox(height: kScreenPadding),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _buildHeader(BuildContext context, String header) {
  return Padding(
    padding: const EdgeInsets.all(kSizedBoxSpacing),
    child: EllipsizedText(
      header,
      style:
          context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    ),
  );
}

Widget _buildItemList(
  BuildContext context,
  List<dynamic> items,
  Function(SelectItem) onPressed,
  double maxHeight,
) {
  return ConstrainedBox(
    constraints: BoxConstraints(
      maxHeight: maxHeight * 0.7,
    ),
    child: ListView.builder(
      shrinkWrap: true,
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
            color: context.colorScheme.primary,
          ),
          const SizedBox(width: kSizedBoxSpacing),
          Flexible(
            child: EllipsizedText(
              item.name,
              style: context.textTheme.displayMedium,
            ),
          ),
        ],
      ),
    ),
  );
}
