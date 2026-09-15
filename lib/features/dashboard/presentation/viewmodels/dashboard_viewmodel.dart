import 'package:flutter/foundation.dart';

import '../../../news/data/services/news_service.dart';
import '../../domain/entities/news_item.dart';

class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel({NewsService? newsService})
      : _newsService = newsService ?? NewsService() {
    loadNews();
  }

  final NewsService _newsService;

  List<NewsItem> _newsList = [];
  bool _isLoadingNews = true;
  String? _newsError;

  // Live gold market values
  String liveGoldPrice = '2,345.60';
  String liveGoldChange = '+\$12.40 (0.53%)';
  bool isPositiveChange = true;
  String lastUpdated = 'Hari ini, 14:30 WIB';

  List<NewsItem> get newsList => _newsList;
  bool get isLoadingNews => _isLoadingNews;
  String? get newsError => _newsError;

  Future<void> loadNews() async {
    _isLoadingNews = true;
    _newsError = null;
    notifyListeners();

    try {
      // Menggunakan sumber berita yang sama dengan All News.
      final rawNews = await _newsService.fetchNews();

      _newsList = rawNews.map((rssItem) {
        return NewsItem(
          id: rssItem.link,
          title: rssItem.title,
          imageUrl: rssItem.imageUrl.isNotEmpty
              ? rssItem.imageUrl
              : 'https://via.placeholder.com/150',
          category: 'Komoditas',
          source: 'Investing.com',
          timeAgo: _formatDate(rssItem.pubDate),
          url: rssItem.link,
        );
      }).toList();
    } catch (e) {
      _newsError = e.toString();
    } finally {
      _isLoadingNews = false;
      notifyListeners();
    }
  }

  String _formatDate(String pubDate) {
    if (pubDate.length > 16) {
      return pubDate.substring(0, 16);
    }

    return 'Hari ini';
  }

  Future<void> refreshAll() async {
    await loadNews();
  }
}