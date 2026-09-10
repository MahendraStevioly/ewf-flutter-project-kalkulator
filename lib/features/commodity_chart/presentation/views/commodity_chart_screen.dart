import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../widgets/tradingview_widget.dart';
import 'package:url_launcher/url_launcher.dart';

/// Grafik Harga Komoditas screen
/// Menampilkan chart TradingView via WebView 
class CommodityChartScreen extends StatefulWidget {
  const CommodityChartScreen({super.key});

  @override
  State<CommodityChartScreen> createState() => _CommodityChartScreenState();
}

class _CommodityChartScreenState extends State<CommodityChartScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Data komoditas sekarang hanya menyimpan nama dan simbol TradingView
  final List<_Commodity> _commodities = const [
    _Commodity(name: 'Emas', tvSymbol: AppConstants.symbolGold),
    _Commodity(name: 'Perak', tvSymbol: AppConstants.symbolSilver),
    _Commodity(name: 'Minyak', tvSymbol: AppConstants.symbolOil),
    _Commodity(name: 'Gas', tvSymbol: AppConstants.symbolGas),
    _Commodity(name: 'Tembaga', tvSymbol: AppConstants.symbolCopper),
  ];

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _commodities.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) return;
      setState(() => _selectedIndex = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = _commodities[_selectedIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  _BackButton(),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Grafik Komoditas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      // Mengarahkan langsung ke chart spesifik yang sedang aktif!
                      final url = Uri.parse('https://www.tradingview.com/chart/?symbol=${selected.tvSymbol}');
                      
                      // Buka di browser eksternal atau aplikasi TradingView jika terpasang
                      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Gagal membuka tautan TradingView')),
                          );
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.open_in_new_rounded, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'TradingView',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── COMMODITY TABS ──────────────────────────────────────────
            SizedBox(
              height: 38,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: _commodities.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final c = _commodities[index];
                  final isSelected = index == _selectedIndex;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedIndex = index;
                      _tabController.animateTo(index);
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFF7941D) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFF7941D).withAlpha(60),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                )
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          c.name,
                          style: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF64748B),
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // ── CHART AREA (FULL SIZE) ──────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(8), 
                        blurRadius: 10, 
                        offset: const Offset(0, 3)
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: TradingViewWidget(
                      symbol: selected.tvSymbol,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// Model data dikompresi jadi sangat ringan
class _Commodity {
  const _Commodity({
    required this.name,
    required this.tvSymbol,
  });

  final String name;
  final String tvSymbol;
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