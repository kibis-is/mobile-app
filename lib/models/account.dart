import 'package:kibisis/models/wallet.dart';

class Account {
  final String name;
  final String address;
  final String pin;
  final String mnemonic;
  final List<Wallet> wallets;

  Account(
      {required this.name,
      required this.address,
      required this.pin,
      required this.mnemonic,
      required this.wallets});
}
