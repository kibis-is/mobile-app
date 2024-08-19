import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoadingState {
  final bool isLoading;
  final String message;
  final double? progress;
  final int duration;
  final bool fullScreen;

  LoadingState({
    required this.isLoading,
    required this.message,
    this.progress,
    this.duration = 0,
    this.fullScreen = false,
  });

  LoadingState copyWith({
    bool? isLoading,
    String? message,
    double? progress,
    int? duration,
    bool? fullScreen,
  }) {
    return LoadingState(
      isLoading: isLoading ?? this.isLoading,
      message: message ?? this.message,
      progress: progress ?? this.progress,
      duration: duration ?? this.duration,
      fullScreen: fullScreen ?? this.fullScreen,
    );
  }
}

class LoadingStateNotifier extends StateNotifier<LoadingState> {
  Timer? _timer;

  // Predefined follow-up messages
  final List<String> _followUpMessages = [
    "Almost there",
    "Hang in there",
    "Just a bit more",
    "You're doing great",
    "Nearly done",
    "Thanks for waiting",
  ];

  LoadingStateNotifier() : super(LoadingState(isLoading: false, message: ''));

  void startLoading({
    required String message,
    bool withProgressBar = false,
    int duration = 5000,
    int totalTime = 30000,
    bool fullScreen = false,
  }) {
    // Cancel any existing timers
    _cancelTimers();

    state = LoadingState(
      isLoading: true,
      message: message,
      progress: withProgressBar ? 0.0 : null,
      duration: duration,
      fullScreen: fullScreen,
    );

    _startProgressAndMessageRotation(withProgressBar, duration, totalTime);
  }

  void _startProgressAndMessageRotation(
      bool withProgressBar, int duration, int totalTime) {
    const int stepDuration = 100;
    const int messageInterval = 5000;
    double stepProgress = withProgressBar ? 1.0 / (duration / stepDuration) : 0;
    int elapsedTime = 0;

    _timer =
        Timer.periodic(const Duration(milliseconds: stepDuration), (timer) {
      elapsedTime += stepDuration;

      // Update progress if applicable
      if (withProgressBar && state.progress != null) {
        double newProgress = state.progress! + stepProgress;
        if (newProgress >= 1.0 || !state.isLoading) {
          state = state.copyWith(progress: 1.0);
          _cancelTimers();
          return;
        } else {
          state = state.copyWith(progress: newProgress);
        }
      }

      // Update message rotation
      if (elapsedTime % messageInterval == 0) {
        int messageIndex =
            (elapsedTime ~/ messageInterval) % _followUpMessages.length;
        state = state.copyWith(message: _followUpMessages[messageIndex]);
      }

      // Stop timers after total time or if loading has stopped
      if (elapsedTime >= totalTime || !state.isLoading) {
        _cancelTimers();
      }
    });
  }

  void stopLoading() {
    _cancelTimers();
    state = state.copyWith(isLoading: false, message: '', progress: null);
  }

  void _cancelTimers() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }
}

final loadingProvider =
    StateNotifierProvider<LoadingStateNotifier, LoadingState>((ref) {
  return LoadingStateNotifier();
});
