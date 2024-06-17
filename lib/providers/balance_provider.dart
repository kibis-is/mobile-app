import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/providers/algorand_provider.dart';
import 'package:algorand_dart/algorand_dart.dart';

final balanceProvider =
    StateNotifierProvider<BalanceNotifier, AsyncValue<String>>((ref) {
  return BalanceNotifier(ref);
});

class BalanceNotifier extends StateNotifier<AsyncValue<String>> {
  final Ref ref;

  BalanceNotifier(this.ref) : super(const AsyncValue.loading());

  Future<void> getBalance(String publicAddress) async {
    final algorandService = ref.read(algorandServiceProvider);

    if (publicAddress.isEmpty) {
      state = const AsyncValue.data('0');
      return;
    }
    try {
      final balance = await algorandService.getAccountBalance(publicAddress);
      state = AsyncValue.data(balance);
    } on AlgorandException {
      state = AsyncValue.error('Failed to fetch balance', StackTrace.current);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
