import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/algorand_provider.dart';

final balanceProvider = Provider<double>((ref) {
  return ref.watch(balanceNotifierProvider).asData?.value ?? 0.0;
});

final balanceNotifierProvider =
    StateNotifierProvider<BalanceNotifier, AsyncValue<double>>((ref) {
  final publicAddress = ref.watch(accountProvider).account?.publicAddress ?? '';
  return BalanceNotifier(ref, publicAddress);
});

class BalanceNotifier extends StateNotifier<AsyncValue<double>> {
  final Ref ref;
  final String publicAddress;

  BalanceNotifier(this.ref, this.publicAddress)
      : super(const AsyncValue.loading()) {
    _fetchBalance();
  }

  Future<void> _fetchBalance() async {
    try {
      final balanceStr = await ref
          .read(algorandServiceProvider)
          .getAccountBalance(publicAddress);
      final balance = double.tryParse(balanceStr) ?? 0.0;
      if (mounted) {
        state = AsyncValue.data(balance);
      }
    } catch (e) {
      if (mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }
}
