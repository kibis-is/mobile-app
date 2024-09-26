class SimulateTransactionParam {
  final Map<String, dynamic> transactionMessagePack;
  final String? authAddress;

  SimulateTransactionParam(
    this.transactionMessagePack,
    {this.authAddress}
  );
}
