class NumberShortener {
  static String shortenNumber(double number) {
    if (number < 1000000) {
      return number % 1 == 0 ? number.toStringAsFixed(0) : number.toString();
    }

    const suffixes = ['M', 'B', 'T'];
    int suffixIndex = -1;

    while (number >= 1000000 && suffixIndex < suffixes.length - 1) {
      number /= 1000;
      suffixIndex++;
    }

    return suffixIndex == 0
        ? (number % 1 == 0
            ? '${number.toStringAsFixed(0)}${suffixes[suffixIndex]}'
            : '${number.toStringAsFixed(2)}${suffixes[suffixIndex]}')
        : (number % 1 == 0
            ? '${number.toStringAsFixed(0)}${suffixes[suffixIndex]}'
            : '${number.toStringAsFixed(1)}${suffixes[suffixIndex]}');
  }
}
