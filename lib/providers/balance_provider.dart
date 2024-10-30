import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/algorand_provider.dart';

final balanceProvider =
    StateNotifierProvider<BalanceNotifier, AsyncValue<double>>((ref) {
  final publicAddress = ref.watch(accountProvider).account?.address ?? '';
  return BalanceNotifier(ref, publicAddress);
});

class BalanceNotifier extends StateNotifier<AsyncValue<double>> {
  final Ref ref;
  final String publicAddress;
  Timer? _timer;

  BalanceNotifier(this.ref, this.publicAddress)
      : super(const AsyncValue.loading()) {
    _startOrResetTimer();
  }

  void _startOrResetTimer() {
    _timer?.cancel();
    _timer =
        Timer.periodic(const Duration(seconds: 30), (_) => _fetchBalance());
    _fetchBalance();
  }

  Future<void> _fetchBalance() async {
    debugPrint('Fetching balance...');
    try {
      final balanceStr = await ref
          .read(algorandServiceProvider)
          .getAccountBalance(publicAddress);
      final balance = double.tryParse(balanceStr) ?? 0.0;
      if (mounted) {
        state = AsyncValue.data(balance);
      }
    } catch (e, stackTrace) {
      if (mounted) {
        state = AsyncValue.error(e, stackTrace);
      }
    }
  }

  void manualFetchBalance() {
    _startOrResetTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void reset() {
    state = const AsyncValue.data(0.0);
  }
}
