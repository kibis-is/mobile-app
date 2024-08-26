class NumberShortener {
  static String formatBalance(double number) {
    String formattedNumber;

    if (number >= 1e12) {
      formattedNumber = '${(number / 1e12).toStringAsFixed(2)}T';
    } else if (number >= 1e9) {
      formattedNumber = '${(number / 1e9).toStringAsFixed(2)}B';
    } else if (number >= 1e6) {
      formattedNumber = '${(number / 1e6).toStringAsFixed(2)}M';
    } else if (number >= 1e3) {
      formattedNumber = '${(number / 1e3).toStringAsFixed(2)}K';
    } else {
      formattedNumber = number.toStringAsFixed(2);
    }

    if (formattedNumber.endsWith('.00')) {
      formattedNumber =
          formattedNumber.substring(0, formattedNumber.length - 3);
    }

    return formattedNumber;
  }

  static String formatAssetTotal(int number) {
    String formattedNumber;

    if (number >= 1e12) {
      formattedNumber = '${number ~/ 1e12}T';
    } else if (number >= 1e9) {
      formattedNumber = '${number ~/ 1e9}B';
    } else if (number >= 1e6) {
      formattedNumber = '${number ~/ 1e6}M';
    } else if (number >= 1e3) {
      formattedNumber = '${number ~/ 1e3}K';
    } else {
      formattedNumber = number.toString();
    }

    return formattedNumber;
  }
}
