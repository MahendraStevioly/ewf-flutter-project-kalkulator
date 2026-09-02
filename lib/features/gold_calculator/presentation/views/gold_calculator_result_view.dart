import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class GoldCalculatorResultView extends StatelessWidget {
  const GoldCalculatorResultView({super.key});

  String _formatCurrency(double value) {
    final intPart = value.toStringAsFixed(0);
    final cents = (value % 1 * 100).toStringAsFixed(0).padLeft(2, '0');
    final formattedInteger = intPart.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
    return 'Rp$formattedInteger,$cents';
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
                                child: Text('\$ ${hb.toStringAsFixed(2)}', style: AppTypography.body),
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
                                child: Text('\$ ${hj.toStringAsFixed(2)}', style: AppTypography.body),
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
                    _resultRow('Hasil Harga Beli (HHB)', _formatCurrency(hhb)),
                    _divider(),
                    _resultRow('Hasil Harga Jual (HHJ)', _formatCurrency(hhj)),
                    _divider(),
                    _resultRow('Selisih Harga', _formatCurrency(selisih)),
                    _divider(),
                    _resultRow('Estimasi Gram Emas', '${gramEmas.toStringAsFixed(2)} gram'),
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
              _buildBottomNav(context),
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

  Widget _buildBottomNav(BuildContext context) {
    return Row(
      children: [
        _navItem(Icons.trending_up_rounded, 'Gold', true, () {}),
        _navItem(Icons.grid_3x3_rounded, 'Pivot', false, () => Navigator.of(context).pushNamed(AppRoutes.pivotPoint)),
        _navItem(Icons.history_rounded, 'History', false, () => Navigator.of(context).pushNamed(AppRoutes.history)),
        _navItem(Icons.settings_rounded, 'Settings', false, () => Navigator.of(context).pushNamed(AppRoutes.settings)),
      ],
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: isActive ? AppColors.white : AppColors.dark),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTypography.muted.copyWith(
                  color: isActive ? AppColors.white : AppColors.dark,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
