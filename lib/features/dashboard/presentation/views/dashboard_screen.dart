import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../news/presentation/views/all_news_screen.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/history_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../domain/entities/news_item.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../widgets/news_card.dart';
import '../widgets/news_detail_bottom_sheet.dart';
import 'package:kalkulator_pivot/features/news/presentation/viewmodels/news_viewmodel.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardViewModel(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DashboardViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => viewModel.refreshAll(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── HEADER SECTION ──────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildHeader(context, viewModel)),

            // ── BODY CONTENT ────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // XAU/USD Price Card
                  _buildPriceCard(viewModel),
                  const SizedBox(height: 24),

                  // Berita Terkini
                  _buildSectionHeader(
                    context,
                    title: 'Berita Terkini',
                    actionLabel: 'Lihat Semua →',
                    onAction: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeNotifierProvider(
                          create: (_) => NewsViewModel(),
                          child: const AllNewsScreen(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildNewsSection(context, viewModel),
                  const SizedBox(height: 24),

                  // Fitur Utama
                  const Text(
                    'Fitur Utama',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureList(context),
                  const SizedBox(height: 24),

                  // Riwayat Terbaru
                  _buildSectionHeader(
                    context,
                    title: 'Riwayat Terbaru',
                    actionLabel: 'Lihat Semua →',
                    onAction: () =>
                        Navigator.of(context).pushNamed(AppRoutes.history),
                  ),
                  const SizedBox(height: 12),
                  _buildRecentHistory(context),
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // HEADER (no AppBar, custom top area)
  // ─────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, DashboardViewModel viewModel) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: brand + history icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'EWF',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 9,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'STAFF UTILITY',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.history),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.access_time_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Greeting & date
          const Text(
            'Selamat datang',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getFormattedDate(),
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final days = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ];
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${days[now.weekday % 7]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  // ─────────────────────────────────────────────────────────
  // XAU/USD PRICE CARD
  // ─────────────────────────────────────────────────────────
  Widget _buildPriceCard(DashboardViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'XAU/USD',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_upward_rounded,
                          size: 12,
                          color: Color(0xFF16A34A),
                        ),
                        SizedBox(width: 2),
                        Text(
                          '+0.30%',
                          style: TextStyle(
                            color: Color(0xFF16A34A),
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Text(
                'Diperbarui ${viewModel.lastUpdated}',
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '\$${viewModel.liveGoldPrice}',
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '+12.40',
                style: TextStyle(
                  color: Color(0xFF16A34A),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // SECTION HEADER ROW
  // ─────────────────────────────────────────────────────────
  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFFF7941D),
              ),
            ),
          ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  // NEWS SECTION
  // ─────────────────────────────────────────────────────────
  Widget _buildNewsSection(BuildContext context, DashboardViewModel viewModel) {
    return SizedBox(
      height: 208,
      child: viewModel.isLoadingNews
          ? ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 2,
              itemBuilder: (context, index) => _buildNewsShimmer(),
            )
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: viewModel.newsList.length,
              itemBuilder: (context, index) {
                final item = viewModel.newsList[index];
                return NewsCard(
                  item: item,
                  onTap: () => NewsDetailBottomSheet.show(context, item),
                );
              },
            ),
    );
  }

  Widget _buildNewsShimmer() {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: const BoxDecoration(
              color: Color(0xFFE2E8F0),
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 8,
                  child: ColoredBox(color: Color(0xFFE2E8F0)),
                ),
                SizedBox(height: 6),
                SizedBox(
                  height: 12,
                  child: ColoredBox(color: Color(0xFFE2E8F0)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // FITUR UTAMA (List style, bukan 2x2 grid)
  // ─────────────────────────────────────────────────────────
  Widget _buildFeatureList(BuildContext context) {
    final features = [
      _FeatureItem(
        icon: Icons.diamond_outlined,
        title: 'Kalkulator Emas Fisik',
        subtitle: 'Hitung estimasi keuntungan emas fisik',
        route: AppRoutes.goldCalculator,
        iconColor: AppColors.primary,
        iconBg: const Color(0xFFFFF3E0),
      ),
      _FeatureItem(
        icon: Icons.candlestick_chart_rounded,
        title: 'Analisa Pivot Point',
        subtitle: 'Hitung level support dan resistance',
        route: AppRoutes.pivotPoint,
        iconColor: AppColors.primary,
        iconBg: const Color(0xFFFFF3E0),
      ),
      _FeatureItem(
        icon: Icons.bar_chart_rounded,
        title: 'Grafik Harga Komoditas',
        subtitle: 'Chart live dari TradingView',
        route: AppRoutes.commodityChart,
        iconColor: AppColors.primary,
        iconBg: const Color(0xFFFFF3E0),
      ),
      _FeatureItem(
        icon: Icons.settings_rounded,
        title: 'Pengaturan',
        subtitle: 'Konfigurasi parameter & preferensi',
        route: AppRoutes.settings,
        iconColor: const Color(0xFF334155),
        iconBg: const Color(0xFFF1F5F9),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: List.generate(features.length, (index) {
          final f = features[index];
          final isLast = index == features.length - 1;
          return Column(
            children: [
              _FeatureListTile(
                icon: f.icon,
                title: f.title,
                subtitle: f.subtitle,
                iconColor: f.iconColor,
                iconBg: f.iconBg,
                onTap: () => Navigator.of(context).pushNamed(f.route),
              ),
              if (!isLast)
                const Divider(height: 0, indent: 64, color: Color(0xFFF1F5F9)),
            ],
          );
        }),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // RECENT HISTORY
  // ─────────────────────────────────────────────────────────
  Widget _buildRecentHistory(BuildContext context) {
    final recent = HistoryService.instance.getRecentCombined(limit: 3);

    if (recent.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Belum ada riwayat perhitungan.\nMulai hitung untuk melihat riwayat di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: List.generate(recent.length, (index) {
          final item = recent[index];
          final isLast = index == recent.length - 1;
          final isGold = item['type'] == HistoryType.gold;

          Widget tile;
          if (isGold) {
            final g = item['entry'] as GoldHistoryEntry;
            tile = _buildHistoryTile(
              context: context,
              isGold: true,
              title:
                  'HB \$${g.hb.toStringAsFixed(2)}  |  HJ \$${g.hj.toStringAsFixed(2)}',
              subtitle: _formatDateTime(g.timestamp),
              value: _formatCurrencyShort(g.keuntunganBersih),
              isPositive: g.keuntunganBersih >= 0,
              onTap: () => Navigator.of(
                context,
              ).pushNamed(AppRoutes.goldDetail, arguments: g),
            );
          } else {
            final p = item['entry'] as PivotHistoryEntry;
            tile = _buildHistoryTile(
              context: context,
              isGold: false,
              title: 'PP ${p.pp.toStringAsFixed(2)}',
              subtitle: _formatDateTime(p.timestamp),
              value: p.recommendation,
              isPositive: p.recommendation == 'BUY',
              isNeutral: p.recommendation == 'NEUTRAL',
              onTap: () => Navigator.of(
                context,
              ).pushNamed(AppRoutes.pivotDetail, arguments: p),
            );
          }

          return Column(
            children: [
              tile,
              if (!isLast)
                const Divider(height: 0, indent: 64, color: Color(0xFFF1F5F9)),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHistoryTile({
    required BuildContext context,
    required bool isGold,
    required String title,
    required String subtitle,
    required String value,
    required bool isPositive,
    bool isNeutral = false,
    required VoidCallback onTap,
  }) {
    final Color valueColor = isNeutral
        ? const Color(0xFF64748B)
        : isPositive
        ? const Color(0xFF16A34A)
        : const Color(0xFFDC2626);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isGold
                    ? const Color(0xFFFFF3E0)
                    : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isGold
                    ? Icons.diamond_outlined
                    : Icons.candlestick_chart_rounded,
                size: 20,
                color: isGold ? AppColors.primary : const Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
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

  String _formatCurrencyShort(double value) {
    if (value.abs() >= 1000000000) {
      return '${value >= 0 ? '+' : '-'}Rp${(value.abs() / 1000000000).toStringAsFixed(1)}M';
    } else if (value.abs() >= 1000000) {
      return '${value >= 0 ? '+' : '-'}Rp${(value.abs() / 1000000).toStringAsFixed(0)}jt';
    } else if (value.abs() >= 1000) {
      return '${value >= 0 ? '+' : '-'}Rp${(value.abs() / 1000).toStringAsFixed(0)}rb';
    }
    return '${value >= 0 ? '+' : '-'}Rp${value.abs().toStringAsFixed(0)}';
  }
}

class _FeatureItem {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.iconColor,
    required this.iconBg,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
  final Color iconColor;
  final Color iconBg;
}

class _FeatureListTile extends StatelessWidget {
  const _FeatureListTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.iconBg,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color iconBg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }
}
