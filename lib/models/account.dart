import 'package:kibisis/models/mock_wallet.dart';

class Account {
  final String name;
  final String address;
  final String pin;
  final String mnemonic;
  final List<MockWallet> wallets;

  Account(
      {required this.name,
      required this.address,
      required this.pin,
      required this.mnemonic,
      required this.wallets});
}
