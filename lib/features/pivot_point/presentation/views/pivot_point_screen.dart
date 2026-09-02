import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../viewmodels/pivot_point_viewmodel.dart';

class PivotPointScreen extends StatefulWidget {
  const PivotPointScreen({super.key});

  @override
  State<PivotPointScreen> createState() => _PivotPointScreenState();
}

class _PivotPointScreenState extends State<PivotPointScreen> {
  late PivotPointViewModel viewModel;
  bool isManualMode = true;

  final TextEditingController highController = TextEditingController(text: '4,150');
  final TextEditingController lowController = TextEditingController(text: '4,100');
  final TextEditingController closeController = TextEditingController(text: '4,130');
  final TextEditingController opController = TextEditingController(text: '4,120');

  final TextEditingController symbolController = TextEditingController(text: 'XAU/USD');
  final TextEditingController openController = TextEditingController(text: '4,132.00');
  final TextEditingController marketHighController = TextEditingController(text: '4,138.00');
  final TextEditingController marketLowController = TextEditingController(text: '4,128.00');
  final TextEditingController marketCloseController = TextEditingController(text: '4,134.00');

  @override
  void initState() {
    super.initState();
    viewModel = PivotPointViewModel();
  }

  @override
  void dispose() {
    highController.dispose();
    lowController.dispose();
    closeController.dispose();
    opController.dispose();
    symbolController.dispose();
    openController.dispose();
    marketHighController.dispose();
    marketLowController.dispose();
    marketCloseController.dispose();
    super.dispose();
  }

  double _parseDecimal(String value) {
    final normalized = value
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(normalized) ?? 0;
  }

  String _formatNumber(double value, {int decimals = 2}) {
    final fixed = value.toStringAsFixed(decimals);
    final parts = fixed.split('.');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
    return '$integerPart,${parts[1]}';
  }

  Color _recommendationColor(String recommendation) {
    switch (recommendation) {
      case 'BUY':
        return AppColors.positive;
      case 'SELL':
        return AppColors.negative;
      default:
        return AppColors.gray;
    }
  }

