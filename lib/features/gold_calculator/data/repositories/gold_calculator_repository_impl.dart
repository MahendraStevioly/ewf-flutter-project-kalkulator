import '../../domain/entities/physical_gold_calculation.dart';
import '../../domain/repositories/gold_calculator_repository.dart';

class GoldCalculatorRepositoryImpl implements GoldCalculatorRepository {
  const GoldCalculatorRepositoryImpl();

  @override
  PhysicalGoldCalculation calculate({
    required double hb,
    required double hj,
    required double kurs,
    required double toz,
    required double modal,
  }) {
    final hhb = (hb * kurs / toz).truncateToDouble();
    final hhj = (hj * kurs / toz).truncateToDouble();
    final selisih = (hhj - hhb).truncateToDouble();
    final gramEmas = modal / hhb;
    final keuntunganBersih = (gramEmas * selisih).truncateToDouble();

    return PhysicalGoldCalculation(
      hb: hb,
      hj: hj,
      kurs: kurs,
      toz: toz,
      hhb: hhb,
      hhj: hhj,
      selisih: selisih,
      gramEmas: gramEmas,
      keuntunganBersih: keuntunganBersih,
    );
  }
}
