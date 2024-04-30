import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:algorand_dart/algorand_dart.dart';

class MnemonicNotifier extends StateNotifier<List<String>> {
  final Algorand algorand;

  MnemonicNotifier(this.algorand) : super([]) {
    generateMnemonic();
  }

  Future<void> generateMnemonic() async {
    final account = await algorand.createAccount();
    state = await account.seedPhrase;
  }

  String getConcatenatedMnemonic() {
    return state.join(' ');
  }
}

final algorandProvider = Provider<Algorand>((ref) => Algorand());

final mnemonicProvider =
    StateNotifierProvider<MnemonicNotifier, List<String>>((ref) {
  return MnemonicNotifier(ref.watch(algorandProvider));
});
