import 'package:flutter/material.dart';

import '../../../../core/services/history_service.dart';

class PivotDetailScreen extends StatelessWidget {
  const PivotDetailScreen({super.key});

  String _formatDateTime(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year} • $h:$m';
  }

  Color _signalColor(String rec) {
    if (rec == 'BUY') return const Color(0xFF16A34A);
    if (rec == 'SELL') return const Color(0xFFDC2626);
    return const Color(0xFF64748B);
  }

  @override
  Widget build(BuildContext context) {
    final entry = ModalRoute.of(context)?.settings.arguments;
    if (entry is! PivotHistoryEntry) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Data tidak ditemukan'),
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

    final recommendation = entry.recommendation;
    final signalColor = _signalColor(recommendation);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER ───────────────────────────────────────────────────
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
                      'Detail Pivot Point',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(entry.timestamp),
                      style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    ),

                    const SizedBox(height: 24),

                    // OHLC Inputs Card
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
                          _detailRow('High', entry.high.toStringAsFixed(2)),
                          _divider(),
                          _detailRow('Low', entry.low.toStringAsFixed(2)),
                          _divider(),
                          _detailRow('Close', entry.close.toStringAsFixed(2)),
                          _divider(),
                          _detailRow('Open (OP)', entry.openingPrice.toStringAsFixed(2)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // PP & Range row
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Titik Pivot (PP)',
                                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  entry.pp.toStringAsFixed(2),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Rentang Harian',
                                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  entry.range.toStringAsFixed(2),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Recommendation Card
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
                          const Text(
                            'REKOMENDASI',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            recommendation,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Resistance & Support levels
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
                          _levelRow('R4', entry.r4, const Color(0xFFDC2626)),
                          _levelDivider(),
                          _levelRow('R3', entry.r3, const Color(0xFFDC2626)),
                          _levelDivider(),
                          _levelRow('R2', entry.r2, const Color(0xFFDC2626)),
                          _levelDivider(),
                          _levelRow('R1', entry.r1, const Color(0xFFDC2626)),
                          _levelDivider(),
                          _levelRow('PP', entry.pp, const Color(0xFF0F172A), isPivot: true),
                          _levelDivider(),
                          _levelRow('S1', entry.s1, const Color(0xFF16A34A)),
                          _levelDivider(),
                          _levelRow('S2', entry.s2, const Color(0xFF16A34A)),
                          _levelDivider(),
                          _levelRow('S3', entry.s3, const Color(0xFF16A34A)),
                          _levelDivider(),
                          _levelRow('S4', entry.s4, const Color(0xFF16A34A)),
                        ],
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

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(height: 0, color: Color(0xFFF1F5F9), indent: 16, endIndent: 16);
  Widget _levelDivider() => const Divider(height: 0, color: Color(0xFFF1F5F9));

  Widget _levelRow(String label, double value, Color color, {bool isPivot = false}) {
    return Container(
      color: isPivot ? const Color(0xFFF8FAFC) : null,
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
              value.toStringAsFixed(2),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
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
