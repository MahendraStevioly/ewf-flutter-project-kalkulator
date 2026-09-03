import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/number_formatter.dart';

class GoldCalculatorResultView extends StatelessWidget {
  const GoldCalculatorResultView({super.key});

  String _formatCurrency(double value) {
    if (value.isNaN || value.isInfinite) return 'Rp0,00';
    final isNegative = value < 0;
    final absVal = value.abs();
    final str = absVal.toStringAsFixed(8);
    final parts = str.split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
    final decPart = parts[1].substring(0, 2);
    final prefix = isNegative ? '-Rp' : 'Rp';
    return '$prefix$intPart,$decPart';
  }

  String _formatGram(double value) {
    if (value.isNaN || value.isInfinite) return '0,00 gram';
    final isNegative = value < 0;
    final absVal = value.abs();
    final str = absVal.toStringAsFixed(8);
    final parts = str.split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
    final decPart = parts[1].substring(0, 2);
    final prefix = isNegative ? '-' : '';
    return '$prefix$intPart,$decPart gram';
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is! Map<String, dynamic>) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Data hasil kalkulasi tidak ditemukan')),
      );
    }

    final hb = (arguments['hb'] as num?)?.toDouble() ?? 0.0;
    final hj = (arguments['hj'] as num?)?.toDouble() ?? 0.0;
    final modalAwal = (arguments['modalAwal'] as num?)?.toDouble() ?? 0.0;
    final hhb = (arguments['hhb'] as num?)?.toDouble() ?? 0.0;
    final hhj = (arguments['hhj'] as num?)?.toDouble() ?? 0.0;
    final selisih = (arguments['selisih'] as num?)?.toDouble() ?? 0.0;
    final gramEmas = (arguments['gramEmas'] as num?)?.toDouble() ?? 0.0;
    final keuntunganBersih = (arguments['keuntunganBersih'] as num?)?.toDouble() ?? 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        leading: const Icon(Icons.domain_rounded, color: AppColors.dark),
        title: const Text(
          'EWF Staff Utility',
          style: TextStyle(color: AppColors.dark, fontWeight: FontWeight.w700),
        ),
        actions: const [Icon(Icons.access_time_rounded, color: AppColors.dark)],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.calculate_rounded, size: 26),
                  const SizedBox(width: 8),
                  const Text('Physical Gold Calculator', style: AppTypography.title),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.lightGray),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('INPUT: MARKET RATES (USD)', style: AppTypography.label),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Harga Beli (HB)', style: AppTypography.body),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.lightGray),
                                ),
                                child: Text('\$ ${formatUsd(hb)}', style: AppTypography.body),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Harga Jual (HJ)', style: AppTypography.body),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.lightGray),
                                ),
                                child: Text('\$ ${formatUsd(hj)}', style: AppTypography.body),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withAlpha(200)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text('HASIL PERHITUNGAN', style: AppTypography.sectionTitle),
              const SizedBox(height: AppSpacing.md),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.lightGray),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _resultRow('Modal Awal', _formatCurrency(modalAwal)),
                    _divider(),
                    _resultRow('Hasil Harga Beli (HHB)', _formatCurrency(hhb)),
                    _divider(),
                    _resultRow('Hasil Harga Jual (HHJ)', _formatCurrency(hhj)),
                    _divider(),
                    _resultRow('Selisih Harga', _formatCurrency(selisih)),
                    _divider(),
                    _resultRow('Total Gram Emas', _formatGram(gramEmas)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.positive.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.positive.withAlpha(100)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KEUNTUNGAN BERSIH',
                      style: AppTypography.body.copyWith(
                        color: AppColors.positive,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatCurrency(keuntunganBersih),
                      style: AppTypography.title.copyWith(
                        color: AppColors.positive,
                        fontSize: 28,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dark,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bookmark_rounded),
                      const SizedBox(width: 8),
                      const Text('Simpan ke Riwayat'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.dark,
                        side: const BorderSide(color: AppColors.dark),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Hitung Ulang'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.goldCalculator),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.dark,
                        side: const BorderSide(color: AppColors.dark),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Reset'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.lightGray),
                ),
                child: const Text(
                  'Context: Calculation based on real-time market spread. Verify local branch limits before finalizing transaction.',
                  style: AppTypography.muted,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.body),
          Text(value, style: AppTypography.body.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Divider(height: 0, color: AppColors.lightGray);
  }
}
