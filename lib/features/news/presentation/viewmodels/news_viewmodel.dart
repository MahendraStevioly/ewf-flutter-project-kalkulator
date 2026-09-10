import 'package:flutter/material.dart';
import '../../data/services/news_service.dart';
import '../../../dashboard/domain/entities/news_item.dart';

class NewsViewModel extends ChangeNotifier {
  final NewsService _service = NewsService();

  bool isLoading = false;
  String? errorMessage;
  List<NewsItem> liveNewsList = [];

  Future<void> fetchLiveNews() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // 1. Tarik data mentah dari Investing.com
      final rawNews = await _service.fetchNews();

      // 2. Ubah formatnya agar sesuai dengan model NewsItem buatan teman Anda
      liveNewsList = rawNews.map((rssItem) {
        return NewsItem(
          id: rssItem.link, // <-- Tambahkan ID menggunakan link artikel
          title: rssItem.title,
          imageUrl: rssItem.imageUrl.isNotEmpty 
              ? rssItem.imageUrl 
              : 'https://via.placeholder.com/150',
          category: 'Komoditas',
          source: 'Investing.com',
          timeAgo: _formatDate(rssItem.pubDate),
          url: rssItem.link, // <-- Tambahkan URL agar tombol di Bottom Sheet bisa bekerja!
        );
      }).toList();

    } catch (e) {
      errorMessage = 'Gagal memuat berita terkini.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Fungsi sederhana memotong format tanggal RSS agar rapi di UI
  String _formatDate(String pubDate) {
    if (pubDate.length > 16) {
      return pubDate.substring(0, 16); 
    }
    return 'Hari ini';
  }
}