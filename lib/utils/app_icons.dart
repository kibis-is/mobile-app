import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIcons {
  // Define sizes
  static const double small = 16.0;
  static const double medium = 24.0;
  static const double large = 32.0;

  // Static IconData examples
  static const IconData arrowRight = Icons.arrow_forward_ios_rounded;
  static const IconData freeze = Icons.ac_unit_rounded;
  static const IconData widget = Icons.widgets_rounded;
  static const IconData copy = Icons.copy_rounded;
  static const IconData time = Icons.access_time_rounded;
  static const IconData showPassword = Icons.visibility_rounded;
  static const IconData hidePassword = Icons.visibility_off_rounded;
  static const IconData cross = Icons.clear_rounded;
  static const IconData refresh = Icons.refresh_rounded;
  static const IconData backspace = Icons.backspace_rounded;
  static const IconData edit = Icons.edit_rounded;
  static const IconData info = Icons.info_rounded;
  static const IconData settings = Icons.settings_rounded;
  static const IconData wallet = Icons.account_balance_wallet_rounded;
  static const IconData add = Icons.add_rounded;
  static const IconData verticalDots = Icons.more_vert_rounded;
  static const IconData arrowDropdown = Icons.arrow_drop_down_rounded;
  static const IconData arrowDropup = Icons.arrow_drop_up_rounded;
  static const IconData paste = Icons.paste_rounded;
  static const IconData share = Icons.share_rounded;
  static const IconData error = Icons.error_rounded;
  static const IconData general = Icons.settings_rounded;
  static const IconData security = Icons.security_rounded;
  static const IconData appearance = Icons.palette_rounded;
  static const IconData sessions = Icons.insert_link_rounded;
  static const IconData advanced = Icons.build_rounded;
  static const IconData about = Icons.info_rounded;
  static const IconData send = Icons.send_rounded;
  static const IconData asset = Icons.monetization_on_rounded;
  static const IconData scan = Icons.qr_code_scanner_rounded;
  static const IconData addAccount = Icons.person_add_rounded;
  static const IconData importAccount = Icons.import_export_rounded;

  static const String svgBasePath = 'assets/images/';

  static const String voiIcon = 'voi-asset-icon';
  static const String algorandIcon = 'algorand-logo';

  static Color? defaultColor;

  // Initialize default color (call this once during app initialization)
  static void initializeDefaultColor(BuildContext context) {
    defaultColor = Theme.of(context).colorScheme.onSurface;
  }

  // Function to get Icon or SVG with a shorter method name
  static Widget icon({
    required dynamic icon,
    double size = medium,
    Color? color,
  }) {
    final effectiveColor = color ?? defaultColor ?? Colors.black;

    if (icon is IconData) {
      return Icon(
        icon,
        size: size,
        color: effectiveColor,
      );
    } else if (icon is String) {
      try {
        return SvgPicture.asset(
          '$svgBasePath$icon.svg',
          height: size,
          colorFilter: ColorFilter.mode(effectiveColor, BlendMode.srcATop),
        );
      } catch (e) {
        debugPrint('Error loading SVG: $e');
        return Icon(Icons.error, size: size, color: effectiveColor);
      }
    } else {
      throw ArgumentError(
          'Icon must be either IconData or a String path to SVG.');
    }
  }
}