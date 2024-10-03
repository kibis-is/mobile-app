import 'dart:typed_data';

import 'package:algorand_dart/algorand_dart.dart';
import 'package:kibisis/exceptions/avm_application_read_exception.dart';
import 'package:kibisis/models/abi_address_type.dart';
import 'package:kibisis/models/abi_string_type.dart';
import 'package:kibisis/models/abi_uint_type.dart';
import 'package:kibisis/models/base_contract.dart';
import 'package:kibisis/utils/avm/calculate_box_mbr.dart';
import 'package:kibisis/utils/avm/compute_group_id.dart';
import 'package:kibisis/utils/avm/is_zero_address.dart';

class ARC0200Contract extends BaseContract {
  ARC0200Contract({
    required super.appID,
    required super.algodURL,
    super.algodToken,
  });

  /// Gets the balance of an address.
  ///
  /// If the address is not valid or a "zero" address, 0 is returned.
  ///
  /// **Parameters:**
  /// - [String] [address]: The address to check.
  ///
  /// **Returns:**
  /// [Future<BigInt>] The balance of the address.
  ///
  /// **Throws:**
  /// - [AVMApplicationReadException] If there was an issue parsing the type returned from the read operation.
  /// - [ABIValueException] If there was an issue parsing the type returned from the read operation.
  ///
  /// **Example:**
  /// ```dart
  /// final contract = ARC0200Contract(...)
  /// Future<BigInt> balance = await contract.balanceOf('INM3RC2AU43ZYJNLUOJF3NMWVK56CDL36JVQUP2G573E3PY4PU7KGHELJA');
  /// print(balance.toString()); // Output: 1000
  /// ```
  Future<BigInt> balanceOf(String address) async {
    Uint8List? result;

    if (!Address.isAlgorandAddress(address) || isZeroAddress(address)) {
      return BigInt.zero;
    }

    result = await readByMethodSignature(
        methodSignature: 'arc200_balanceOf(address)uint256',
        appArgs: [
          ABIAddressType().encode(address),
        ]);

    if (result == null) {
      return BigInt.zero;
    }

    return ABIUintType(256).decode(result);
  }

  /// Creates the unsigned transfer transactions.
  ///
  /// If the balance of the receiver is zero, storage will need to be paid for
  /// the receiver. This function will prepend a pay transaction and compute
  /// the transaction group as atomic transactions.
  ///
  /// **Parameters:**
  /// - [BigInt] [amount]: The amount to transfer.
  /// - [String] [sender]: The sender of the token.
  /// - [String] [receiver]: The receiver of the token.
  /// - [String?] [authAddress]: The auth address of the sender.
  /// - [String?] [note]: An optional note to attach to the application call
  /// transaction.
  /// - [TransactionParams?] [suggestedParams]: Optional transaction params to
  /// use. If none are supplied, the network is queried for the latest.
  ///
  /// **Returns:**
  /// [Future<List<Uint8List>>] The raw unsigned transactions.
  ///
  /// **Throws:**
  /// - [AVMApplicationReadException] If there was an issue parsing the type returned from the read operation.
  /// - [ABIValueException] If there was an issue parsing the type returned from the read operation.
  /// - [AVMMaxTransactionSizeException] If the list of transactions exceeds the transaction group limit of 16.
  ///
  /// **Example:**
  /// ```dart
  /// final contract = ARC0200Contract(...)
  /// List<Uint8List> transactions = await contract.buildUnsignedTransferTransactions({
  ///   amount: BigInt.from(1000),
  ///   sender: 'ICIOEFSBC5RR7SOFTJM4BXA3LVQKAAQRAKCXVFFM5P5QESYJVWPAOWYZSE',
  ///   receiver: 'ROIWGW3NF7I4KWARW4HVQ6PWVEMWFL5OZPLY3TS4I4VEGRONIPWSS4GP3A',
  ///   note: 'Cheers for beers!',
  /// });
  /// ```
  Future<List<Uint8List>> buildUnsignedTransferTransactions({
    required BigInt amount,
    required String sender,
    required String receiver,
    String? authAddress,
    String? note,
    TransactionParams? suggestedParams,
  }) async {
    final receiverBalance = await balanceOf(receiver);
    final encodedAmount = ABIUintType(256).encode(amount);
    const methodSignature = 'arc200_transfer(address,uint256)bool';
    final appArgs = [
      ABIAddressType().encode(receiver),
      encodedAmount,
    ];
    final boxReferences = await determineBoxReferences(
      methodSignature: methodSignature,
      sender: sender,
      appArgs: appArgs,
      suggestedParams: suggestedParams,
      authAddress: authAddress,
    );
    Map<String, dynamic> applicationTransaction;
    int boxStorageCost;
    Uint8List? groupID;
    Map<String, dynamic>? payTransaction;

    if (boxReferences.isEmpty) {
      throw AVMApplicationReadException(appID,
          'failed to get box references for sender "$sender" and receiver "$receiver"');
    }

    // create the application call transaction
    applicationTransaction = await createWriteApplicationTransactionMessagePack(
      methodSignature: methodSignature,
      sender: sender,
      appArgs: appArgs,
      note: note,
      boxNames: boxReferences,
      suggestedParams: suggestedParams,
    );

    // if the receiver balance is zero, it is *likely* this is first time they have received the token, so a pay transaction needs to be added to pay for box storage
    if (receiverBalance <= BigInt.zero) {
      boxStorageCost = calculateBoxMBR(boxReferences[0].name, encodedAmount);
      payTransaction = (await (PaymentTransactionBuilder()
                ..amount = boxStorageCost
                ..sender = Address.fromAlgorandAddress(address: sender)
                ..receiver = Address.fromAlgorandAddress(address: address())
                ..noteText =
                    'Initial box storage funding for account "$receiver" for application "$appID"')
              .build())
          .toMessagePack();

      // assign group ids
      groupID = computeGroupID([payTransaction, applicationTransaction]);
      payTransaction['grp'] = groupID;
      applicationTransaction['grp'] = groupID;
    }

    return [
      if (payTransaction != null) Encoder.encodeMessagePack(payTransaction),
      Encoder.encodeMessagePack(applicationTransaction),
    ];
  }

