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
    this.suffixIcon, // Ensure this is IconData?
    this.onTrailingPressed, // Ensure this is VoidCallback?
    this.isObscureText = false,
    this.autoCorrect = true,
    this.textInputAction = TextInputAction.next,
    this.keyboardType = TextInputType.text,
    this.textAlign = TextAlign.left,
    this.maxLength,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.focusNode,
  });

  final TextEditingController controller;
  final String labelText;
  final String errorText;
  final bool isEnabled;
  final IconData? leadingIcon;
  final IconData? suffixIcon; // Correct Type
  final VoidCallback? onTrailingPressed; // Correct Type
  final bool isObscureText;
  final bool autoCorrect;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final TextAlign textAlign;
  final int? maxLength;
  final int maxLines;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autocorrect: autoCorrect,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      maxLength: maxLength,
      maxLines: maxLines,
      enabled: isEnabled,
      textAlign: textAlign,
      controller: controller,
      focusNode: focusNode,
      obscureText: isObscureText,
      textAlignVertical: TextAlignVertical.top,
      decoration: InputDecoration(
        counterText: "",
        prefixIcon: leadingIcon != null ? Icon(leadingIcon) : null,
        labelText: labelText,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: kScreenPadding, vertical: kScreenPadding / 2),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        errorText: errorText.isEmpty
            ? null
            : (controller.text.isNotEmpty ? null : errorText),
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(right: kScreenPadding / 2),
                child: IconButton(
                  icon: Icon(suffixIcon),
                  onPressed: onTrailingPressed,
                ),
              )
            : isObscureText
                ? IconButton(
                    icon: const Icon(Icons.visibility),
                    onPressed: () {
                      // Typically toggle password visibility
                    },
                  )
                : null,
      ),
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
    );
  }
}
