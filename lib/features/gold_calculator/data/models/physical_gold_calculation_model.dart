import '../../domain/entities/physical_gold_calculation.dart';

class PhysicalGoldCalculationModel extends PhysicalGoldCalculation {
  const PhysicalGoldCalculationModel({
    required super.hb,
    required super.hj,
    required super.kurs,
    required super.toz,
    required super.hhb,
    required super.hhj,
    required super.selisih,
    required super.gramEmas,
    required super.keuntunganBersih,
  });

  factory PhysicalGoldCalculationModel.fromCalculation(
    PhysicalGoldCalculation calculation,
  ) {
    return PhysicalGoldCalculationModel(
      hb: calculation.hb,
      hj: calculation.hj,
      kurs: calculation.kurs,
      toz: calculation.toz,
      hhb: calculation.hhb,
      hhj: calculation.hhj,
      selisih: calculation.selisih,
      gramEmas: calculation.gramEmas,
      keuntunganBersih: calculation.keuntunganBersih,
    );
  }
}
