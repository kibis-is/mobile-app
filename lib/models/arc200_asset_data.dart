class Arc200AssetData {
  final int contractId;
  final BigInt balance;
  final String name;
  final String symbol;
  final int decimals;

  Arc200AssetData({
    required this.contractId,
    required this.balance,
    required this.name,
    required this.symbol,
    required this.decimals,
  });

  Map<String, dynamic> toJson() => {
        'contractId': contractId,
        'balance': balance.toString(),
        'name': name,
        'symbol': symbol,
        'decimals': decimals,
      };

  factory Arc200AssetData.fromJson(Map<String, dynamic> json) {
    return Arc200AssetData(
      contractId: json['contractId'],
      balance: BigInt.parse(json['balance']),
      name: json['name'],
      symbol: json['symbol'],
      decimals: json['decimals'],
    );
  }
}
