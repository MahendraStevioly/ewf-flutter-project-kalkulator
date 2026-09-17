import 'package:flutter/material.dart';

import '../../../../core/services/history_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

class GoldDetailScreen extends StatelessWidget {
  const GoldDetailScreen({super.key});

  String _formatCurrency(double value) {
    if (value.isNaN || value.isInfinite) return 'Rp0';
    final isNeg = value < 0;
    final intPart = value.abs().truncate().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
    return '${isNeg ? '-Rp' : 'Rp'}$intPart';
  }

  String _formatUsd(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }

  String _formatDateTime(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year} • $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final entry = ModalRoute.of(context)?.settings.arguments;
    if (entry is! GoldHistoryEntry) {
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

    final isPos = entry.keuntunganBersih >= 0;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
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
                    Text(
                      'Detail Perhitungan',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(entry.timestamp),
                      style: TextStyle(
                        fontSize: 13,
                        color: context.textMuted,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Detail Rows Card
                    Container(
                      decoration: BoxDecoration(
                        color: context.cardBg,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: context.borderColor),
                        boxShadow: [
                          if (!context.isDarkMode)
                            BoxShadow(
                              color: Colors.black.withAlpha(8),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _detailRow('Harga Beli (HB)', _formatUsd(entry.hb), context),
                          _divider(context),
                          _detailRow('Harga Jual (HJ)', _formatUsd(entry.hj), context),
                          _divider(context),
                          _detailRow(
                            'Harga Hitung Beli (HHB)',
                            '${_formatCurrency(entry.hhb)} / gram',
                            context,
                            valueColor: context.textPrimary,
                          ),
                          _divider(context),
                          _detailRow(
                            'Harga Hitung Jual (HHJ)',
                            '${_formatCurrency(entry.hhj)} / gram',
                            context,
                            valueColor: context.textPrimary,
                          ),
                          _divider(context),
                          _detailRow(
                            'Selisih Harga',
                            '${_formatCurrency(entry.selisih)} / gram',
                            context,
                          ),
                          _divider(context),
                          _detailRow(
                            'Estimasi Gram Emas',
                            '${entry.gramEmas.toStringAsFixed(2)} gram',
                            context,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Net Profit Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isPos
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFDC2626),
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
                            '${isPos ? '+' : ''}${_formatCurrency(entry.keuntunganBersih)}',
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

                    // Parameters Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.isDarkMode ? AppColors.darkSurface : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(14),
                        border: context.isDarkMode ? Border.all(color: context.borderColor) : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PARAMETER DIGUNAKAN',
                            style: TextStyle(
                              color: context.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _paramChip(
                                  label: 'Modal Awal',
                                  value: _formatCurrency(entry.modalAwal),
                                  context: context,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _paramChip(
                                  label: 'Kurs USD',
                                  value: _formatCurrency(entry.kurs),
                                  context: context,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _paramChip(
                                  label: 'TOZ',
                                  value: entry.toz.toStringAsFixed(1),
                                  context: context,
                                ),
                              ),
                            ],
                          ),
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

  Widget _detailRow(String label, String value, BuildContext context, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: context.textSecondary),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: valueColor ?? context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) => Divider(
    height: 0,
    color: context.dividerColor,
    indent: 16,
    endIndent: 16,
  );

  Widget _paramChip({required String label, required String value, required BuildContext context}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10, color: context.textMuted),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: context.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
          color: context.cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: context.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: context.textPrimary,
        ),
      ),
    );
  }
}
