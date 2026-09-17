import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/history_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/number_formatter.dart';
import '../viewmodels/pivot_point_viewmodel.dart';
import '../widgets/newsmaker_table_widget.dart'; // <-- IMPORT TABEL NEWSMAKER

class PivotPointScreen extends StatelessWidget {
  const PivotPointScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PivotPointViewModel(),
      child: const _PivotPointView(),
    );
  }
}

class _PivotPointView extends StatefulWidget {
  const _PivotPointView();

  @override
  State<_PivotPointView> createState() => _PivotPointViewState();
}

class _PivotPointViewState extends State<_PivotPointView>
    with SingleTickerProviderStateMixin {
  final TextEditingController highController = TextEditingController(text: '4,145');
  final TextEditingController lowController = TextEditingController(text: '4,110');
  final TextEditingController closeController = TextEditingController(text: '4,132');
  final TextEditingController opController = TextEditingController(text: '4,118');

  late TabController _tabController;
  bool _isManual = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) return;
      setState(() => _isManual = _tabController.index == 0);
      
      // Reset hasil saat berpindah tab agar UI tetap bersih
      context.read<PivotPointViewModel>().setManualMode(_isManual);
    });
  }

  @override
  void dispose() {
    highController.dispose();
    lowController.dispose();
    closeController.dispose();
    opController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Color _signalColor(String rec) {
    if (rec == 'BUY') return const Color(0xFF16A34A);
    if (rec == 'SELL') return const Color(0xFFDC2626);
    return const Color(0xFF64748B);
  }

  Future<void> _calculate(PivotPointViewModel viewModel) async {
    // Fungsi ini sekarang hanya digunakan untuk mode Manual
    if (_isManual) {
      await viewModel.calculateManual(
        high: parseDecimal(highController.text),
        low: parseDecimal(lowController.text),
        close: parseDecimal(closeController.text),
        openingPrice: parseDecimal(opController.text),
      );
    }

    if (!mounted) return;
    if (viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage!),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.negative,
        ),
      );
    }
  }

  void _saveToHistory(PivotPointViewModel viewModel) {
    final data = viewModel.result;
    if (data == null) return;
    final entry = PivotHistoryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      high: data.high,
      low: data.low,
      close: data.close,
      openingPrice: data.openingPrice,
      pp: data.pp,
      range: data.range,
      r1: data.r1,
      r2: data.r2,
      r3: data.r3,
      r4: data.r4,
      s1: data.s1,
      s2: data.s2,
      s3: data.s3,
      s4: data.s4,
      recommendation: data.recommendation,
    );
    HistoryService.instance.addPivot(entry);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hasil pivot berhasil disimpan ke riwayat'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF16A34A),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PivotPointViewModel>();

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(children: [_BackButton()]),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pivot Point',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Masukkan data pasar untuk menghitung level support dan resistance.',
                      style: TextStyle(fontSize: 13, color: context.textSecondary, height: 1.4),
                    ),
                    const SizedBox(height: 24),

                    // ── MODE SWITCH ─────────────────────────────────────
                    Container(
                      height: 44,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: context.isDarkMode ? AppColors.darkSurface : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: context.cardBg,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(15),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        labelColor: context.textPrimary,
                        unselectedLabelColor: context.textSecondary,
                        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                        tabs: const [Tab(text: 'Manual'), Tab(text: 'Data Historis')],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── AREA INPUT / TABEL ──────────────────────────────
                    _isManual
                        ? Container(
                            decoration: BoxDecoration(
                              color: context.cardBg,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: context.borderColor),
                              boxShadow: [
                                if (!context.isDarkMode)
                                  BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 12, offset: const Offset(0, 3)),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: _buildManualInputs(context),
                            ),
                          )
                        : const NewsmakerTableWidget(), // Panggil tabel di sini

                    // ── HITUNG BUTTON (HANYA MUNCUL DI MODE MANUAL) ─────
                    if (_isManual) ...[
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: viewModel.isLoading ? null : () => _calculate(viewModel),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: viewModel.isLoading
                              ? const SizedBox(
                                  width: 22, height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text(
                                  'HITUNG PIVOT',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 0.8),
                                ),
                        ),
                      ),
                    ],

                    // ── RESULTS ──────────────────────────────────────
                    if (viewModel.result != null) ...[
                      const SizedBox(height: 24),
                      _buildResults(context, viewModel),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualInputs(BuildContext context) {
    return Column(
      children: [
        _inputField(label: 'HIGH', hint: '4145.00', controller: highController, context: context),
        const SizedBox(height: 20),
        _inputField(label: 'LOW', hint: '4110.00', controller: lowController, context: context),
        const SizedBox(height: 20),
        _inputField(label: 'CLOSE', hint: '4132.00', controller: closeController, context: context),
        const SizedBox(height: 20),
        _inputField(label: 'OPEN (OP)', hint: '4118.00', controller: opController, context: context),
      ],
    );
  }

  Widget _inputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: context.textMuted,
            letterSpacing: 0.5,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: context.borderColor, width: 1.5)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [UsdNumberInputFormatter(allowFraction: true)],
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: context.textMuted,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResults(BuildContext context, PivotPointViewModel viewModel) {
    final data = viewModel.result!;
    final rec = data.recommendation;
    final signalColor = _signalColor(rec);

    // ── KALKULASI MIDPOINT ANTAR LEVEL (M-Levels) ──
    final mR4 = (data.r3 + data.r4) / 2;
    final mR3 = (data.r2 + data.r3) / 2;
    final mR2 = (data.r1 + data.r2) / 2;
    final mR1 = (data.pp + data.r1) / 2;
    
    final mS1 = (data.pp + data.s1) / 2;
    final mS2 = (data.s1 + data.s2) / 2;
    final mS3 = (data.s2 + data.s3) / 2;
    final mS4 = (data.s3 + data.s4) / 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // PP & Range row
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.isDarkMode ? AppColors.darkSurface : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(14),
                  border: context.isDarkMode ? Border.all(color: context.borderColor) : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Titik Pivot (PP)', style: TextStyle(fontSize: 11, color: context.textSecondary)),
                    const SizedBox(height: 6),
                    Text(formatNumber(data.pp), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: context.textPrimary)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.isDarkMode ? AppColors.darkSurface : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(14),
                  border: context.isDarkMode ? Border.all(color: context.borderColor) : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rentang Harian', style: TextStyle(fontSize: 11, color: context.textSecondary)),
                    const SizedBox(height: 6),
                    Text(formatNumber(data.range, decimals: 2), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: context.textPrimary)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── KOTAK REKOMENDASI (HANYA TAMPIL JIKA MODE MANUAL) ──
        if (viewModel.isManualMode) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: signalColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('REKOMENDASI', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
                const SizedBox(height: 6),
                Text(rec, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // ── DAFTAR LEVEL & MIDPOINT ──
        Container(
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: context.borderColor),
            boxShadow: [
              if (!context.isDarkMode)
                BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 12, offset: const Offset(0, 3)),
            ],
          ),
          child: Column(
            children: [
              _levelRow('R4', data.r4, const Color(0xFFDC2626), context),
              _theDivider(context),
              _midpointRow('Mid R3/R4', mR4, context),
              _theDivider(context),
              _levelRow('R3', data.r3, const Color(0xFFDC2626), context),
              _theDivider(context),
              _midpointRow('Mid R2/R3', mR3, context),
              _theDivider(context),
              _levelRow('R2', data.r2, const Color(0xFFDC2626), context),
              _theDivider(context),
              _midpointRow('Mid R1/R2', mR2, context),
              _theDivider(context),
              _levelRow('R1', data.r1, const Color(0xFFDC2626), context),
              _theDivider(context),
              _midpointRow('Mid PP/R1', mR1, context),
              _theDivider(context),
              
              // Pivot Point (Tengah)
              _levelRow('PP', data.pp, context.isDarkMode ? AppColors.primary : const Color(0xFF0F172A), context, isPivot: true),
              _theDivider(context),
              
              _midpointRow('Mid PP/S1', mS1, context),
              _theDivider(context),
              _levelRow('S1', data.s1, const Color(0xFF16A34A), context),
              _theDivider(context),
              _midpointRow('Mid S1/S2', mS2, context),
              _theDivider(context),
              _levelRow('S2', data.s2, const Color(0xFF16A34A), context),
              _theDivider(context),
              _midpointRow('Mid S2/S3', mS3, context),
              _theDivider(context),
              _levelRow('S3', data.s3, const Color(0xFF16A34A), context),
              _theDivider(context),
              _midpointRow('Mid S3/S4', mS4, context),
              _theDivider(context),
              _levelRow('S4', data.s4, const Color(0xFF16A34A), context),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Save Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () => _saveToHistory(viewModel),
            style: OutlinedButton.styleFrom(
              foregroundColor: context.textPrimary,
              side: BorderSide(color: context.borderColor),
              backgroundColor: context.cardBg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bookmark_rounded, size: 18),
                SizedBox(width: 8),
                Text('Simpan ke Riwayat', style: TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _levelRow(String label, double value, Color color, BuildContext context, {bool isPivot = false}) {
    return Container(
      color: isPivot
          ? (context.isDarkMode ? Colors.white.withAlpha(8) : const Color(0xFFF8FAFC))
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isPivot ? FontWeight.w800 : FontWeight.w600,
                color: color,
              ),
            ),
            Text(
              formatNumber(value),
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
            ),
          ],
        ),
      ),
    );
  }

  // ── WIDGET KHUSUS UNTUK BARIS MIDPOINT ──
  Widget _midpointRow(String label, double value, BuildContext context) {
    return Container(
      color: context.isDarkMode ? Colors.white.withAlpha(5) : const Color(0xFFF8FAFC).withAlpha(150),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.textMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
            Text(
              formatNumber(value),
              style: TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.w600, 
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _theDivider(BuildContext context) => Divider(height: 0, color: context.dividerColor);
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: context.borderColor),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 6, offset: const Offset(0, 1)),
          ],
        ),
        child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: context.textPrimary),
      ),
    );
  }
}