import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/news_item.dart';

class NewsDetailBottomSheet extends StatelessWidget {
  const NewsDetailBottomSheet({
    super.key,
    required this.item,
  });

  final NewsItem item;

  static Future<void> show(BuildContext context, NewsItem item) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NewsDetailBottomSheet(item: item),
    );
  }

  Future<void> _openNewsWebsite(BuildContext context) async {
    var rawUrl = item.url.trim();
    if (rawUrl.isEmpty || !rawUrl.startsWith('http')) {
      rawUrl = 'https://www.tradingview.com/symbols/XAUUSD/news/';
    }

    final uri = Uri.parse(rawUrl);

    try {
      // Coba buka dengan mode external browser aplikasi
      var success = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      // Jika external gagal, coba mode platform default
      if (!success) {
        success = await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
      }

      if (!success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka tautan browser.')),
        );
      }
    } catch (e) {
      try {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal membuka tautan: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: context.borderColor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Scrollable Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      item.imageUrl,
                      height: 190,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        height: 140,
                        color: context.isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        child: const Center(
                          child: Icon(Icons.newspaper_rounded, size: 48, color: AppColors.gray),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category & Time Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: context.isDarkMode
                              ? AppColors.primary.withAlpha(30)
                              : const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Komoditas', // <--- DARI BERITA EMAS DIGANTI JADI KOMODITAS
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 14, color: context.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            item.timeAgo,
                            style: TextStyle(
                              color: context.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Headline Title
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: context.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Source info
                  Row(
                    children: [
                      Icon(Icons.verified_outlined, size: 15, color: context.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        'Sumber: ${item.source}',
                        style: TextStyle(
                          color: context.textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Snippet / Summary text
                  Text(
                    item.snippet.isNotEmpty
                        ? item.snippet
                        // <--- TEKS FALLBACK BAWAAN DIGANTI AGAR LEBIH NETRAL
                        : 'Buka tautan berita resmi untuk membaca artikel, analisis teknikal, dan sentimen pasar selengkapnya.',
                    style: TextStyle(
                      fontSize: 14,
                      color: context.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Action Button Container (Fixed at bottom of Sheet)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: context.cardBg,
              border: Border(
                top: BorderSide(color: context.borderColor),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => _openNewsWebsite(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Buka Berita Lengkap di Website',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.open_in_new_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}