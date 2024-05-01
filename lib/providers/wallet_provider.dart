import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/models/wallet.dart';

final walletProvider = Provider<WalletNotifier>((ref) {
  return WalletNotifier();
});

class WalletNotifier extends StateNotifier<List<Wallet>> {
  WalletNotifier() : super([]);

  List<Wallet> getWallets() {
    List<Wallet> wallets = [
      Wallet(
        name: 'Kibisis Wallet',
        address: 'JJRKNG3R5P5NWEKCCZVWW6CCY4DW6JXILRSCAUYI64XMQVXZAMH3H5LJ5U',
        network: 'VOI',
        balance: 0.1231,
        privateKey:
            'E9873D79C6D87DC0FB6A5778633389F4453213303DA61F20BD67FC233AA33262',
        assets: [],
      ),
      Wallet(
        name: 'Helios Wallet',
        address: 'K5PXFZZD4Y5G4HMQKZ5GKTQL4XDS7MF55JGFC6V4XQK9EGCQTZUG9K7UCI',
        network: 'VOI',
        balance: 0.4567,
        privateKey:
            'B8763D79C6D87DC0FA6A5778633389F4453213303DA61F20BD67FC233AA332AB',
        assets: [],
      ),
      Wallet(
        name: 'Argo Wallet',
        address: '6YVZT3R4MYSND3XXK4YJ5UUX3R2ZLCV7LIPKDGXV46QVNEJZWBAB6F5L5Q',
        network: 'VOI',
        balance: 0.8910,
        privateKey:
            'C9874E79A6D87DC0FB6B5789733490F5564213414EB62F30CE78GD244BB4433C',
        assets: [],
      ),
      Wallet(
        name: 'Prometheus Wallet',
        address: 'XILRD5TI7GYNT4SMXFJVA6F4E2SC3LD2ABJH2BN4TAG7C6JQY4ACMQUZRU',
        network: 'VOI',
        balance: 0.2345,
        privateKey:
            'D9884F80D7E98ED1FC7C67997445A1G6675324525FC73G41DF89HE355CC5543D',
        assets: [],
      ),
    ];
    return wallets;
  }
}
