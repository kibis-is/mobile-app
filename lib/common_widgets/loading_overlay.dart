import 'package:flutter/material.dart';

class LoadingOverlay extends StatefulWidget {
  final bool isLoading;
  final double opacity;
  final Color? color;
  final Widget progressIndicator;
  final Widget child;
  final Duration fadeInDuration;
  final Duration fadeOutDuration;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.opacity = 0.5,
    this.progressIndicator = const CircularProgressIndicator(),
    this.color,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.fadeOutDuration = const Duration(milliseconds: 500),
  });

  @override
  LoadingOverlayState createState() => LoadingOverlayState();
}

class LoadingOverlayState extends State<LoadingOverlay>
    with TickerProviderStateMixin {
  late AnimationController _fadeInController;
  late AnimationController _fadeOutController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _fadeOutAnimation;

  @override
  void initState() {
    super.initState();
    _fadeInController = AnimationController(
      vsync: this,
      duration: widget.fadeInDuration,
    );
    _fadeOutController = AnimationController(
      vsync: this,
      duration: widget.fadeOutDuration,
    );

    _fadeInAnimation = Tween(begin: 0.0, end: 1.0).animate(_fadeInController);
    _fadeOutAnimation = Tween(begin: 1.0, end: 0.0).animate(_fadeOutController);

    if (widget.isLoading) {
      _fadeInController.forward();
    }
  }

  @override
  void didUpdateWidget(LoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isLoading && widget.isLoading) {
      _fadeOutController.stop();
      _fadeInController.forward();
    } else if (oldWidget.isLoading && !widget.isLoading) {
      _fadeInController.stop();
      _fadeOutController.forward();
    }
  }

  @override
  void dispose() {
    _fadeInController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        widget.child,
        AnimatedBuilder(
          animation: widget.isLoading ? _fadeInAnimation : _fadeOutAnimation,
          builder: (context, child) {
            return widget.isLoading || _fadeOutController.isAnimating
                ? FadeTransition(
                    opacity:
                        widget.isLoading ? _fadeInAnimation : _fadeOutAnimation,
                    child: Stack(
                      children: <Widget>[
                        Opacity(
                          opacity: widget.opacity,
                          child: ModalBarrier(
                            dismissible: false,
                            color: widget.color ??
                                Theme.of(context).colorScheme.background,
                          ),
                        ),
                        Center(child: widget.progressIndicator),
                      ],
                    ),
                  )
                : const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
