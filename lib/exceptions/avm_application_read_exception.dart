class AVMApplicationReadException implements Exception {
  final BigInt appIndex;
  final String message;
  final String name = 'AVMApplicationReadException';

  AVMApplicationReadException(
      this.appIndex,
      this.message
  );

  @override
  String toString() {
    return '$name: $message';
  }
}
