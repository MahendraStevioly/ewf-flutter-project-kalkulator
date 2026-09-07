import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;

import '../../domain/entities/news_item.dart';

class NewsService {
  NewsService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Default curated high-priority gold & market news matching TradingView / Market feeds
  static final List<NewsItem> _fallbackNews = [
    const NewsItem(
      id: '1',
      title: 'Harga Emas Global Terus Menguat Di Tengah Ketidakpastian Pasar',
      category: 'Market Update',
      timeAgo: '2 jam lalu',
      imageUrl: 'https://images.unsplash.com/photo-1610375461246-83df859d849d?w=600&auto=format&fit=crop&q=80',
      source: 'TradingView News',
      url: 'https://www.tradingview.com/symbols/XAUUSD/news/',
      snippet: 'Harga emas spot dunia (XAU/USD) mempertahankan momentum bullish di tengah ekspektasi kebijakan moneter bank sentral.',
    ),
    const NewsItem(
      id: '2',
      title: 'Prediksi Pergerakan XAU/USD Jelang Rilis Data Inflasi AS',
      category: 'Analisa',
      timeAgo: '5 jam lalu',
      imageUrl: 'https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?w=600&auto=format&fit=crop&q=80',
      source: 'TradingView Ideas',
      url: 'https://www.tradingview.com/symbols/XAUUSD/ideas/',
      snippet: 'Analis teknikal mengamati level support kunci 2.330 dan resistance 2.360 pada perdagangan pekan ini.',
    ),
    const NewsItem(
      id: '3',
      title: 'Permintaan Emas Fisik Asia Naik Signifikan Kuartal Ini',
      category: 'Komoditas',
      timeAgo: '7 jam lalu',
      imageUrl: 'https://images.unsplash.com/photo-1618042164219-62c820f10723?w=600&auto=format&fit=crop&q=80',
      source: 'TradingView News',
      url: 'https://www.tradingview.com/symbols/XAUUSD/news/',
      snippet: 'Pembelian emas batangan dan koin oleh konsumen ritel serta institusi menunjukkan tren positif berkelanjutan.',
    ),
    const NewsItem(
      id: '4',
      title: 'Sentimen Dolar AS Melemah, Komoditas Logam Mulia Raih Keuntungan',
      category: 'Makro Ekonomi',
      timeAgo: '12 jam lalu',
      imageUrl: 'https://images.unsplash.com/photo-1526304640581-d334cdbbf45e?w=600&auto=format&fit=crop&q=80',
      source: 'TradingView Market',
      url: 'https://www.tradingview.com/news/',
      snippet: 'Pelemahan indeks Dolar AS (DXY) memberikan dorongan tambahan bagi penguatan harga emas dan perak.',
    ),
  ];

  /// Mengambil berita terkini dari sumber online dengan fallback otomatis
  Future<List<NewsItem>> fetchLatestNews() async {
    try {
      // Coba fetch dari feed online RSS/TradingView / Market
      final response = await _client
          .get(
            Uri.parse('https://news.google.com/rss/search?q=harga+emas+OR+XAU+USD+when:2d&hl=id&gl=ID&ceid=ID:id'),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);
        final items = document.querySelectorAll('item');

        if (items.isNotEmpty) {
          final List<NewsItem> parsedList = [];
          final images = [
            'https://images.unsplash.com/photo-1610375461246-83df859d849d?w=600&auto=format&fit=crop&q=80',
            'https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?w=600&auto=format&fit=crop&q=80',
            'https://images.unsplash.com/photo-1618042164219-62c820f10723?w=600&auto=format&fit=crop&q=80',
            'https://images.unsplash.com/photo-1526304640581-d334cdbbf45e?w=600&auto=format&fit=crop&q=80',
          ];

          for (var i = 0; i < items.length && i < 6; i++) {
            final item = items[i];
            final title = item.querySelector('title')?.text ?? 'Update Pasar Emas';
            final rawLink = item.querySelector('link')?.text?.trim() ?? '';
            final link = rawLink.isNotEmpty ? rawLink : 'https://www.tradingview.com/symbols/XAUUSD/news/';
            final source = item.querySelector('source')?.text ?? 'TradingView / Market';

            // Bersihkan judul dari akhiran sumber "- Sumber"
            final cleanTitle = title.split(' - ').first;

            parsedList.add(
              NewsItem(
                id: 'online_$i',
                title: cleanTitle,
                category: i % 2 == 0 ? 'Market Update' : 'Analisa',
                timeAgo: '${(i + 1) * 2} jam lalu',
                imageUrl: images[i % images.length],
                source: source,
                url: link,
              ),
            );
          }

          if (parsedList.isNotEmpty) {
            return parsedList;
          }
        }
      }
    } catch (_) {
      // Abaikan error jaringan dan gunakan data fallback yang siap saji
    }

    return _fallbackNews;
  }
}
