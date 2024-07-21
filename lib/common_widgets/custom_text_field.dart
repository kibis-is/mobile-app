import 'package:flutter/material.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    this.labelText = '',
    this.errorText = '',
    this.isEnabled = true,
    this.leadingIcon,
    this.suffixIcon,
    this.onTrailingPressed,
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
    this.onTap,
    this.isSmall = false,
  });

  final TextEditingController controller;
  final String labelText;
  final String errorText;
  final bool isEnabled;
  final IconData? leadingIcon;
  final IconData? suffixIcon;
  final VoidCallback? onTrailingPressed;
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
  final VoidCallback? onTap;
  final bool isSmall;

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
      style: TextStyle(
          fontSize: isSmall
              ? context.textTheme.bodySmall?.fontSize
              : context.textTheme.bodyMedium?.fontSize),
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        counterText: "",
        prefixIcon: leadingIcon != null
            ? Icon(leadingIcon,
                size: isSmall ? AppIcons.small : AppIcons.medium)
            : null,
        labelText: labelText,
        labelStyle: TextStyle(fontSize: context.textTheme.bodySmall?.fontSize),
        contentPadding: EdgeInsets.symmetric(
            horizontal: isSmall ? kScreenPadding / 4 : kScreenPadding / 2,
            vertical: isSmall ? kScreenPadding / 4 : kScreenPadding / 2),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        errorText: errorText.isEmpty
            ? null
            : (controller.text.isNotEmpty ? null : errorText),
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: EdgeInsets.only(
                    right: isSmall ? kScreenPadding / 4 : kScreenPadding / 2),
                child: IconButton(
                  icon: AppIcons.icon(
                      icon: suffixIcon,
                      size: isSmall ? AppIcons.small : AppIcons.medium),
                  onPressed: onTrailingPressed,
                ),
              )
            : isObscureText
                ? IconButton(
                    icon: AppIcons.icon(
                        icon: AppIcons.showPassword,
                        size: isSmall ? AppIcons.small : AppIcons.medium),
                    onPressed: () {
                      // Typically toggle password visibility
                    },
                  )
                : null,
      ),
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      onTap: onTap,
    );
  }
}
