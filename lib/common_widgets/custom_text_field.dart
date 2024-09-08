import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/settings/appearance/providers/dark_mode_provider.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class CustomTextField extends ConsumerWidget {
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
  final String? errorText;
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
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(isDarkModeProvider);
    final BorderRadius borderRadius = maxLines > 1
        ? BorderRadius.circular(kScreenPadding)
        : BorderRadius.circular(100.0);
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
      style: context.textTheme.displaySmall,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        fillColor: context.colorScheme.surface,
        filled: true,
        counterText: "",
        prefixIcon: leadingIcon != null
            ? Padding(
                padding: const EdgeInsets.only(left: kScreenPadding / 2),
                child: Icon(
                  leadingIcon,
                  size: isSmall ? AppIcons.small : AppIcons.medium,
                  color: context.colorScheme.onSurfaceVariant,
                ),
              )
            : null,
        labelText: labelText,
        labelStyle: TextStyle(
          fontSize: context.textTheme.bodySmall?.fontSize,
          color: context.colorScheme.onSurfaceVariant,
        ),
        contentPadding: EdgeInsets.symmetric(
            horizontal: isSmall ? kScreenPadding / 4 : kScreenPadding,
            vertical: kScreenPadding / 4),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        errorText: errorText?.isEmpty ?? true
            ? null
            : (controller.text.isNotEmpty ? null : errorText),
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: EdgeInsets.only(
                    right: isSmall ? kScreenPadding / 4 : kScreenPadding / 2),
                child: (controller.text.isEmpty)
                    ? null
                    : IconButton(
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
        border: OutlineInputBorder(
          borderRadius: borderRadius,
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(
            color: Colors.transparent,
            width: 0.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(
            color: Colors.transparent,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(
            color: Colors.transparent,
            width: 0.0,
          ),
        ),
      ),
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      onTap: onTap,
    );
  }
}
