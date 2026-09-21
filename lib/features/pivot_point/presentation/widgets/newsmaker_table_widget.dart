import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/market_data.dart';
import '../viewmodels/pivot_point_viewmodel.dart';
import '../../../../core/theme/app_colors.dart'; // <-- Import warna utama
import '../../../../core/theme/app_theme.dart'; // <-- Import extension dark mode

class NewsmakerTableWidget extends StatefulWidget {
  const NewsmakerTableWidget({super.key});

  @override
  State<NewsmakerTableWidget> createState() => _NewsmakerTableWidgetState();
}

class _NewsmakerTableWidgetState extends State<NewsmakerTableWidget> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Tambahkan BuildContext sebagai parameter untuk akses tema
  Widget _buildHeaderCell(String text, BuildContext context, {double width = 80}) {
    return Container(
      width: width,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: context.textSecondary,
        ),
      ),
    );
  }

  // Tambahkan BuildContext sebagai parameter untuk akses tema
  Widget _buildDataCell(String text, BuildContext context, {double width = 80, bool isBold = false}) {
    return Container(
      width: width,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          color: context.textPrimary, // Teks biasa maupun tebal pakai warna adaptif
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PivotPointViewModel>();
    final histories = viewModel.newsmakerHistories;

    // Daftar instrumen yang tersedia
    final symbols = ['Gold', 'Hang Seng', 'Nikkei'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── CHIP FILTER INSTRUMEN ──
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: symbols.map((sym) {
              final isSelected = viewModel.selectedNewsmakerSymbol == sym;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(sym),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      viewModel.changeNewsmakerSymbol(sym);
                      // Scroll list ke atas saat ganti instrumen
                      if (_scrollController.hasClients) {
                        _scrollController.jumpTo(0);
                      }
                    }
                  },
                  showCheckmark: false,
                  selectedColor: AppColors.primary,
                  backgroundColor: context.chipBg, // Background dinamis
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : context.borderColor, // Border dinamis
                    ),
                  ),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : context.textSecondary, // Teks dinamis
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 16),

        // ── TABEL DATA HISTORIS (PAGINATED) ──
        if (histories.isEmpty && !viewModel.isLoading)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Belum ada data historis',
                style: TextStyle(color: context.textSecondary),
              ),
            ),
          )
        else
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.cardBg, // Card dinamis
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.borderColor), // Border dinamis
              boxShadow: [
                if (!context.isDarkMode) // Shadow hanya tampil di light mode
                  BoxShadow(
                    color: Colors.black.withAlpha(8),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: 650,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Table Custom
                      Container(
                        color: context.isDarkMode 
                            ? Colors.white.withAlpha(10) // Gelap transparan untuk dark mode
                            : const Color(0xFFF8FAFC),
                        child: Row(
                          children: [
                            _buildHeaderCell('Tanggal', context, width: 120),
                            _buildHeaderCell('High', context, width: 85),
                            _buildHeaderCell('Low', context, width: 85),
                            _buildHeaderCell('Close', context, width: 85),
                            _buildHeaderCell('Open', context, width: 85),
                            _buildHeaderCell('Aksi', context, width: 110),
                          ],
                        ),
                      ),
                      Divider(height: 1, color: context.dividerColor),

                      // Body Table dengan ListView.builder
                      Container(
                        constraints: const BoxConstraints(maxHeight: 400),
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: histories.length,
                          itemBuilder: (context, index) {
                            final data = histories[index];
                            return Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: context.dividerColor), // Divider dinamis
                                ),
                              ),
                              child: Row(
                                children: [
                                  _buildDataCell(data.date, context, width: 120, isBold: true),
                                  _buildDataCell(data.high.toStringAsFixed(2), context, width: 85),
                                  _buildDataCell(data.low.toStringAsFixed(2), context, width: 85),
                                  _buildDataCell(data.close.toStringAsFixed(2), context, width: 85),
                                  _buildDataCell(data.open.toStringAsFixed(2), context, width: 85),
                                  Container(
                                    width: 110,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    child: ElevatedButton(
                                      onPressed: () => viewModel.calculateFromHistory(data),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        'Hitung',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        if (histories.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: viewModel.currentPage > 1 && !viewModel.isFetchingMore
                    ? () => viewModel.previousPage()
                    : null,
                icon: const Icon(Icons.chevron_left, size: 20),
                label: const Text('Sebelumnya', style: TextStyle(fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  disabledForegroundColor: Colors.grey,
                ),
              ),
              if (viewModel.isFetchingMore)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Text(
                  'Halaman ${viewModel.currentPage}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: context.textSecondary, // Teks halaman dinamis
                  ),
                ),
              TextButton(
                onPressed: viewModel.hasMoreData && !viewModel.isFetchingMore
                    ? () => viewModel.nextPage()
                    : null,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  disabledForegroundColor: Colors.grey,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('Selanjutnya', style: TextStyle(fontWeight: FontWeight.bold)),
                    Icon(Icons.chevron_right, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}