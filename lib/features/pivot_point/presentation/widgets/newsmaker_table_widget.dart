import 'package:flutter/material.dart';
import '../../domain/entities/market_data.dart';

class NewsmakerTableWidget extends StatefulWidget {
  // ── PARAMETER DINAMIS ──
  // Dengan ini, tabel bisa menerima data dari ViewModel APAPUN (Pivot / Nest)
  final List<MarketData> histories;
  final String selectedSymbol;
  final bool isLoading;
  final int currentPage;
  final bool isFetchingMore;
  final bool hasMoreData;
  final void Function(String) onChangeSymbol;
  final void Function(MarketData) onCalculate;
  final VoidCallback onNextPage;
  final VoidCallback onPrevPage;

  const NewsmakerTableWidget({
    super.key,
    required this.histories,
    required this.selectedSymbol,
    required this.isLoading,
    required this.currentPage,
    required this.isFetchingMore,
    required this.hasMoreData,
    required this.onChangeSymbol,
    required this.onCalculate,
    required this.onNextPage,
    required this.onPrevPage,
  });

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

  Widget _buildHeaderCell(String text, {double width = 80}) {
    return Container(
      width: width,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
    );
  }

  Widget _buildDataCell(String text, {double width = 80, bool isBold = false}) {
    return Container(
      width: width,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Text(
        text, 
        style: TextStyle(
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w500, 
          color: isBold ? const Color(0xFF0F172A) : null
        )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              final isSelected = widget.selectedSymbol == sym;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(sym),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      widget.onChangeSymbol(sym);
                      if (_scrollController.hasClients) {
                        _scrollController.jumpTo(0);
                      }
                    }
                  },
                  showCheckmark: false,
                  selectedColor: const Color(0xFFF7941D),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFFF7941D) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
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
        if (widget.histories.isEmpty && !widget.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text('Belum ada data historis'),
            ),
          )
        else
          Container(
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
                      Container(
                        color: const Color(0xFFF8FAFC),
                        child: Row(
                          children: [
                            _buildHeaderCell('Tanggal', width: 120),
                            _buildHeaderCell('High', width: 85),
                            _buildHeaderCell('Low', width: 85),
                            _buildHeaderCell('Close', width: 85),
                            _buildHeaderCell('Open', width: 85),
                            _buildHeaderCell('Aksi', width: 110),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),
                      
                      Container(
                        constraints: const BoxConstraints(maxHeight: 400),
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: widget.histories.length,
                          itemBuilder: (context, index) {
                            final data = widget.histories[index];
                            return Container(
                              decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                              ),
                              child: Row(
                                children: [
                                  _buildDataCell(data.date, width: 120, isBold: true),
                                  _buildDataCell(data.high.toStringAsFixed(2), width: 85),
                                  _buildDataCell(data.low.toStringAsFixed(2), width: 85),
                                  _buildDataCell(data.close.toStringAsFixed(2), width: 85),
                                  _buildDataCell(data.open.toStringAsFixed(2), width: 85),
                                  Container(
                                    width: 110,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    child: ElevatedButton(
                                      onPressed: () => widget.onCalculate(data),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFF7941D),
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      child: const Text('Hitung', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
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
          
        if (widget.histories.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: widget.currentPage > 1 && !widget.isFetchingMore 
                    ? widget.onPrevPage 
                    : null,
                icon: const Icon(Icons.chevron_left, size: 20),
                label: const Text('Sebelumnya', style: TextStyle(fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFF7941D),
                  disabledForegroundColor: Colors.grey,
                ),
              ),
              if (widget.isFetchingMore)
                const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Text(
                  'Halaman ${widget.currentPage}',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                ),
              TextButton(
                onPressed: widget.hasMoreData && !widget.isFetchingMore 
                    ? widget.onNextPage 
                    : null,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFF7941D),
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