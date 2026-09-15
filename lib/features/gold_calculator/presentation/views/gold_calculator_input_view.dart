import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
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
  final TextEditingController modalController = TextEditingController(
    text: '100.000.000',
  );
  final TextEditingController kursController = TextEditingController(text: '18.000');
  bool showParameterDetail = false;
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
        SnackBar(
          content: Text(viewModel.errorMessage!),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.negative,
        ),
      );
    } else {
      Navigator.of(context).pushNamed(
        AppRoutes.goldCalculatorResult,
        arguments: viewModel.hasil,
      );
    }
  }

  String _getFormattedModalChip() {
    // 1. Ambil teks dari controller dan ubah jadi angka
    final modalValue = viewModel.parseFormattedNumber(modalController.text) ?? 0.0;

    // 2. Jika nilainya mencapai jutaan, ubah ke format "jt"
    if (modalValue >= 1000000) {
      final formatJt = modalValue / 1000000;
      // Cek apakah angkanya bulat (contoh: 110 jt) atau ada desimal (contoh: 110.5 jt)
      return formatJt == formatJt.truncateToDouble()
          ? 'Rp ${formatJt.toStringAsFixed(0)} jt'
          : 'Rp ${formatJt.toStringAsFixed(1)} jt';
    }

    // 3. Jika di bawah 1 juta (atau kosong), kembalikan ke format Rupiah standar
    return viewModel.formatCurrency(modalValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  _BackButton(),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    const Text(
                      'Kalkulator Emas Fisik',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Simulasi perhitungan keuntungan investasi emas fisik berdasarkan harga pasar.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── INPUT FIELDS CARD ───────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(8),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ], 
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // HB Field
                            _buildFieldLabel('HARGA BELI (HB)', 'USD / troy oz'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: hbController,
                              hint: '4100.00',
                              prefix: '\$',
                              formatter: UsdNumberInputFormatter(allowFraction: false),
                            ),
                            const SizedBox(height: 20),

                            // HJ Field
                            _buildFieldLabel('HARGA JUAL (HJ)', 'USD / troy oz'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: hjController,
                              hint: '4130.00',
                              prefix: '\$',
                              formatter: UsdNumberInputFormatter(allowFraction: false),
                            ),
                            const SizedBox(height: 20),

                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── PARAMETER DASAR ─────────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(8),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Header row (always visible)
                          InkWell(
                            onTap: null,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  const Text(
                                    'PARAMETER DASAR',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF64748B),
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                  const Spacer(),
                                  Row(
                                    children: [
                                      _miniParamChip('Modal', _getFormattedModalChip()),
                                      const SizedBox(width: 6),
                                      _miniParamChip('Kurs', isFetchingRate ? '...' : 'Rp ${kursController.text}'),
                                      const SizedBox(width: 6),
                                      _miniParamChip('TOZ', '31.1'),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => setState(
                                      () => showParameterDetail = !showParameterDetail,
                                    ),
                                    child: Text(
                                      showParameterDetail ? 'Tutup' : 'Edit',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Expandable detail
                          if (showParameterDetail) ...[
                            const Divider(height: 0, color: Color(0xFFF1F5F9)),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildFieldLabel('MODAL AWAL', 'IDR'),
                                  const SizedBox(height: 8),
                                  _buildTextField(
                                    controller: modalController,
                                    hint: '100.000.000',
                                    prefix: 'Rp',
                                    formatter: IndonesianNumberInputFormatter(
                                      allowFraction: false,
                                    ),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'KURS USD/IDR',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.positive.withAlpha(30),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.circle, size: 7, color: AppColors.positive),
                                                SizedBox(width: 4),
                                                Text('LIVE', style: TextStyle(fontSize: 10, color: AppColors.positive, fontWeight: FontWeight.w700)),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          if (isFetchingRate)
                                            const SizedBox(
                                              width: 14,
                                              height: 14,
                                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                            )
                                          else
                                            GestureDetector(
                                              onTap: _loadLiveRate,
                                              child: const Icon(Icons.refresh_rounded, size: 18, color: AppColors.primary),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  _buildTextField(
                                    controller: kursController,
                                    hint: '18.000',
                                    prefix: 'Rp',
                                    formatter: IndonesianNumberInputFormatter(allowFraction: false),
                                  ),
                                  const SizedBox(height: 12),
                                  _paramRow('KONVERSI TOZ', '${viewModel.konversiTozG.toStringAsFixed(1)} gram / troy oz'),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── HITUNG BUTTON ────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _handleCalculate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary, // Hanya 1 warna utama
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: AppColors.primary.withAlpha(80),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'HITUNG KEUNTUNGAN',
                          style: TextStyle(
                            fontSize: 15, 
                            fontWeight: FontWeight.w800, 
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
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

  Widget _buildFieldLabel(String label, String unit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        ),
        Text(
          unit,
          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required String prefix,
    required dynamic formatter,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.5)),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [formatter],
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          prefixText: prefix.isNotEmpty ? '$prefix ' : null,
          prefixStyle: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFFCBD5E1),
          ),
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFFCBD5E1),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }

  Widget _miniParamChip(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
        Text(
          value,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _paramRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 6, offset: const Offset(0, 1)),
          ],
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF0F172A)),
      ),
    );
  }
}
