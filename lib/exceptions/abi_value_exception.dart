class ABIValueException implements Exception {
  final String message;
  final String name = 'ABIValueException';

  ABIValueException(
      this.message
  );

  @override
  String toString() {
    return '$name: $message';
  }
}
