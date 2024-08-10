import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class ConnectivityNotifier extends StateNotifier<bool> {
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityNotifier() : super(true) {
    _subscription =
        Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    bool isConnected = !results.contains(ConnectivityResult.none);
    state = isConnected;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  bool get isConnected => state;
}

final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, bool>(
  (ref) => ConnectivityNotifier(),
);
