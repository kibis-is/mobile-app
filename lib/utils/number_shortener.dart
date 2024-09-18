class NumberShortener {
  static String shortenNumber(double number) {
    if (number < 1000000) {
      return number % 1 == 0 ? number.toStringAsFixed(0) : number.toStringAsFixed(2);
    }

    const suffixes = ['M', 'B', 'T'];
    int suffixIndex = -1;

    while (number >= 1000000 && suffixIndex < suffixes.length - 1) {
      number /= 1000;
      suffixIndex++;
    }

    // Ensure only 2 decimal places max
    return '${number.toStringAsFixed(number % 1 == 0 ? 0 : 2)}${suffixes[suffixIndex]}';
  }
}