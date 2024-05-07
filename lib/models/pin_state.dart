class PinState {
  final String pin;
  final String error;

  PinState({this.pin = '', this.error = ''});

  PinState copyWith({String? pin, String? error}) {
    return PinState(
      pin: pin ?? this.pin,
      error: error ?? this.error,
    );
  }
}
