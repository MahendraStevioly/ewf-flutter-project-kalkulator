import 'package:flutter/foundation.dart';

import '../../data/repositories/pivot_point_repository_impl.dart';
import '../../domain/entities/pivot_point_calculation.dart';
import '../../domain/usecases/calculate_pivot_point.dart';
import '../../domain/entities/market_data.dart';

/// ViewModel untuk Pivot Point Calculator.
/// Bertugas memanggil UseCase, menyimpan hasil, dan mengelola loading state.
class PivotPointViewModel extends ChangeNotifier {
  PivotPointViewModel({CalculatePivotPoint? calculatePivotPoint})
      : _calculatePivotPoint = calculatePivotPoint ??
            CalculatePivotPoint(PivotPointRepositoryImpl());

  final CalculatePivotPoint _calculatePivotPoint;

  PivotPointCalculation? result;
  String? errorMessage;
  bool isLoading = false;
  bool isManualMode = true;
  String symbol = 'XAU/USD';
  String lastUpdated = '';

  void setManualMode(bool manual) {
    if (isManualMode == manual) {
      return;
    }
    isManualMode = manual;
    resetResults();
    notifyListeners();
  }

  Future<void> calculateManual({
    required double high,
    required double low,
    required double close,
    required double openingPrice,
  }) async {
    if (!_validateInputs(high, low, close, openingPrice)) {
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      result = _calculatePivotPoint.call(
        high: high,
        low: low,
        close: close,
        openingPrice: openingPrice,
      );
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Error dalam kalkulasi: $e';
      result = null;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> calculateNewsmaker({
    required String symbolInput,
    required double open,
    required double high,
    required double low,
    required double close,
  }) async {
    symbol = symbolInput.trim().isEmpty ? 'XAU/USD' : symbolInput.trim();

    if (!_validateInputs(high, low, close, open)) {
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      result = _calculatePivotPoint.call(
        high: high,
        low: low,
        close: close,
        openingPrice: open,
      );
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Error dalam kalkulasi: $e';
      result = null;
    }

    isLoading = false;
    notifyListeners();
  }

  bool _validateInputs(
    double high,
    double low,
    double close,
    double openingPrice,
  ) {
    if (high <= 0 || low <= 0 || close <= 0 || openingPrice <= 0) {
      errorMessage = 'Semua nilai harus berupa angka positif';
      return false;
    }

    errorMessage = null;
    return true;
  }

  void resetResults() {
    result = null;
    errorMessage = null;
    notifyListeners();
  }

  void reset() {
    symbol = 'XAU/USD';
    lastUpdated = '';
    isLoading = false;
    isManualMode = true;
    resetResults();
  }

  // 1. Data dummy untuk UI tabel (Bisa diganti fetch API nanti)
  List<MarketData> _newsmakerHistories = [
    const MarketData(date: '8 Sep 2026', open: 4132.00, high: 4138.00, low: 4128.00, close: 4134.00),
    const MarketData(date: '7 Sep 2026', open: 4108.00, high: 4120.00, low: 4105.00, close: 4115.00),
    const MarketData(date: '6 Sep 2026', open: 4135.00, high: 4150.00, low: 4130.00, close: 4140.00),
  ];

  List<MarketData> get newsmakerHistories => _newsmakerHistories;

  // 2. Fungsi untuk dipanggil saat tombol 'Hitung' di tabel diklik
  void calculateFromHistory(MarketData data) {
    calculateNewsmaker(
      symbolInput: 'Newsmaker (${data.date})', // Supaya Anda tahu ini dari tanggal berapa
      open: data.open,
      high: data.high,
      low: data.low,
      close: data.close,
    );
    notifyListeners();
  }
}
