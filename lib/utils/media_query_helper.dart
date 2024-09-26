import 'package:flutter/material.dart';

class MediaQueryHelper {
  final BuildContext context;

  MediaQueryHelper(this.context);

  // Specifically targets if the device is a tablet (shortest side > 600 and < 900)
  bool isTablet() {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide > 600 && shortestSide < 900;
  }

  // Specifically targets if the device is a desktop (shortest side > 900)
  bool isDesktop() {
    return MediaQuery.of(context).size.shortestSide >= 900;
  }

  // Determines if the screen is wide (shortest side > 600)
  bool isWideScreen() {
    return MediaQuery.of(context).size.shortestSide > 600;
  }

  // Determines if the screen is in landscape mode
  bool isLandscape() {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  // Determines if the screen is in portrait mode
  bool isPortrait() {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  // Retrieves the screen width
  double screenWidth() {
    return MediaQuery.of(context).size.width;
  }

  // Retrieves the screen height
  double screenHeight() {
    return MediaQuery.of(context).size.height;
  }

  // Determines the flex values based on screen width
  List<int> getDynamicFlex() {
    final width = screenWidth();

    if (width >= 900) {
      return [2, 3]; // Wide screens use 2 : 3 ratio
    } else if (width >= 600) {
      return [2, 2]; // Mid-range screens use 2 : 2 ratio
    } else {
      return [1, 1]; // Fallback for single-column layout, could be adjusted
    }
  }
}
