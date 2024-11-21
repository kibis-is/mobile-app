import 'package:kibisis/constants/constants.dart';

class NumberFormatter {
  static String shortenNumber(double number) {
    const suffixes = ['', 'K', 'M', 'B', 'T'];
    int suffixIndex = 0;

    // Apply formatting with commas and decimals for numbers <= 99,999
    if (number <= 99999 && number >= 1) {
      return formatWithCommas(number);
    }

    while (number >= 1000 && suffixIndex < suffixes.length - 1) {
      number /= 1000;
      suffixIndex++;
    }

    // Truncate to 2 decimal places without rounding
    number = (number * 100).floorToDouble() / 100;

    String formattedNumber = number.toStringAsFixed(2);

    // Remove trailing .00 if it's an integer value
    if (formattedNumber.endsWith('.00')) {
      formattedNumber =
          formattedNumber.substring(0, formattedNumber.length - 3);
    }

    return '$formattedNumber${suffixes[suffixIndex]}';
  }

  static String formatWithCommas(double number) {
    String formattedNumber = number.toString();
    final parts = formattedNumber.split('.');
    final integerPart = parts[0];
    final fractionalPart = parts.length > 1 ? parts[1] : '';

    final formattedInteger = integerPart.replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]},');

    return fractionalPart.isNotEmpty
        ? '$formattedInteger.$fractionalPart'
        : formattedInteger;
  }

  static String applyDirectionSign(
      String formattedNumber, TransactionDirection direction) {
    final number = double.tryParse(formattedNumber) ?? 0.0;
    if (number == 0.0) {
      return formattedNumber;
    }
    return '${direction == TransactionDirection.outgoing ? '-' : '+'}$formattedNumber';
  }
}
