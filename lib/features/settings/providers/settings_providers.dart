import 'package:flutter_riverpod/flutter_riverpod.dart';

final allowMainNetNetworksProvider = StateProvider<bool>((ref) => false);
final allowBetaNetNetworksProvider = StateProvider<bool>((ref) => false);
final allowDIDTokenFormatInAddressSharingProvider =
    StateProvider<bool>((ref) => false);
