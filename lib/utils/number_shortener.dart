class NumberShortener {
  static String shortenNumber(double number) {
    const suffixes = ['', 'K', 'M', 'B', 'T'];
    int suffixIndex = 0;

    while (number >= 1000 && suffixIndex < suffixes.length - 1) {
      number /= 1000;
      suffixIndex++;
    }

    // Format number with up to two decimal places
    String formattedNumber =
        number % 1 == 0 ? number.toStringAsFixed(0) : number.toStringAsFixed(2);

    return '$formattedNumber${suffixes[suffixIndex]}';
  }
}
