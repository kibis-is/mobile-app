import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/constants/constants.dart';

class CustomTextField extends ConsumerWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    this.labelText = '',
    this.errorText = '',
    this.isEnabled = true,
    this.leadingIcon,
    this.isObscureText = false,
    this.autoCorrect = true,
    this.textInputAction = TextInputAction.next,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.maxLines = 1,
    this.isPin = false,
  });

  final TextEditingController controller;
  final String labelText;
  final String errorText;
  final bool isEnabled;
  final bool isObscureText;
  final IconData? leadingIcon;
  final bool autoCorrect;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final int? maxLength;
  final int maxLines;
  final bool isPin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      autocorrect: autoCorrect,
      textInputAction: textInputAction,
      keyboardType: isPin ? TextInputType.number : keyboardType,
      maxLength: isPin ? 1 : maxLength,
      maxLines: maxLines,
      enabled: isEnabled,
      textAlign: isPin ? TextAlign.center : TextAlign.center,
      controller: controller,
      obscureText: isObscureText || isPin,
      style: isPin ? Theme.of(context).textTheme.titleLarge : null,
      decoration: InputDecoration(
        counterText: "",
        prefixIcon: isPin
            ? null
            : leadingIcon != null
                ? Icon(leadingIcon)
                : null,
        labelText: isPin ? "-" : labelText,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: kScreenPadding, vertical: kScreenPadding / 2),
        floatingLabelBehavior:
            isPin ? FloatingLabelBehavior.never : FloatingLabelBehavior.auto,
        errorText: errorText.isEmpty
            ? null
            : controller.text.isNotEmpty
                ? null
                : errorText,
        suffixIcon: isPin
            ? null
            : isObscureText
                ? IconButton(
                    icon: const Icon(Icons.visibility),
                    onPressed: () {},
                  )
                : null,
      ),
    );
  }
}
