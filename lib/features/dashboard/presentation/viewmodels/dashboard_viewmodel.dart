import 'package:flutter/foundation.dart';

import '../../data/services/news_service.dart';
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

  // Live gold market values (as requested: sample/live data matching Dashboard.png)
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
      _newsList = await _newsService.fetchLatestNews();
    } catch (e) {
      _newsError = e.toString();
    } finally {
      _isLoadingNews = false;
      notifyListeners();
    }
  }

  Future<void> refreshAll() async {
    await loadNews();
  }
}
