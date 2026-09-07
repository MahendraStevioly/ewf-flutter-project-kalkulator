class NewsItem {
  const NewsItem({
    required this.id,
    required this.title,
    required this.category,
    required this.timeAgo,
    required this.imageUrl,
    this.source = 'TradingView / Market',
    this.url = '',
    this.snippet = '',
  });

  final String id;
  final String title;
  final String category;
  final String timeAgo;
  final String imageUrl;
  final String source;
  final String url;
  final String snippet;
}
