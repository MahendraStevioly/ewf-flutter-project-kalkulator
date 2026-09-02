import '../entities/physical_gold_calculation.dart';
import '../repositories/gold_calculator_repository.dart';

class CalculatePhysicalGold {
  const CalculatePhysicalGold(this.repository);

  final GoldCalculatorRepository repository;

  PhysicalGoldCalculation call({
    required double hb,
    required double hj,
    required double kurs,
    required double toz,
    required double modal,
  }) {
    return repository.calculate(
      hb: hb,
      hj: hj,
      kurs: kurs,
      toz: toz,
      modal: modal,
    );
  }
}
