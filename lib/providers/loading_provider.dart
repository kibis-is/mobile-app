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
  Timer? _messageTimer;

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
    state = LoadingState(
      isLoading: true,
      message: message,
      progress: withProgressBar ? 0.0 : null,
      duration: duration,
      fullScreen: fullScreen,
    );

    if (withProgressBar) {
      _startProgress(duration);
    }

    _startMessageRotation(totalTime);
  }

  void _startProgress(int duration) {
    const int stepDuration = 100;
    final double stepProgress = 1.0 / (duration / stepDuration);

    _timer =
        Timer.periodic(const Duration(milliseconds: stepDuration), (timer) {
      if (state.progress! >= 1.0 || !state.isLoading) {
        timer.cancel();
        state = state.copyWith(progress: 1.0);
      } else {
        state = state.copyWith(progress: state.progress! + stepProgress);
      }
    });
  }

  void _startMessageRotation(int totalTime) {
    const int messageInterval = 5000;
    int elapsedTime = 0;

    _messageTimer =
        Timer.periodic(const Duration(milliseconds: messageInterval), (timer) {
      elapsedTime += messageInterval;

      if (elapsedTime >= totalTime || !state.isLoading) {
        timer.cancel();
      } else {
        int messageIndex =
            (elapsedTime ~/ messageInterval) % _followUpMessages.length;
        state = state.copyWith(message: _followUpMessages[messageIndex]);
      }
    });
  }

  void stopLoading() {
    _timer?.cancel();
    _messageTimer?.cancel();
    state = LoadingState(isLoading: false, message: '');
  }

  @override
  void dispose() {
    _timer?.cancel();
    _messageTimer?.cancel();
    super.dispose();
  }
}

final loadingProvider =
    StateNotifierProvider<LoadingStateNotifier, LoadingState>((ref) {
  return LoadingStateNotifier();
});
