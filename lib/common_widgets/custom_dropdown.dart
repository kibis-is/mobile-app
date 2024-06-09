import 'package:flutter/material.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class SelectItem {
  final String name;
  final String value;
  final String icon;

  SelectItem({required this.name, required this.value, required this.icon});
}

class CustomDropDown extends StatelessWidget {
  final bool isExpanded;
  final ValueChanged<SelectItem?> onChanged;
  final List<SelectItem> items;
  final SelectItem? selectedValue;
  final String label;

  const CustomDropDown({
    super.key,
    this.isExpanded = true,
    required this.onChanged,
    required this.items,
    this.selectedValue,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none, // Allows the label to position outside the box
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
      padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
      decoration: BoxDecoration(
        border: Border.all(
          color: context.colorScheme.onBackground,
        ),
        borderRadius: BorderRadius.circular(kWidgetRadius),
        color: Theme.of(context).colorScheme.background,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SelectItem>(
          isExpanded: isExpanded,
          value: selectedValue,
          onChanged: onChanged,
          items: items.map((SelectItem item) {
            return DropdownMenuItem<SelectItem>(
              value: item,
              child: Text(item.name),
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
        color: Theme.of(context).colorScheme.background,
        child: Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
