import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class ScannerOverlay extends StatelessWidget {
  final Rect scanWindowRect;

  const ScannerOverlay({required this.scanWindowRect, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ClipPath(
            clipper: _ScanWindowClipper(scanWindowRect),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                color: Colors.black54,
              ),
            ),
          ),
        ),
        Positioned.fromRect(
          rect: scanWindowRect,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: context.colorScheme.primary, width: 4),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScanWindowClipper extends CustomClipper<Path> {
  final Rect scanWindowRect;

  _ScanWindowClipper(this.scanWindowRect);

  @override
  Path getClip(Size size) {
    return Path.combine(
      PathOperation.difference,
      Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
      Path()..addRect(scanWindowRect),
    );
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
