import 'package:flutter/foundation.dart';

import '../../data/repositories/pivot_point_repository_impl.dart';
import '../../domain/entities/pivot_point_calculation.dart';
import '../../domain/usecases/calculate_pivot_point.dart';

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
}