  /// Gets the decimals of the token.
  ///
  /// **Returns:**
  /// A Future<int> of the decimals.
  ///
  /// **Throws:**
  /// - [AVMApplicationReadException] If there was an issue parsing the type returned from the read operation.
  /// - [ABIValueException] If there was an issue parsing the type returned from the read operation.
  ///
  /// **Example:**
  /// ```dart
  /// final contract = ARC0200Contract(...)
  /// Future<int> decimals = await contract.decimals();
  /// print(decimals); // Output: 6
  /// ```
  Future<int> decimals() async {
    final result = await readByMethodSignature(
        methodSignature: 'arc200_decimals()uint8', appArgs: []);

    if (result == null) {
      return 0;
    }

    return ABIUintType(8).decode(result).toInt();
  }

  /// Gets the name of the token.
  ///
  /// **Returns:**
  /// A Future<String> of the name of the token.
  ///
  /// **Throws:**
  /// - [AVMApplicationReadException] If there was an issue parsing the type returned from the read operation.
  /// - [ABIValueException] If there was an issue parsing the type returned from the read operation.
  ///
  /// **Example:**
  /// ```dart
  /// final contract = ARC0200Contract(...)
  /// Future<String> name = await contract.name();
  /// print(name); // Output: Voi Incentive Token
  /// ```
  Future<String> name() async {
    final result = await readByMethodSignature(
        methodSignature: 'arc200_name()byte[32]', appArgs: []);

    if (result == null) {
      return '';
    }

    return ABIStringType().decode(result);
  }

  /// Gets the symbol of the token.
  ///
  /// **Returns:**
  /// A Future<String> of the symbol of the token.
  ///
  /// **Throws:**
  /// - [AVMApplicationReadException] If there was an issue parsing the type returned from the read operation.
  /// - [ABIValueException] If there was an issue parsing the type returned from the read operation.
  ///
  /// **Example:**
  /// ```dart
  /// final contract = ARC0200Contract(...)
  /// Future<String> symbol = await contract.symbol();
  /// print(symbol); // Output: VIA
  /// ```
  Future<String> symbol() async {
    final result = await readByMethodSignature(
        methodSignature: 'arc200_symbol()byte[8]', appArgs: []);

    if (result == null) {
      return '';
    }

    return ABIStringType().decode(result);
  }

  /// Gets the total supply of the token.
  ///
  /// **Returns:**
  /// A Future<BigInt> of the total supply of the token.
  ///
  /// **Throws:**
  /// - [AVMApplicationReadException] If there was an issue parsing the type returned from the read operation.
  /// - [ABIValueException] If there was an issue parsing the type returned from the read operation.
  ///
  /// **Example:**
  /// ```dart
  /// final contract = ARC0200Contract(...)
  /// Future<BigInt> totalSupply = await contract.totalSupply();
  /// print(totalSupply.toString()); // Output: 1000
  /// ```
  Future<BigInt> totalSupply() async {
    final result = await readByMethodSignature(
        methodSignature: 'arc200_totalSupply()uint256', appArgs: []);

    if (result == null) {
      return BigInt.zero;
    }

    return ABIUintType(256).decode(result);
  }
}
