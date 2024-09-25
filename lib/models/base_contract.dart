import 'dart:async';
import 'dart:convert';

import 'package:algorand_dart/algorand_dart.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:kibisis/constants/avm.dart';
import 'package:kibisis/exceptions/avm_application_read_exception.dart';
import 'package:kibisis/models/box_reference.dart';
import 'package:kibisis/models/simulate_transaction_param.dart';

class BaseContract {
  // private variables
  final Dio _client;
  String? _feeSinkAddress;

  // public variables
  final BigInt appID;

  BaseContract({
    required this.appID,
    required String algodURL,
    String? algodToken,
  }) : _client = Dio() {
    _client.options.baseUrl = algodURL;

    if (algodToken != null) {
      _client.options.headers = {
        ALGOD_API_TOKEN_HEADER_NAME: algodToken,
      };
    }
  }

  /// public static functions

  static Uint8List convertAddressToAppArg(String address) {
    return Address.fromAlgorandAddress(address: address).toBytes();
  }

  static Uint8List convertStringToAppArg(String value) {
    return Uint8List.fromList(utf8.encode(value));
  }

  static Uint8List convertUintToAppArg(BigInt value) {
    return BigIntEncoder.encodeUint64(value);
  }

  /// Parses a Base64 encoded address application argument and parses it into
  /// an address string.
  ///
  /// Returns the parsed address string.
  ///
  /// Example:
  /// ```dart
  /// final result = BaseContract.parseBase64EncodedAddressArg('Q1m4i0CnN5wlq6OSXbWWqrvhDXvyawo/Ru/2Tb8cfT4=');
  /// print(result); // Output: I7F3LRWCPSKURPRQZ3RFEEI2KFJ4TYC7EKSL75YIWH7LJ4FD5DUMIIPRAU
  /// ```
  static String parseBase64EncodedAddressArg(String arg)  {
    final decodedArg = base64.decode(arg);

    return Address.encodeAddress(decodedArg);
  }

  /// Parses a Base64 encoded string application argument and parses it into a
  /// string.
  ///
  /// Returns the parsed string.
  ///
  /// Example:
  /// ```dart
  /// final result = BaseContract.parseBase64EncodedStringArg('2nAluQ==');
  /// print(result); // Output: arc200_transfer
  /// ```
  static String parseBase64EncodedStringArg(String arg)  {
    final decodedArg = base64.decode(arg);

    return utf8.decode(decodedArg);
  }

  /// Parses a Base64 encoded application uint argument and parse it to a BigInt.
  ///
  /// Returns the parsed BigInt value.
  ///
  /// Example:
  /// ```dart
  /// final result = BaseContract.parseBase64EncodedUintArg('AAAAAAAAA+g=');
  /// print(result); // Output: 1000
  /// ```
  static BigInt parseBase64EncodedUintArg(String arg)  {
    final decodedArg = base64.decode(arg);

    return BigIntEncoder.decodeUint64(decodedArg);
  }

  static Uint8List parseMethodSignature(String method) {
    final digest = sha512256.convert(utf8.encode(method));
    final hashBytes = Uint8List.fromList(digest.bytes);

    // get the first 4 bytes of the hashed method signature
    return hashBytes.sublist(0, 4);
  }

  /// private functions

  Future<Map<String, dynamic>> _createReadApplicationTransactionMessagePack({
    required String methodSignature,
    required List<Uint8List> appArgs,
    TransactionParams? suggestedParams
  }) async {
    final _appArgs = [
      parseMethodSignature(methodSignature),
      ...appArgs,
    ];
    final transaction = await (ApplicationCallTransactionBuilder()
        ..sender = Address.fromAlgorandAddress(address: await _getFeeSinkAddress()) // we need an address that contains a balance
        ..applicationId = appID.toInt()
        ..arguments = _appArgs
        ..suggestedParams = suggestedParams ?? await _transactionParams())
      .build();

    return transaction.toMessagePack();
  }

  Future<Map<String, dynamic>> _createWriteApplicationTransactionMessagePack({
    required String methodSignature,
    required String sender,
    required List<Uint8List> appArgs,
    TransactionParams? suggestedParams,
    String? note,
    List<BoxReference>? boxNames
  }) async {
    final _appArgs = [
      parseMethodSignature(methodSignature),
      ...appArgs,
    ];
    final transaction = await (ApplicationCallTransactionBuilder()
        ..sender = Address.fromAlgorandAddress(address: sender)
        ..applicationId = appID.toInt()
        ..arguments = _appArgs
        ..suggestedParams = suggestedParams ?? await _transactionParams()
        ..noteText = note)
      .build();
    final transactionAsMessagePack = transaction.toMessagePack();

    // if we have box references, add them as they are not supported in algorand dart
    if (boxNames != null) {
      transactionAsMessagePack['apbx'] = boxNames.map((value) => {
        'i': value.id,
        'n': value.name,
      });
    }

    return transactionAsMessagePack;
  }

