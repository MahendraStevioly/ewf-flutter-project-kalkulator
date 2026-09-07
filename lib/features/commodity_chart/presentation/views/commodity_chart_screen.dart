import 'package:flutter/material.dart';

/// Grafik Harga Komoditas screen
/// Menampilkan chart TradingView via WebView (menggunakan URL launcher sebagai fallback)
class CommodityChartScreen extends StatefulWidget {
  const CommodityChartScreen({super.key});

  @override
  State<CommodityChartScreen> createState() => _CommodityChartScreenState();
}

class _CommodityChartScreenState extends State<CommodityChartScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<_Commodity> _commodities = const [
    _Commodity(
      name: 'Emas',
      symbol: 'XAU/USD',
      symbolCode: 'XAUUSD',
      price: '4.407.425',
      change: '-22.400',
      changePct: '-0,51%',
      isPositive: false,
      color: Color(0xFFF7941D),
    ),
    _Commodity(
      name: 'Perak',
      symbol: 'XAG/USD',
      symbolCode: 'XAGUSD',
      price: '30.85',
      change: '+0.12',
      changePct: '+0.39%',
      isPositive: true,
      color: Color(0xFF6B7280),
    ),
    _Commodity(
      name: 'Minyak',
      symbol: 'WTI Crude',
      symbolCode: 'USOIL',
      price: '74.52',
      change: '-0.87',
      changePct: '-1.16%',
      isPositive: false,
      color: Color(0xFF1D4ED8),
    ),
    _Commodity(
      name: 'Gas',
      symbol: 'Natural Gas',
      symbolCode: 'NATGAS',
      price: '2.241',
      change: '+0.034',
      changePct: '+1.54%',
      isPositive: true,
      color: Color(0xFF059669),
    ),
    _Commodity(
      name: 'Tembaga',
      symbol: 'Copper',
      symbolCode: 'COPPER',
      price: '4.124',
      change: '-0.018',
      changePct: '-0.43%',
      isPositive: false,
      color: Color(0xFFB45309),
    ),
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
                  Container(
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

            // ── CHART AREA ─────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Price summary card
                    _buildPriceCard(selected),
                    const SizedBox(height: 12),

                    // Chart Placeholder (dummy)
                    Expanded(
                      child: _buildChartPlaceholder(selected),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceCard(_Commodity commodity) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: commodity.color.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                commodity.name[0],
                style: TextStyle(
                  color: commodity.color,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  commodity.symbol,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                ),
                Text(
                  commodity.price,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                commodity.change,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: commodity.isPositive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (commodity.isPositive
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFDC2626))
                      .withAlpha(25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  commodity.changePct,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: commodity.isPositive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartPlaceholder(_Commodity commodity) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          // Timeframe selector
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                for (final tf in ['1m', '30m', '1h', 'D'])
                  _timeframeChip(tf, tf == 'D'),
                const Spacer(),
                const Icon(Icons.candlestick_chart_rounded, size: 18, color: Color(0xFF64748B)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 0, color: Color(0xFFF1F5F9)),

          // Candlestick chart placeholder
          Expanded(
            child: CustomPaint(
              painter: _CandlestickPainter(
                isPositive: commodity.isPositive,
                color: commodity.color,
              ),
              child: Container(),
            ),
          ),

          // Bottom label
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Jul', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                const Text('Agu', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                const Text('Sep', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeframeChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF7941D) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? Colors.white : const Color(0xFF94A3B8),
        ),
      ),
    );
  }
}

class _Commodity {
  const _Commodity({
    required this.name,
    required this.symbol,
    required this.symbolCode,
    required this.price,
    required this.change,
    required this.changePct,
    required this.isPositive,
    required this.color,
  });

  final String name;
  final String symbol;
  final String symbolCode;
  final String price;
  final String change;
  final String changePct;
  final bool isPositive;
  final Color color;
}

/// Simple dummy candlestick painter
class _CandlestickPainter extends CustomPainter {
  const _CandlestickPainter({required this.isPositive, required this.color});

  final bool isPositive;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final greenPaint = Paint()..color = const Color(0xFF16A34A);
    final redPaint = Paint()..color = const Color(0xFFDC2626);
    final wickPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 1.5;

    // Draw some dummy candles
    final candles = [
      _DummyCandle(0.3, 0.55, 0.28, 0.65, true),
      _DummyCandle(0.55, 0.4, 0.38, 0.6, false),
      _DummyCandle(0.4, 0.65, 0.38, 0.7, true),
      _DummyCandle(0.65, 0.5, 0.48, 0.68, false),
      _DummyCandle(0.5, 0.75, 0.48, 0.78, true),
      _DummyCandle(0.75, 0.6, 0.58, 0.78, false),
      _DummyCandle(0.6, 0.8, 0.58, 0.82, true),
      _DummyCandle(0.8, 0.68, 0.66, 0.83, false),
      _DummyCandle(0.68, 0.85, 0.66, 0.87, true),
      _DummyCandle(0.85, 0.72, 0.7, 0.88, false),
      _DummyCandle(0.72, 0.88, 0.7, 0.9, true),
      _DummyCandle(0.88, 0.77, 0.75, 0.91, false),
    ];

    final n = candles.length;
    final candleWidth = size.width / (n * 1.8);
    final gap = size.width / (n * 1.8) * 0.8;

    for (var i = 0; i < n; i++) {
      final c = candles[i];
      final x = gap + i * (candleWidth + gap) + candleWidth / 2;
      final open = size.height - c.open * size.height * 0.7 - size.height * 0.1;
      final close = size.height - c.close * size.height * 0.7 - size.height * 0.1;
      final high = size.height - c.high * size.height * 0.7 - size.height * 0.1;
      final low = size.height - c.low * size.height * 0.7 - size.height * 0.1;

      // Wick
      canvas.drawLine(Offset(x, high), Offset(x, low), wickPaint);

      // Body
      final bodyTop = c.isGreen ? close : open;
      final bodyBottom = c.isGreen ? open : close;
      canvas.drawRect(
        Rect.fromLTWH(x - candleWidth / 2, bodyTop, candleWidth, bodyBottom - bodyTop),
        c.isGreen ? greenPaint : redPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DummyCandle {
  const _DummyCandle(this.open, this.close, this.low, this.high, this.isGreen);
  final double open;
  final double close;
  final double low;
  final double high;
  final bool isGreen;
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
