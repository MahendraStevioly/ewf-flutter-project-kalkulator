import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/history_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/number_formatter.dart';

class GoldCalculatorResultView extends StatelessWidget {
  const GoldCalculatorResultView({super.key});

  String _formatCurrency(double value) {
    if (value.isNaN || value.isInfinite) return 'Rp0,00';
    final isNeg = value < 0;
    final abs = value.abs();
    final str = abs.toStringAsFixed(2);
    final parts = str.split('.');
    final intPart = parts[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');
    return '${isNeg ? '-Rp' : 'Rp'}$intPart,${parts[1]}';
  }

  String _formatGram(double value) {
    if (value.isNaN || value.isInfinite) return '0,00 gram';
    final abs = value.abs();
    final str = abs.toStringAsFixed(2);
    final parts = str.split('.');
    final intPart = parts[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');
    return '$intPart,${parts[1]} gram';
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is! Map<String, dynamic>) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Data hasil kalkulasi tidak ditemukan'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Kembali'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final hb = (arguments['hb'] as num?)?.toDouble() ?? 0.0;
    final hj = (arguments['hj'] as num?)?.toDouble() ?? 0.0;
    final modalAwal = (arguments['modalAwal'] as num?)?.toDouble() ?? 0.0;
    final kurs = (arguments['kurs'] as num?)?.toDouble() ?? 18000.0;
    final hhb = (arguments['hhb'] as num?)?.toDouble() ?? 0.0;
    final hhj = (arguments['hhj'] as num?)?.toDouble() ?? 0.0;
    final selisih = (arguments['selisih'] as num?)?.toDouble() ?? 0.0;
    final gramEmas = (arguments['gramEmas'] as num?)?.toDouble() ?? 0.0;
    final keuntunganBersih = (arguments['keuntunganBersih'] as num?)?.toDouble() ?? 0.0;
    final isPos = keuntunganBersih >= 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER ───────────────────────────────────────────────
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
                    // Title
                    const Text(
                      'Hasil Perhitungan',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTimeNow(),
                      style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 24),

                    // ── RESULT ROWS CARD ──────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 12, offset: const Offset(0, 3)),
                        ],
                      ),
                      child: Column(
                        children: [
                          _resultRow('Harga Beli (HB)', '\$${hb.toStringAsFixed(2)}'),
                          _divider(),
                          _resultRow('Harga Jual (HJ)', '\$${hj.toStringAsFixed(2)}'),
                          _divider(),
                          _resultRow('Harga Hitung Beli (HHB)', '${_formatCurrency(hhb)} / gram'),
                          _divider(),
                          _resultRow('Harga Hitung Jual (HHJ)', '${_formatCurrency(hhj)} / gram'),
                          _divider(),
                          _resultRow('Selisih Harga', '${_formatCurrency(selisih)} / gram'),
                          _divider(),
                          _resultRow('Estimasi Gram Emas', _formatGram(gramEmas)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── NET PROFIT CARD ───────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isPos ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'KEUNTUNGAN BERSIH',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${isPos ? '+' : ''}${_formatCurrency(keuntunganBersih)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── PARAMETERS CARD ───────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PARAMETER DIGUNAKAN',
                            style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w700, letterSpacing: 0.6),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _paramChip('Modal Awal', _formatCurrency(modalAwal))),
                              const SizedBox(width: 8),
                              Expanded(child: _paramChip('Kurs USD', _formatCurrency(kurs))),
                              const SizedBox(width: 8),
                              Expanded(child: _paramChip('TOZ', '31.1')),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── ACTION BUTTONS ────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => _saveToHistory(context, {
                          'hb': hb,
                          'hj': hj,
                          'kurs': kurs,
                          'toz': 31.1,
                          'modalAwal': modalAwal,
                          'hhb': hhb,
                          'hhj': hhj,
                          'selisih': selisih,
                          'gramEmas': gramEmas,
                          'keuntunganBersih': keuntunganBersih,
                        }),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          foregroundColor: Colors.white,
                          elevation: 0,
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
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0F172A),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              backgroundColor: Colors.white,
                            ),
                            child: const Text('Hitung Ulang', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.goldCalculator),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0F172A),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              backgroundColor: Colors.white,
                            ),
                            child: const Text('Reset', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Text(
                        'Perhitungan berdasarkan spread pasar. Pastikan konfirmasi dengan kantor cabang sebelum transaksi.',
                        style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), height: 1.5),
                        textAlign: TextAlign.center,
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

  void _saveToHistory(BuildContext context, Map<String, dynamic> data) {
    final entry = GoldHistoryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      hb: data['hb'],
      hj: data['hj'],
      kurs: data['kurs'],
      toz: data['toz'],
      modalAwal: data['modalAwal'],
      hhb: data['hhb'],
      hhj: data['hhj'],
      selisih: data['selisih'],
      gramEmas: data['gramEmas'],
      keuntunganBersih: data['keuntunganBersih'],
    );
    HistoryService.instance.addGold(entry);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perhitungan berhasil disimpan ke riwayat'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF16A34A),
      ),
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)))),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(height: 0, color: Color(0xFFF1F5F9), indent: 16, endIndent: 16);

  Widget _paramChip(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)), overflow: TextOverflow.ellipsis),
      ],
    );
  }

  String _formatDateTimeNow() {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '${now.day} ${months[now.month - 1]} ${now.year} • $h:$m';
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
