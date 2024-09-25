import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final orientationProvider =
    StateNotifierProvider<OrientationNotifier, OrientationState>(
  (ref) => OrientationNotifier(),
);

class OrientationState {
  final bool isLandscape;
  final bool isWideScreen;

  OrientationState({
    required this.isLandscape,
    required this.isWideScreen,
  });

  factory OrientationState.fromMediaQuery(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final shortestSide = mediaQuery.size.shortestSide;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final isWideScreen = shortestSide > 600;

    return OrientationState(
      isLandscape: isLandscape,
      isWideScreen: isWideScreen,
    );
  }
}

class OrientationNotifier extends StateNotifier<OrientationState> {
  OrientationNotifier()
      : super(OrientationState(isLandscape: false, isWideScreen: false));

  void update(BuildContext context) {
    state = OrientationState.fromMediaQuery(context);
  }
}
