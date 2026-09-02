import '../entities/physical_gold_calculation.dart';

abstract class GoldCalculatorRepository {
  const GoldCalculatorRepository();

  PhysicalGoldCalculation calculate({
    required double hb,
    required double hj,
    required double kurs,
    required double toz,
    required double modal,
  });
}
