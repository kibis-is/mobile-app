class LoginValidator {
  static String? validatePin(String pin) {
    if (pin.length != 6 || !RegExp(r'^[0-9]+$').hasMatch(pin)) {
      return 'PIN must be a 6 digit number.';
    }
    return null;
  }

  static String? validateAccountName(String accountName) {
    if (accountName.isEmpty) {
      return 'Account name cannot be empty.';
    }
    return null;
  }

  static String? validateMnemonic(String mnemonic) {
    if (mnemonic.isEmpty) {
      return 'Mnemonic cannot be empty.';
    }
    return null;
  }
}
