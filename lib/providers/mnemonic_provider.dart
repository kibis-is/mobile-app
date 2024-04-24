import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:algorand_dart/algorand_dart.dart';

final mnemonicProvider = FutureProvider<List<String>>((ref) async {
  final algorand = Algorand();
  final account = await algorand.createAccount();
  final List<String> mnemonicWords = await account.seedPhrase;
  //final mnemonic = mnemonicWords.join(' ');
  return mnemonicWords;
});
