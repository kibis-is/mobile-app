import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

final walletConnectProvider = Provider<Web3Wallet>((ref) {
  return initializeWalletKit();
});

Future<Web3Wallet> initializeWalletKit() async {
  final wcClient = await Web3Wallet.createInstance(
    projectId: '20cac84b2470041bd5936fd157f814f6',
    relayUrl: 'wss://relay.walletconnect.com',
    metadata: const PairingMetadata(
      name: 'Kibisis',
      description: 'Kibisis Mobile Wallet',
      url: 'https://kibis.is',
      icons: ['https://kibis.is/images/logo-dark.svg'],
      redirect: Redirect(
        native: 'mywallet://',
        universal: 'https://kibis.is/app',
      ),
    ),
  );
  return wcClient;
}
