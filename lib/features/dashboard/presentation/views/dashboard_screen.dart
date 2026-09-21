import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../news/presentation/views/all_news_screen.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/history_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../widgets/news_detail_bottom_sheet.dart';
import '../widgets/news_card.dart';
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

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  late DateTime _currentTime;
  Timer? _clockTimer;

  late final PageController _newsPageController;
  Timer? _newsAutoSlideTimer;

  String _getFormattedDate(DateTime now) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  String _getFormattedTime(DateTime now) {
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final second = now.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();

    // Set initialPage ke angka besar agar bisa di-swipe bolak-balik sejak awal
    _newsPageController = PageController(
      initialPage: 6000, 
      viewportFraction: 0.75,
    );

    _clockTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (mounted) {
          setState(() {
            _currentTime = DateTime.now();
          });
        }
      },
    );

    _newsAutoSlideTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _autoSlideNews(),
    );
  }

  // Fungsi auto slide yang baru (terus maju ke kanan)
  void _autoSlideNews() {
    if (_newsPageController.hasClients) {
      _newsPageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _newsPageController.dispose();
    _newsAutoSlideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DashboardViewModel>();

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          _newsAutoSlideTimer?.cancel();

          if (_newsPageController.hasClients) {
            _newsPageController.jumpToPage(6000); // Reset ke titik tengah
          }

          await viewModel.refreshAll();
          if (!mounted) return;

          _newsAutoSlideTimer = Timer.periodic(
            const Duration(seconds: 5),
            (_) => _autoSlideNews(),
          );
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, viewModel)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 24), // Spacing pengganti Live Gold yang dihapus
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
                  Text(
                    'Fitur Utama',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureList(context),
                  const SizedBox(height: 12),
                  _buildSettingsTile(context),
                  const SizedBox(height: 12),
                  _buildSectionHeader(
                    context,
                    title: 'Riwayat Terbaru',
                    actionLabel: 'Lihat Semua →',
                    onAction: () => Navigator.of(context).pushNamed(AppRoutes.history),
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

  Widget _buildHeader(BuildContext context, DashboardViewModel viewModel) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 10,
        16,
        0,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B), // Tetap dipertahankan karena desain header solid navy
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(28),
              blurRadius: 24,
              offset: const Offset(0, 8),
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
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
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
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.history),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
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
            const SizedBox(height: 24),
            const Text(
              'Selamat datang',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w800,
                height: 1.1,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getFormattedDate(_currentTime),
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 15,
                  color: Color(0xFFF7941D),
                ),
                const SizedBox(width: 6),
                Text(
                  _getFormattedTime(_currentTime),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'WIB',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: context.textPrimary,
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

  Widget _buildNewsSection(BuildContext context, DashboardViewModel viewModel) {
    if (viewModel.isLoadingNews) {
      return SizedBox(
        height: 208,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 2,
          itemBuilder: (context, index) => _buildNewsShimmer(),
        ),
      );
    }

    if (viewModel.newsList.isEmpty) {
      return SizedBox(
        height: 208,
        child: Center(
          child: Text(
            viewModel.newsError ?? 'Tidak ada berita saat ini',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    final newsList = viewModel.newsList.take(5).toList();

    return SizedBox(
      height: 208,
      child: PageView.builder(
        controller: _newsPageController,
        itemBuilder: (context, index) {
          final realIndex = index % newsList.length;
          final item = newsList[realIndex];

          return NewsCard(
            item: item,
            onTap: () {
              NewsDetailBottomSheet.show(context, item);
            },
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
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: context.chipBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 8,
                  child: ColoredBox(color: context.chipBg),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 12,
                  child: ColoredBox(color: context.chipBg),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureList(BuildContext context) {
    // Definisi warna bg icon yang dinamis
    final bgIconColor = context.isDarkMode 
        ? AppColors.primary.withAlpha(35) 
        : const Color(0xFFFFF3E0);

    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
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
          // ── Item 1: Kalkulator Emas Fisik ──
          _FeatureListTile(
            icon: Icons.diamond_outlined,
            title: 'Kalkulator Emas Fisik',
            subtitle: 'Hitung estimasi keuntungan emas fisik',
            iconColor: AppColors.primary,
            iconBg: bgIconColor,
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.goldCalculator),
          ),
          Divider(height: 0, indent: 64, color: context.dividerColor),

          // ── Item 2: Konsep Transaksi (Accordion) ──
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: bgIconColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.candlestick_chart_rounded, color: AppColors.primary, size: 22),
              ),
              title: Text(
                'Konsep Transaksi',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
              subtitle: Text(
                'Pilih metode analisa & kalkulasi',
                style: TextStyle(
                  fontSize: 12,
                  color: context.textSecondary,
                ),
              ),
              children: [
                Container(
                  // ── Area dalam accordion dibikin sedikit beda warnanya ──
                  decoration: BoxDecoration(
                    color: context.isDarkMode ? Colors.white.withAlpha(5) : const Color(0xFFF8FAFC),
                  ),
                  child: Column(
                    children: [
                      Divider(height: 1, color: context.dividerColor),
                      
                      // ── Sub-menu 1: Nest ──
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            // TODO: Navigasi ke Nest (ditunda dulu)
                            print('Navigasi ke Nest');
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 72, right: 16, top: 12, bottom: 12),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: context.cardBg, // Diubah jadi dinamis
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: context.borderColor), // Diubah jadi dinamis
                                    boxShadow: [
                                      if (!context.isDarkMode)
                                        BoxShadow(
                                          color: Colors.black.withAlpha(4),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                    ],
                                  ),
                                  child: const Icon(Icons.hub_outlined, size: 16, color: AppColors.primary),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    'Nest',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: context.textPrimary, // Diubah jadi dinamis
                                    ),
                                  ),
                                ),
                                Icon(Icons.chevron_right, color: context.textMuted, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Divider(height: 1, indent: 72, color: context.dividerColor),
                      
                      // ── Sub-menu 2: Pivot Point ──
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pushNamed(AppRoutes.pivotPoint),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 72, right: 16, top: 12, bottom: 12),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: context.cardBg, // Diubah jadi dinamis
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: context.borderColor), // Diubah jadi dinamis
                                    boxShadow: [
                                      if (!context.isDarkMode)
                                        BoxShadow(
                                          color: Colors.black.withAlpha(4),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                    ],
                                  ),
                                  child: const Icon(Icons.show_chart_rounded, size: 16, color: AppColors.primary),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    'Pivot Point',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: context.textPrimary, // Diubah jadi dinamis
                                    ),
                                  ),
                                ),
                                Icon(Icons.chevron_right, color: context.textMuted, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 0, indent: 64, color: context.dividerColor),

          // ── Item 3: Grafik Harga Komoditas ──
          _FeatureListTile(
            icon: Icons.bar_chart_rounded,
            title: 'Grafik Harga Komoditas',
            subtitle: 'Chart live dari TradingView',
            iconColor: AppColors.primary,
            iconBg: bgIconColor,
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.commodityChart),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.settings),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: context.chipBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.settings_rounded,
                color: context.isDarkMode ? AppColors.primary : const Color(0xFF334155),
                size: 21,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pengaturan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Konfigurasi parameter & preferensi',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: context.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentHistory(BuildContext context) {
    final recent = HistoryService.instance.getRecentCombined(limit: 3);

    if (recent.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(20),
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
        child: Center(
          child: Text(
            'Belum ada riwayat perhitungan.\nMulai hitung untuk melihat riwayat di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.textMuted,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
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
              title: 'HB \$${g.hb.toStringAsFixed(2)}  |  HJ \$${g.hj.toStringAsFixed(2)}',
              subtitle: _formatDateTime(g.timestamp),
              value: _formatCurrencyShort(g.keuntunganBersih),
              isPositive: g.keuntunganBersih >= 0,
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.goldDetail, arguments: g),
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
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.pivotDetail, arguments: p),
            );
          }

          return Column(
            children: [
              tile,
              if (!isLast)
                Divider(height: 0, indent: 64, color: context.dividerColor),
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
        ? context.textSecondary
        : isPositive
        ? const Color(0xFF16A34A)
        : const Color(0xFFDC2626);

    final bgBadgeColor = isGold
        ? (context.isDarkMode ? AppColors.primary.withAlpha(35) : const Color(0xFFFFF3E0))
        : (context.isDarkMode ? const Color(0xFF3B82F6).withAlpha(35) : const Color(0xFFEFF6FF));

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
                color: bgBadgeColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isGold ? Icons.diamond_outlined : Icons.candlestick_chart_rounded,
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
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: context.textMuted,
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
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
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
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: context.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}