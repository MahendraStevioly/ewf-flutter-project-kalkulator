import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/market_data.dart';
import '../viewmodels/pivot_point_viewmodel.dart';

class NewsmakerTableWidget extends StatelessWidget {
  const NewsmakerTableWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PivotPointViewModel>();
    final histories = viewModel.newsmakerHistories;

    if (histories.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text('Belum ada data historis newsmaker'),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      // Memotong sudut tabel agar melengkung rapi
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        // INI KUNCI AGAR TABEL BISA DIGULIR KE SAMPING
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
            dataRowMaxHeight: 56,
            columnSpacing: 24, // Jarak antar kolom
            columns: const [
              DataColumn(label: Text('Tanggal', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF64748B)))),
              DataColumn(label: Text('High', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF64748B)))),
              DataColumn(label: Text('Low', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF64748B)))),
              DataColumn(label: Text('Close', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF64748B)))),
              DataColumn(label: Text('Open', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF64748B)))),
              DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF64748B)))),
            ],
            rows: histories.map((data) {
              return DataRow(
                cells: [
                  DataCell(Text(data.date, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A)))),
                  DataCell(Text(data.high.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.w500))),
                  DataCell(Text(data.low.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.w500))),
                  DataCell(Text(data.close.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.w500))),
                  DataCell(Text(data.open.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.w500))),
                  DataCell(
                    ElevatedButton(
                      onPressed: () => viewModel.calculateFromHistory(data),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF7941D),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Hitung', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}