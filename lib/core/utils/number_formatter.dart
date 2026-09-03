/// Parse angka format Indonesia (4.150,50 → 4150.50)
double parseDecimal(String value) {
  final normalized = value
      .replaceAll('.', '')
      .replaceAll(',', '.')
      .replaceAll(RegExp(r'[^0-9.]'), '');
  return double.tryParse(normalized) ?? 0;
}

/// Format angka ke format Indonesia dengan pemisah ribuan
String formatNumber(double value, {int decimals = 2}) {
  final fixed = value.toStringAsFixed(decimals);
  final parts = fixed.split('.');
  final integerPart = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => '.',
  );
  return '$integerPart,${parts[1]}';
}

/// Terjemahkan rekomendasi pivot ke Bahasa Indonesia
String formatRecommendation(String recommendation) {
  switch (recommendation) {
    case 'BUY':
      return 'BELI';
    case 'SELL':
      return 'JUAL';
    default:
      return 'NETRAL';
  }
}
