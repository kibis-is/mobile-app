import 'package:algorand_dart/algorand_dart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/providers/algorand_provider.dart';

final transactionsProvider = FutureProvider.family<List<Transaction>, String>(
    (ref, publicAddress) async {
  final algorandService = ref.watch(algorandServiceProvider);
  return await algorandService.getTransactions(publicAddress);
});
