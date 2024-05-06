class MockWallet {
  final String name;
  final String address;
  final String network;
  final double balance;
  final String privateKey;
  final List<String> assets;

  MockWallet({
    required this.name,
    required this.address,
    required this.network,
    required this.balance,
    required this.privateKey,
    required this.assets,
  });
}
