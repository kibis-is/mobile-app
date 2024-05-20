// Define a provider for managing loading state
import 'package:flutter_riverpod/flutter_riverpod.dart';

final loadingProvider =
    StateNotifierProvider<LoadingStateNotifier, bool>((ref) {
  return LoadingStateNotifier();
});

class LoadingStateNotifier extends StateNotifier<bool> {
  LoadingStateNotifier() : super(false);

  void startLoading() => state = true;
  void stopLoading() => state = false;
}
