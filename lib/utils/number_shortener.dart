class NumberFormatter {
  static String shortenNumber(double number) {
    const suffixes = ['', 'K', 'M', 'B', 'T'];
    int suffixIndex = 0;

    while (number >= 1000 && suffixIndex < suffixes.length - 1) {
      number /= 1000;
      suffixIndex++;
    }

    String formattedNumber =
        number % 1 == 0 ? number.toStringAsFixed(0) : number.toStringAsFixed(2);

    return '$formattedNumber${suffixes[suffixIndex]}';
  }

  static String formatWithCommas(String number) {
    final parts = number.split('.');
    final integerPart = parts[0];
    final fractionalPart = parts.length > 1 ? parts[1] : '';

    final formattedInteger = integerPart.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]},',
    );

    return fractionalPart.isNotEmpty
        ? '$formattedInteger.$fractionalPart'
        : formattedInteger;
  }
}
