import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter/material.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/models/select_item.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class CustomDropDown extends StatelessWidget {
  final bool isExpanded;
  final ValueChanged<SelectItem?>? onChanged;
  final List<SelectItem> items;
  final SelectItem? selectedValue;
  final String label;

  const CustomDropDown({
    super.key,
    this.isExpanded = true,
    this.onChanged,
    required this.items,
    this.selectedValue,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topLeft,
      children: [
        _buildDropDownContainer(context),
        _buildLabel(context),
      ],
    );
  }

  Widget _buildDropDownContainer(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(),
      padding: const EdgeInsets.symmetric(horizontal: kScreenPadding / 2),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.transparent,
        ),
        borderRadius: BorderRadius.circular(100.0),
        color: context.colorScheme.surface,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SelectItem>(
          isExpanded: isExpanded,
          value: selectedValue,
          onChanged: onChanged,
          items: items.map((SelectItem item) {
            return DropdownMenuItem<SelectItem>(
              value: item,
              child: Row(
                children: [
                  if (item.icon is Widget)
                    item.icon
                  else
                    AppIcons.icon(
                      icon: item.icon,
                      color: context.colorScheme.onBackground,
                      size: AppIcons.medium,
                    ),
                  const SizedBox(width: kScreenPadding / 2),
                  Flexible(
                    child: EllipsizedText(item.name,
                        ellipsis: '...',
                        type: EllipsisType.end,
                        style: context.textTheme.displaySmall),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context) {
    return Positioned(
      left: 12,
      top: -10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colorScheme.onBackground,
          ),
        ),
      ),
    );
  }
}
