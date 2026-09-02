import '../entities/pivot_point_calculation.dart';

abstract class PivotPointRepository {
  const PivotPointRepository();

  PivotPointCalculation calculate({
    required double high,
    required double low,
    required double close,
    required double openingPrice,
  });
}
