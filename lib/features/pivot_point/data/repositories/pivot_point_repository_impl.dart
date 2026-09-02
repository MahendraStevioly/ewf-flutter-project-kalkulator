import '../../domain/entities/pivot_point_calculation.dart';
import '../../domain/repositories/pivot_point_repository.dart';

class PivotPointRepositoryImpl implements PivotPointRepository {
  const PivotPointRepositoryImpl();

  @override
  PivotPointCalculation calculate({
    required double high,
    required double low,
    required double close,
    required double openingPrice,
  }) {
    final pp = (high + low + close) / 3;
    final range = high - low;

    final r1 = (2 * pp) - low;
    final r2 = pp + range;
    final r3 = pp + (2 * range);
    final r4 = pp + (3 * range);

    final s1 = (2 * pp) - high;
    final s2 = pp - range;
    final s3 = pp - (2 * range);
    final s4 = pp - (3 * range);

    String recommendation;
    if (pp > openingPrice) {
      recommendation = 'BUY';
    } else if (pp < openingPrice) {
      recommendation = 'SELL';
    } else {
      recommendation = 'NEUTRAL';
    }

    return PivotPointCalculation(
      high: high,
      low: low,
      close: close,
      pp: pp,
      range: range,
      r1: r1,
      r2: r2,
      r3: r3,
      r4: r4,
      s1: s1,
      s2: s2,
      s3: s3,
      s4: s4,
      recommendation: recommendation,
    );
  }
}
