import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/features/dashboard/providers/assets_fetched_provider.dart';
import 'package:kibisis/features/dashboard/providers/transactions_provider.dart';
import 'package:kibisis/providers/assets_provider.dart';
import 'package:kibisis/providers/balance_provider.dart';

void invalidateProviders(WidgetRef ref) {
  ref.read(accountDataFetchStatusProvider.notifier).setFetched(false);
  ref.invalidate(balanceProvider);
  ref.invalidate(assetsProvider);
  ref.invalidate(transactionsProvider);
}
