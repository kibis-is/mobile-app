import 'dart:async';
import 'dart:convert';

import 'package:algorand_dart/algorand_dart.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:kibisis/constants/avm.dart';
import 'package:kibisis/exceptions/avm_application_read_exception.dart';
import 'package:kibisis/models/box_reference.dart';
import 'package:kibisis/models/simulate_transaction_box_reference_result.dart';
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

  /// Creates a method selector be used when creating a call in an application
  /// transaction.
  ///
  /// The method signature is in the form of "arc200_balance_of(address)uint256"
  /// and the returned method selector is a the first 4 bytes of the SHA-512
  /// hash of the method signature.
  ///
  /// **Parameters:**
  /// - [String] [methodSignature]: The method signature to convert.
  ///
  /// **Returns:**
  /// [Uint8List] The method selector.
  ///
  static Uint8List createMethodSelectorFromMethodSignature(String methodSignature) {
    final digest = sha512256.convert(utf8.encode(methodSignature));
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
      createMethodSelectorFromMethodSignature(methodSignature),
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

  Future<String> _getFeeSinkAddress() async {
    Response<dynamic> response;

    if (_feeSinkAddress != null) {
      return _feeSinkAddress!;
    }

    response = await _client.get('/genesis');

    _feeSinkAddress = response.data['fees'];

    return _feeSinkAddress!;
  }

  /// Simulates app call transactions, reads the logs and parses the responses.
  /// This is used to read data from an application.
  ///
  /// **Parameters:**
  /// - [List<SimulateTransactionParam>] [simulateTransactions]: A list of
  /// transactions and an optional auth address.
  ///
  /// **Returns:**
  /// [Future<Map<String, dynamic>>] A list of the simulate transactions result
  /// encoded in message pack.
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
  /// **Returns:**
  /// [String] The application's address.
  ///
  /// **Example:**
  /// ```dart
  /// final contract = BaseContract({ appID: 6779767, algodURL: 'https://some.where.over.the.rainbow' })
  /// final address = contract.address();
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
  /// **Returns:**
  /// [String] The application's account information.
  ///
  /// **Example:**
  /// ```dart
  /// final contract = BaseContract({ appID: 6779767, algodURL: 'https://some.where.over.the.rainbow' })
  /// final accountInformation = await contract.accountInformation();
  /// print(accountInformation.address); // Output: I7F3LRWCPSKURPRQZ3RFEEI2KFJ4TYC7EKSL75YIWH7LJ4FD5DUMIIPRAU
  /// ```
  Future<AccountInformation> accountInformation() async {
    final _address = address();
    final result = await _client.get('/v2/accounts/$_address');

    return AccountInformation.fromJson(result.data!);
  }

  Future<Map<String, dynamic>> createWriteApplicationTransactionMessagePack({
    required String methodSignature,
    required String sender,
    required List<Uint8List> appArgs,
    TransactionParams? suggestedParams,
    String? note,
    List<BoxReference>? boxNames
  }) async {
    final _appArgs = [
      createMethodSelectorFromMethodSignature(methodSignature),
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

  Future<List<BoxReference>> determineBoxReferences({
    required String methodSignature,
    required String sender,
    required List<Uint8List> appArgs,
    String? authAddress,
    TransactionParams? suggestedParams,
  }) async {
    List<SimulateTransactionBoxReferenceResult>? boxes;
    Map<String, dynamic> response;
    Map<String, dynamic> transactionMessagePack;

    try {
      transactionMessagePack = await createWriteApplicationTransactionMessagePack(
        methodSignature: methodSignature,
        sender: sender,
        appArgs: appArgs,
        suggestedParams: suggestedParams,
      );
      response = await _simulateTransactions([SimulateTransactionParam(transactionMessagePack, authAddress: authAddress)]);
    } catch (error) {
      debugPrint('failed to simulate transaction: $error');

      throw AVMApplicationReadException(appID, error.toString());
    }

    if (response['txn-groups'][0].containsKey('failure-message')) {
      throw AVMApplicationReadException(appID, response['txn-groups'][0]['failure-message']);
    }

    boxes = response['txn-groups'][0]['unnamed-resources-accessed']['boxes'];

    if (boxes == null || boxes.isEmpty) {
      return [];
    }

    return boxes.map((value) => BoxReference(
        value.app,
        base64.decode(value.name)
    )).toList();
  }

  /// Calls a read function on the contract using the simulate transactions.
  ///
  /// **Returns:**
  /// [Future<Uint8List?>] The raw response from the read operation or null if
  /// the response was not found.
  ///
  /// **Example:**
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
    String? log;
    Map<String, dynamic> response;
    Map<String, dynamic> transactionMessagePack;

    try {
      transactionMessagePack = await _createReadApplicationTransactionMessagePack(methodSignature: methodSignature, appArgs: appArgs, suggestedParams: suggestedParams);
      response = await _simulateTransactions([SimulateTransactionParam(transactionMessagePack)]);
    } catch (error) {
      debugPrint('failed to simulate transaction: $error');

      throw AVMApplicationReadException(appID, error.toString());
    }

    if (response['txn-groups'][0].containsKey('failure-message')) {
      throw AVMApplicationReadException(appID, response['txn-groups'][0]['failure-message']);
    }

    log = response['txn-groups'][0]['txn-results'][0]['txn-result']['logs']?.removeLast(); // the last log will be the value

    if (log == null) {
      debugPrint('no log found for application "$appID"');

      return null;
    }

    return base64.decode(log) // the log will be encoded in base64
        .sublist(4); // remove the log prefix (first 4 bytes)
  }
}
