import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../viewmodels/gold_calculator_viewmodel.dart';

class GoldCalculatorInputView extends StatefulWidget {
  const GoldCalculatorInputView({super.key});

  @override
  State<GoldCalculatorInputView> createState() => _GoldCalculatorInputViewState();
}

class _GoldCalculatorInputViewState extends State<GoldCalculatorInputView> {
  late GoldCalculatorViewModel viewModel;
  final TextEditingController hbController = TextEditingController(text: '');
  final TextEditingController hjController = TextEditingController(text: '');
  bool showParameterDetail = false;

  @override
  void initState() {
    super.initState();
    viewModel = GoldCalculatorViewModel();
  }

  @override
  void dispose() {
    hbController.dispose();
    hjController.dispose();
    super.dispose();
  }

  void _handleCalculate() {
    viewModel.hargaBeli = hbController.text;
    viewModel.hargaJual = hjController.text;
    viewModel.calculate();

    if (viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.errorMessage!)),
      );
    } else {
      // Pass calculation result via Navigator arguments
      Navigator.of(context).pushNamed(
        AppRoutes.goldCalculatorResult,
        arguments: viewModel.hasil,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        leading: const Icon(Icons.domain_rounded, color: AppColors.dark),
        title: const Text('EWF Staff Utility', style: TextStyle(color: AppColors.dark, fontWeight: FontWeight.w700)),
        actions: const [Icon(Icons.access_time_rounded, color: AppColors.dark)],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Subtitle
              Text(
                'Kalkulator Emas Fisik',
                style: AppTypography.title,
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Simulasi perhitungan keuntungan investasi emas fisik berdasarkan harga pasar terkini.',
                style: AppTypography.body,
              ),
              const SizedBox(height: AppSpacing.xxl),
              
              // Harga Beli
              Text('Harga Beli (HB)', style: AppTypography.sectionTitle),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: hbController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  prefix: const Text('\$ ', style: AppTypography.body),
                  hintText: '0.00',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.lightGray),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.lightGray),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Harga per troy ounce dalam USD',
                style: AppTypography.muted,
              ),
              const SizedBox(height: AppSpacing.xl),
              
              // Harga Jual
              Text('Harga Jual (HJ)', style: AppTypography.sectionTitle),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: hjController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  prefix: const Text('\$ ', style: AppTypography.body),
                  hintText: '0.00',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.lightGray),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.lightGray),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Harga per troy ounce dalam USD',
                style: AppTypography.muted,
              ),
              const SizedBox(height: AppSpacing.xxl),
              
              // Parameter Dasar
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.lightGray),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.tune_rounded, size: 20),
                              const SizedBox(width: 8),
                              const Text('Parameter Dasar', style: AppTypography.body),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => setState(() => showParameterDetail = !showParameterDetail),
                            child: Text(
                              'Edit Default',
                              style: AppTypography.body.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (showParameterDetail) ...[
                      Container(
                        color: AppColors.background,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _parameterField('MODAL AWAL', 'Rp${viewModel.modalAwal.toStringAsFixed(0)}'),
                            const SizedBox(height: AppSpacing.md),
                            _parameterField('KURS USD/IDR', 'Rp${viewModel.kursUsdIdr.toStringAsFixed(0)}'),
                            const SizedBox(height: AppSpacing.md),
                            _parameterField('KONVERSI TOZ (G)', viewModel.konversiTozG.toStringAsFixed(1)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              
              // Hitung Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _handleCalculate,
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
                      const Icon(Icons.calculate),
                      const SizedBox(width: 8),
                      const Text('HITUNG KEUNTUNGAN'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              
              // Empty State
              Center(
                child: Column(
                  children: [
                    Icon(Icons.calculate_rounded, size: 48, color: AppColors.lightGray),
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'Hasil kalkulasi akan muncul di sini.',
                      style: AppTypography.muted,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              
              // Bottom Navigation
              _buildBottomNav(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _parameterField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.label),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(value, style: AppTypography.body),
        ),
      ],
    );
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
