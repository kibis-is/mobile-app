import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/providers/storage_provider.dart';

enum FabPosition { left, right }

final fabPositionProvider =
    StateNotifierProvider<FabPositionNotifier, FabPosition>((ref) {
  final storage = ref.watch(storageProvider);
  final initialPosition = storage.getFabPosition() ?? FabPosition.right;
  return FabPositionNotifier(storage, initialPosition);
});

class FabPositionNotifier extends StateNotifier<FabPosition> {
  final StorageService _storage;

  FabPositionNotifier(this._storage, FabPosition state) : super(state);

  void setPosition(FabPosition position) {
    state = position;
    _storage.setFabPosition(position);
  }
}
