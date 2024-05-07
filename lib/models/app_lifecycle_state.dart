class AppLifecycleState {
  final DateTime? lastPausedTime;
  final Duration timeoutDuration;

  AppLifecycleState({this.lastPausedTime, required this.timeoutDuration});

  AppLifecycleState copyWith({
    DateTime? lastPausedTime,
    Duration? timeoutDuration,
  }) {
    return AppLifecycleState(
      lastPausedTime: lastPausedTime ?? this.lastPausedTime,
      timeoutDuration: timeoutDuration ?? this.timeoutDuration,
    );
  }
}
