class Wallet {
  final String name;
  final String address;
  final String network;
  final double balance;
  final String privateKey;
  final List<String> assets;

  Wallet({
    required this.name,
    required this.address,
    required this.network,
    required this.balance,
    required this.privateKey,
    required this.assets,
  });
}
