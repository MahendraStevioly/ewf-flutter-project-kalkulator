import '../entities/pivot_point_calculation.dart';
import '../repositories/pivot_point_repository.dart';

class CalculatePivotPoint {
  const CalculatePivotPoint(this.repository);

  final PivotPointRepository repository;

  PivotPointCalculation call({
    required double high,
    required double low,
    required double close,
    required double openingPrice,
  }) {
    return repository.calculate(
      high: high,
      low: low,
      close: close,
      openingPrice: openingPrice,
    );
  }
}
