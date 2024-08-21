import 'dart:isolate';
import 'package:flutter/services.dart';
// For RootIsolateToken

Future<dynamic> computeIsolate(Future Function() function) async {
  final receivePort = ReceivePort();
  final rootToken =
      RootIsolateToken.instance!; // Get the RootIsolateToken instance
  await Isolate.spawn<_IsolateData>(
    _isolateEntry,
    _IsolateData(
      token: rootToken,
      function: function,
      answerPort: receivePort.sendPort,
    ),
  );
  return await receivePort.first;
}

void _isolateEntry(_IsolateData isolateData) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(
      isolateData.token); // Initialize with the token

  try {
    final answer = await isolateData.function();
    isolateData.answerPort.send(answer);
  } catch (e) {
    isolateData.answerPort.send(e.toString());
  }
}

class _IsolateData {
  final RootIsolateToken token;
  final Function function;
  final SendPort answerPort;

  _IsolateData({
    required this.token,
    required this.function,
    required this.answerPort,
  });
}
