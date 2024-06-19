import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/algorand_provider.dart';
import 'package:algorand_dart/algorand_dart.dart';

final balanceProvider =
    StateNotifierProvider<BalanceNotifier, AsyncValue<String>>((ref) {
  final publicAddress = ref.watch(accountProvider).account?.publicAddress ?? '';
  return BalanceNotifier(ref, publicAddress);
});

class BalanceNotifier extends StateNotifier<AsyncValue<String>> {
  final Ref ref;
  final String publicAddress;

  BalanceNotifier(this.ref, this.publicAddress)
      : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    await getBalance(publicAddress);
  }

  Future<void> getBalance(String publicAddress) async {
    if (publicAddress.isEmpty) {
      if (mounted) {
        state = const AsyncValue.data('0');
      }
      return;
    }
    try {
      final balance = await ref
          .read(algorandServiceProvider)
          .getAccountBalance(publicAddress);
      if (mounted) {
        state = AsyncValue.data(balance);
      }
    } on AlgorandException catch (e) {
      if (mounted) {
        state = AsyncValue.error(
            'Failed to fetch balance: ${e.message}', StackTrace.current);
      }
    } catch (e) {
      if (mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  @override
  void dispose() {
    debugPrint('BalanceNotifier for $publicAddress is being disposed');
    super.dispose();
  }
}