  Future<String> _getFeeSinkAddress() async {
    Response<dynamic> response;
    Map<String, dynamic> genesisMap;

    if (_feeSinkAddress != null) {
      return _feeSinkAddress!;
    }

    response = await _client.get('/v2/genesis');
    genesisMap = json.decode(response.data.toString());

    _feeSinkAddress = genesisMap['fees'];

    return _feeSinkAddress!;
  }

  /// Simulates app call transactions, reads the logs and parses the responses.
  /// This is used to read data from an application.
  ///
  /// Returns the result from a simulate transactions request.
  ///
  Future<Map<String, dynamic>> _simulateTransactions(List<SimulateTransactionParam> simulateTransactions) async {
    final transactions = simulateTransactions.map((value) => value.transactionMessagePack).toList();
    final Map<String, dynamic> request = {
      'allow-empty-signatures': true,
      'allow-unnamed-resources': true,
      'txn-groups': [{
        'txns': List.generate(transactions.length, (index) {
          final value = transactions[index];
          final authAddress = simulateTransactions[index].authAddress;

          return {
            'txn': value,
            if (authAddress != null) 'sgnr': Address.fromAlgorandAddress(address: authAddress).publicKey, // add the auth address as the signer
          };
        }),
      }],
    };
    final encodedRequest = Encoder.encodeMessagePack(request);
    final result = await _client.request<Map<String, dynamic>>('/v2/transactions/simulate',
      queryParameters: {},
      options: Options(
        method: 'POST',
        headers: <String, dynamic>{r'Content-Type': 'application/x-binary'},
        extra: {},
        contentType: 'application/x-binary',
      ),
      data: Stream.fromIterable(encodedRequest.map((i) => [i]))
    );

    return result.data!;
  }

  Future<TransactionParams> _transactionParams() async {
    final result = await _client.get('/v2/transactions/params');

    return TransactionParams.fromJson(result.data!);
  }

  /// public functions

  /// Gets the application's address.
  ///
  /// Returns the application's address.
  ///
  /// Example:
  /// ```dart
  /// final contract = BaseContract(...)
  /// final address = contract.applicationAddress();
  /// print(address); // Output: I7F3LRWCPSKURPRQZ3RFEEI2KFJ4TYC7EKSL75YIWH7LJ4FD5DUMIIPRAU
  /// ```
  String address() {
    final prefix = utf8.encode(APP_ID_PREFIX);
    final buffer = Uint8List.fromList([
      ...prefix,
      ...BigIntEncoder.encodeUint64(appID),
    ]);
    final digest = sha512256.convert(buffer as List<int>);

    return Address.encodeAddress(Uint8List.fromList(digest.bytes));
  }

  /// Gets the application's account information.
  ///
  /// Returns the application's account information.
  ///
  /// Example:
  /// ```dart
  /// final contract = BaseContract(...)
  /// final accountInformation = await contract.accountInformation();
  /// print(accountInformation.address); // Output: I7F3LRWCPSKURPRQZ3RFEEI2KFJ4TYC7EKSL75YIWH7LJ4FD5DUMIIPRAU
  /// ```
  Future<AccountInformation> accountInformation() async {
    final _address = address();
    final result = await _client.get('/v2/accounts/$_address');

    return AccountInformation.fromJson(result.data!);
  }

  /// Calls a read function on the contract using the simulate transactions.
  ///
  /// Returns the raw response or null if the response was not found.
  ///
  /// Example:
  /// ```dart
  /// final contract = BaseContract(...)
  /// final result = await contract.readByMethodSignature(methodSignature: 'arc200_balanceOf(address)uint256', appArgs: []);
  /// print(result); // Output: 1000
  /// ```
  Future<Uint8List?> readByMethodSignature({
    required String methodSignature,
    required List<Uint8List> appArgs,
    TransactionParams? suggestedParams
  }) async {
    Uint8List? log;
    Map<String, dynamic> response;
    Map<String, dynamic> transactionMessagePack;

    try {
      transactionMessagePack = await _createReadApplicationTransactionMessagePack(methodSignature: methodSignature, appArgs: appArgs, suggestedParams: suggestedParams);
      response = await _simulateTransactions([SimulateTransactionParam(transactionMessagePack)]);
    } catch (error) {
      debugPrint('failed to simulate transaction: $error');

      rethrow;
    }

    if (response['txn-groups']['failure-message']) {
      throw AVMApplicationReadException(appID, response['txn-groups']['failure-message']);
    }

    log = response['txn-groups'][0]?['txn-results']['txn-result']['logs']?.removeLast();

    if (log == null) {
      debugPrint('no log found for application "$appID"');

      return null;
    }

    return log;
  }
}
