import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/number_formatter.dart';
import '../viewmodels/gold_calculator_viewmodel.dart';

class GoldCalculatorInputView extends StatefulWidget {
  const GoldCalculatorInputView({super.key});

  @override
  State<GoldCalculatorInputView> createState() => _GoldCalculatorInputViewState();
}

class _GoldCalculatorInputViewState extends State<GoldCalculatorInputView> {
  late GoldCalculatorViewModel viewModel;
  final TextEditingController hbController = TextEditingController(text: '');
  final TextEditingController hjController = TextEditingController(text: '');
  final TextEditingController modalController = TextEditingController(text: '');
  final TextEditingController kursController = TextEditingController(text: '18000');
  bool showParameterDetail = true;
  bool isFetchingRate = false;

  @override
  void initState() {
    super.initState();
    viewModel = GoldCalculatorViewModel();
    _loadLiveRate();
  }

  Future<void> _loadLiveRate() async {
    if (!mounted) return;
    setState(() => isFetchingRate = true);
    final rate = await viewModel.fetchLiveExchangeRate();
    if (mounted) {
      if (rate != null && rate > 0) {
        kursController.text = formatNumber(rate, decimals: 0);
      }
      setState(() => isFetchingRate = false);
    }
  }

  @override
  void dispose() {
    hbController.dispose();
    hjController.dispose();
    modalController.dispose();
    kursController.dispose();
    super.dispose();
  }

  void _handleCalculate() {
    viewModel.hargaBeli = hbController.text;
    viewModel.hargaJual = hjController.text;
    viewModel.modalAwalInput = modalController.text;
    viewModel.kursUsdIdrInput = kursController.text;
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
                'Perhitungan keuntungan investasi emas fisik berdasarkan harga pasar terkini.',
                style: AppTypography.body,
              ),
              const SizedBox(height: AppSpacing.xxl),
              
              // Harga Beli
              Text('Harga Beli (HB)', style: AppTypography.sectionTitle),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: hbController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  UsdNumberInputFormatter(allowFraction: true),
                ],
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
                inputFormatters: [
                  UsdNumberInputFormatter(allowFraction: true),
                ],
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
              
              // Modal Awal
              Text('Modal Awal (IDR)', style: AppTypography.sectionTitle),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: modalController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  IndonesianNumberInputFormatter(allowFraction: false),
                ],
                decoration: InputDecoration(
                  prefix: const Text('Rp ', style: AppTypography.body),
                  hintText: '0',
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
                'Total dana modal investasi dalam Rupiah',
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
                              showParameterDetail ? 'Sembunyikan' : 'Edit Kurs',
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text('KURS USD/IDR', style: AppTypography.label),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.positive.withAlpha(30),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: const BoxDecoration(
                                              color: AppColors.positive,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'LIVE',
                                            style: AppTypography.muted.copyWith(
                                              color: AppColors.positive,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (isFetchingRate)
                                  const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                else
                                  GestureDetector(
                                    onTap: _loadLiveRate,
                                    child: const Icon(Icons.refresh_rounded, size: 18, color: AppColors.primary),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: kursController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                IndonesianNumberInputFormatter(allowFraction: true),
                              ],
                              decoration: InputDecoration(
                                prefix: const Text('Rp ', style: AppTypography.body),
                                hintText: viewModel.liveRate != null
                                    ? formatNumber(viewModel.liveRate!, decimals: 0)
                                    : '18.000',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: AppColors.lightGray),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: AppColors.lightGray),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              viewModel.liveRate != null
                                  ? 'Kurs live pasar terkini: Rp ${viewModel.formatCurrency(viewModel.liveRate!).replaceFirst('Rp', '')} (dapat disesuaikan)'
                                  : 'Kurs USD ke IDR (dapat disesuaikan)',
                              style: AppTypography.muted,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _parameterField('KONVERSI TOZ (G)', '${viewModel.konversiTozG.toStringAsFixed(1)} gram'),
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
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.lightGray),
          ),
          child: Text(value, style: AppTypography.body),
        ),
      ],
    );
  }
}
