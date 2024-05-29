import 'package:flutter_riverpod/flutter_riverpod.dart';

final isDarkModeProvider = StateProvider<bool>((ref) => true);

final enablePasswordLockProvider = StateProvider<bool>((ref) => true);

final isDebugLoggingProvider = StateProvider<bool>((ref) => false);
final allowMainNetNetworksProvider = StateProvider<bool>((ref) => false);
final allowBetaNetNetworksProvider = StateProvider<bool>((ref) => false);
final allowDIDTokenFormatInAddressSharingProvider =
    StateProvider<bool>((ref) => false);
