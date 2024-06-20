import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/common_widgets/custom_dropdown.dart';
import 'package:kibisis/constants/constants.dart';

final selectedAssetProvider =
    StateNotifierProvider<SelectedAssetNotifier, SelectItem?>((ref) {
  return SelectedAssetNotifier();
});

class SelectedAssetNotifier extends StateNotifier<SelectItem?> {
  SelectedAssetNotifier() : super(null);

  void selectAsset({
    required List<SelectItem> items,
    required int? assetId,
    required SendTransactionScreenMode mode,
  }) {
    if (items.isEmpty) {
      state = SelectItem(name: 'No Items', value: "-1", icon: '0xe3af');
      return;
    }
    if (mode == SendTransactionScreenMode.payment) {
      state = items[0];
    } else if (mode == SendTransactionScreenMode.asset) {
      state = items.firstWhere(
        (item) => item.value == assetId.toString(),
        orElse: () => items[0],
      );
    } else {
      state = items[0];
    }
  }

  void setAsset(SelectItem asset) {
    state = asset;
  }
}
