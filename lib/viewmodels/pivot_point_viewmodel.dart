/// ViewModel untuk Pivot Point Calculator
/// Mengelola state dan business logic kalkulasi pivot point
class PivotPointViewModel {
  // Input values
  double? high;
  double? low;
  double? close;
  double? openingPrice;

  // Newsmaker mode inputs
  String symbol = 'XAU/USD';
  double? newsmakerOpen;
  double? newsmakerHigh;
  double? newsmakerLow;
  double? newsmakerClose;

  // Result state
  Map<String, dynamic>? hasil;
  String? errorMessage;
  bool isCalculating = false;
  bool isNewsmakerMode = false;
  String lastUpdated = '';

  /// Validasi input untuk mode manual
  bool validateManualInputs() {
    if (high == null || low == null || close == null || openingPrice == null) {
      errorMessage = 'Mohon isi semua nilai (High, Low, Close, OP)';
      return false;
    }

    if (high! <= 0 || low! <= 0 || close! <= 0 || openingPrice! <= 0) {
      errorMessage = 'Semua nilai harus berupa angka positif';
      return false;
    }

    errorMessage = null;
    return true;
  }

  /// Validasi input untuk mode newsmaker
  bool validateNewsmakerInputs() {
    if (newsmakerOpen == null ||
        newsmakerHigh == null ||
        newsmakerLow == null ||
        newsmakerClose == null) {
      errorMessage = 'Data market belum lengkap';
      return false;
    }

    if (newsmakerOpen! <= 0 ||
        newsmakerHigh! <= 0 ||
        newsmakerLow! <= 0 ||
        newsmakerClose! <= 0) {
      errorMessage = 'Semua nilai harus berupa angka positif';
      return false;
    }

    errorMessage = null;
    return true;
  }

  /// Hitung pivot point (mode manual)
  /// Formula:
  /// PP = (High + Low + Close) ÷ 3
  /// Range = High − Low
  /// R1 = (2 × PP) − Low, R2 = PP + Range, R3 = PP + 2Range, R4 = PP + 3Range
  /// S1 = (2 × PP) − High, S2 = PP − Range, S3 = PP − 2Range, S4 = PP − 3Range
  /// Recommendation: PP > OP = BUY, PP < OP = SELL, PP = OP = NEUTRAL
  void calculateManual() {
    if (!validateManualInputs()) {
      return;
    }

    isCalculating = true;

    try {
      final pp = (high! + low! + close!) / 3;
      final range = high! - low!;

      final r1 = (2 * pp) - low!;
      final r2 = pp + range;
      final r3 = pp + (2 * range);
      final r4 = pp + (3 * range);

      final s1 = (2 * pp) - high!;
      final s2 = pp - range;
      final s3 = pp - (2 * range);
      final s4 = pp - (3 * range);

      String recommendation;
      if (pp > openingPrice!) {
        recommendation = 'BUY';
      } else if (pp < openingPrice!) {
        recommendation = 'SELL';
      } else {
        recommendation = 'NEUTRAL';
      }

      hasil = {
        'pp': pp,
        'range': range,
        'r1': r1,
        'r2': r2,
        'r3': r3,
        'r4': r4,
        's1': s1,
        's2': s2,
        's3': s3,
        's4': s4,
        'recommendation': recommendation,
        'symbol': symbol,
      };

      errorMessage = null;
    } catch (e) {
      errorMessage = 'Error dalam kalkulasi: $e';
      hasil = null;
    }

    isCalculating = false;
  }

  /// Hitung pivot point dari data newsmaker
  void calculateNewsmaker() {
    if (!validateNewsmakerInputs()) {
      return;
    }

    isCalculating = true;

    try {
      final pp = (newsmakerHigh! + newsmakerLow! + newsmakerClose!) / 3;
      final range = newsmakerHigh! - newsmakerLow!;

      final r1 = (2 * pp) - newsmakerLow!;
      final r2 = pp + range;
      final r3 = pp + (2 * range);
      final r4 = pp + (3 * range);

      final s1 = (2 * pp) - newsmakerHigh!;
      final s2 = pp - range;
      final s3 = pp - (2 * range);
      final s4 = pp - (3 * range);

      String recommendation;
      if (pp > newsmakerOpen!) {
        recommendation = 'BUY';
      } else if (pp < newsmakerOpen!) {
        recommendation = 'SELL';
      } else {
        recommendation = 'NEUTRAL';
      }

      hasil = {
        'pp': pp,
        'range': range,
        'r1': r1,
        'r2': r2,
        'r3': r3,
        'r4': r4,
        's1': s1,
        's2': s2,
        's3': s3,
        's4': s4,
        'recommendation': recommendation,
        'symbol': symbol.trim().isEmpty ? 'XAU/USD' : symbol.trim(),
      };

      errorMessage = null;
    } catch (e) {
      errorMessage = 'Error dalam kalkulasi: $e';
      hasil = null;
    }

    isCalculating = false;
  }

  /// Format angka untuk display dengan 2 desimal
  String formatNumber(double value, {int decimals = 2}) {
    return value.toStringAsFixed(decimals);
  }

  /// Format rekomendasi ke Indonesia
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

  /// Toggle antara mode manual dan newsmaker
  void toggleMode(bool isNewsmaker) {
    isNewsmakerMode = isNewsmaker;
    resetResults();
  }

  /// Update parameter manual
  void setManualParams(double h, double l, double c, double op) {
    high = h;
    low = l;
    close = c;
    openingPrice = op;
  }

  /// Update parameter newsmaker
  void setNewsmakerParams(String sym, double o, double h, double l, double c) {
    symbol = sym;
    newsmakerOpen = o;
    newsmakerHigh = h;
    newsmakerLow = l;
    newsmakerClose = c;
  }

  /// Reset hasil calculation
  void resetResults() {
    hasil = null;
    errorMessage = null;
  }

  /// Reset semua state
  void reset() {
    high = null;
    low = null;
    close = null;
    openingPrice = null;
    symbol = 'XAU/USD';
    newsmakerOpen = null;
    newsmakerHigh = null;
    newsmakerLow = null;
    newsmakerClose = null;
    hasil = null;
    errorMessage = null;
    isCalculating = false;
    lastUpdated = '';
  }
}
