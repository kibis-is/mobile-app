class NumberShortener {
  static String format(double number) {
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

    if (formattedNumber.endsWith('.00T') ||
        formattedNumber.endsWith('.00B') ||
        formattedNumber.endsWith('.00M') ||
        formattedNumber.endsWith('.00K')) {
      formattedNumber = formattedNumber.replaceAll('.00', '');
    }

    return formattedNumber;
  }
}
