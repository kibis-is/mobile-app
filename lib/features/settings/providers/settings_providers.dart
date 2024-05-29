import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/features/settings/models/timeout.dart';

final isDarkModeProvider = StateProvider<bool>((ref) => true);

final enablePasswordLockProvider = StateProvider<bool>((ref) => true);

final isDebugLoggingProvider = StateProvider<bool>((ref) => false);
final allowMainNetNetworksProvider = StateProvider<bool>((ref) => false);
final allowBetaNetNetworksProvider = StateProvider<bool>((ref) => false);
final allowDIDTokenFormatInAddressSharingProvider =
    StateProvider<bool>((ref) => false);

final lockTimeoutProvider = StateProvider<Timeout>((ref) {
  return Timeout.timeoutList.firstWhere((t) => t.time == 1);
});
