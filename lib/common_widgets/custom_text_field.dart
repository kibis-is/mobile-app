import 'package:flutter/material.dart';
import 'package:kibisis/constants/constants.dart';

class CustomTextField extends StatelessWidget {
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
    this.validator,
    this.onChanged,
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
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autocorrect: autoCorrect,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      maxLength: maxLength,
      maxLines: maxLines,
      enabled: isEnabled,
      textAlign: TextAlign.left,
      controller: controller,
      obscureText: isObscureText,
      decoration: InputDecoration(
        counterText: "",
        prefixIcon: leadingIcon != null ? Icon(leadingIcon) : null,
        labelText: labelText,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: kScreenPadding, vertical: kScreenPadding / 2),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        errorText: errorText.isEmpty
            ? null
            : controller.text.isNotEmpty
                ? null
                : errorText,
        suffixIcon: isObscureText
            ? IconButton(
                icon: const Icon(Icons.visibility),
                onPressed: () {},
              )
            : null,
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }
}