  void _calculateManual() {
    viewModel.setManualParams(
      _parseDecimal(highController.text),
      _parseDecimal(lowController.text),
      _parseDecimal(closeController.text),
      _parseDecimal(opController.text),
    );
    viewModel.calculateManual();

    if (viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.errorMessage!)),
      );
    } else {
      setState(() {});
    }
  }

  void _calculateFromMarket() {
    viewModel.setNewsmakerParams(
      symbolController.text,
      _parseDecimal(openController.text),
      _parseDecimal(marketHighController.text),
      _parseDecimal(marketLowController.text),
      _parseDecimal(marketCloseController.text),
    );
    viewModel.calculateNewsmaker();

    if (viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.errorMessage!)),
      );
    } else {
      setState(() {});
    }
  }

  Widget _buildSwitch() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isManualMode = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isManualMode ? AppColors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Manual',
                    style: AppTypography.body.copyWith(
                      fontWeight: isManualMode ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isManualMode = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !isManualMode ? AppColors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Newsmaker',
                    style: AppTypography.body.copyWith(
                      fontWeight: !isManualMode ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.body),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.lightGray),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.lightGray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildManualPanel() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Column(
        children: [
          _buildInputField(controller: highController, label: 'High (Harga tertinggi)'),
          const SizedBox(height: AppSpacing.md),
          _buildInputField(controller: lowController, label: 'Low (Harga terendah)'),
          const SizedBox(height: AppSpacing.md),
          _buildInputField(controller: closeController, label: 'Close (Harga penutupan)'),
          const SizedBox(height: AppSpacing.md),
          _buildInputField(controller: opController, label: 'OP (Harga pembukaan)'),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _calculateManual,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('HITUNG PIVOT'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsmakerPanel() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Data Source: Newsmaker', style: AppTypography.body),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.positive,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Connected', style: AppTypography.body),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Updated:', style: AppTypography.body),
              Text(viewModel.lastUpdated.isEmpty ? '14:32:15' : viewModel.lastUpdated, style: AppTypography.body),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Symbol', style: AppTypography.body),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: symbolController,
                  decoration: InputDecoration(
                    hintText: 'XAU/USD',
                    suffixIcon: const Icon(Icons.edit_outlined),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildInputField(controller: openController, label: 'Open'),
                const SizedBox(height: AppSpacing.md),
                _buildInputField(controller: marketHighController, label: 'High'),
                const SizedBox(height: AppSpacing.md),
                _buildInputField(controller: marketLowController, label: 'Low'),
                const SizedBox(height: AppSpacing.md),
                _buildInputField(controller: marketCloseController, label: 'Close'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _calculateFromMarket,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('HITUNG PIVOT'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    final data = viewModel.hasil;

    if (data == null) {
      return const SizedBox.shrink();
    }

    final recommendation = data['recommendation'] as String;
    final pp = data['pp'] as double;
    final range = data['range'] as double;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lightGray),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    recommendation == 'BUY' ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                    color: _recommendationColor(recommendation),
                    size: 26,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    viewModel.formatRecommendation(recommendation),
                    style: AppTypography.title.copyWith(
                      color: _recommendationColor(recommendation),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lightGray),
            ),
            child: Column(
              children: [
                _resultStat(label: 'TITIK PIVOT (PP)', value: _formatNumber(pp)),
                const Divider(),
                _resultStat(label: 'RENTANG HARIAN', value: _formatNumber(range, decimals: 2)),
                const Divider(),
                _resultStat(
                  label: 'HARGA PEMBUKAAN (OP)',
                  value: _formatNumber(
                    isManualMode 
                      ? _parseDecimal(opController.text)
                      : _parseDecimal(openController.text),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const Text('Market Level Visualization', style: AppTypography.sectionTitle),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lightGray),
            ),
            child: Column(
              children: [
                _marketLevelRow(label: 'R4', value: data['r4'] as double, color: AppColors.negative),
                _marketLevelRow(label: 'R3', value: data['r3'] as double, color: AppColors.negative),
                _marketLevelRow(label: 'R2', value: data['r2'] as double, color: AppColors.negative),
                _marketLevelRow(label: 'R1', value: data['r1'] as double, color: AppColors.negative),
                _marketLevelRow(label: 'PIVOT', value: data['pp'] as double, color: AppColors.dark, isPivot: true),
                _marketLevelRow(label: 'S1', value: data['s1'] as double, color: AppColors.positive),
                _marketLevelRow(label: 'S2', value: data['s2'] as double, color: AppColors.positive),
                _marketLevelRow(label: 'S3', value: data['s3'] as double, color: AppColors.positive),
                _marketLevelRow(label: 'S4', value: data['s4'] as double, color: AppColors.positive),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultStat({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.body.copyWith(fontWeight: FontWeight.w700)),
        Text(value, style: AppTypography.title.copyWith(fontSize: 18)),
      ],
    );
  }

  Widget _marketLevelRow({
    required String label,
    required double value,
    required Color color,
    bool isPivot = false,
  }) {
    final width = MediaQuery.of(context).size.width * 0.62;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(label, style: AppTypography.body.copyWith(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 8),
          Container(
            width: width,
            height: 26,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: color.withAlpha(isPivot ? 30 : 75),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _formatNumber(value),
              style: AppTypography.body.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.business_center_outlined, size: 30),
                      const SizedBox(width: 10),
                      const Text('EWF Staff Utility', style: AppTypography.title),
                    ],
                  ),
                  const Icon(Icons.dark_mode_outlined),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text('Pivot Point Calculator', style: AppTypography.title),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Enter daily market values to generate support and resistance levels.',
                style: AppTypography.body,
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildSwitch(),
              const SizedBox(height: AppSpacing.xl),
              if (isManualMode) _buildManualPanel() else _buildNewsmakerPanel(),
              _buildResult(),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _navButton(label: 'Gold', selected: false, icon: Icons.attach_money_rounded, onTap: () => Navigator.of(context).pushNamed(AppRoutes.goldCalculator)),
                  _navButton(label: 'Pivot', selected: true, icon: Icons.trending_up_rounded),
                  _navButton(label: 'History', selected: false, icon: Icons.history_rounded, onTap: () => Navigator.of(context).pushNamed(AppRoutes.history)),
                  _navButton(label: 'Settings', selected: false, icon: Icons.settings_rounded, onTap: () => Navigator.of(context).pushNamed(AppRoutes.settings)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navButton({
    required String label,
    required bool selected,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : AppColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: selected ? AppColors.white : AppColors.dark),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: AppTypography.muted.copyWith(
                    color: selected ? AppColors.white : AppColors.dark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
