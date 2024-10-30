import 'package:flutter/material.dart';

class MediaQueryHelper {
  final BuildContext context;

  MediaQueryHelper(this.context);

  bool isTablet() {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide > 600 && shortestSide < 900;
  }

  bool isDesktop() {
    return MediaQuery.of(context).size.shortestSide >= 900;
  }

  bool isWideScreen() {
    return MediaQuery.of(context).size.shortestSide > 600;
  }

  bool isLandscape() {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  bool isPortrait() {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  double screenWidth() {
    return MediaQuery.of(context).size.width;
  }

  double screenHeight() {
    return MediaQuery.of(context).size.height;
  }

  List<int> getDynamicFlex() {
    final width = screenWidth();

    if (width >= 900) {
      return [2, 3];
    } else if (width >= 600) {
      return [2, 2];
    } else {
      return [1, 1];
    }
  }
}
