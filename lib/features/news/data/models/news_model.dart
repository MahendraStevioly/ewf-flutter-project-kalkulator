class NewsModel {
  final String title;
  final String link;
  final String pubDate;
  final String imageUrl;

  NewsModel({
    required this.title,
    required this.link,
    required this.pubDate,
    required this.imageUrl,
  });

  // Fungsi khusus untuk membongkar data dari format RSS
  factory NewsModel.fromRssItem(dynamic item) {
    // Mencari gambar dari tag <enclosure> atau <media:content>
    String parsedImage = '';
    if (item.enclosure != null && item.enclosure?.url != null) {
      parsedImage = item.enclosure!.url!;
    } else if (item.media?.contents != null && item.media!.contents!.isNotEmpty) {
      parsedImage = item.media!.contents!.first.url ?? '';
    }

    return NewsModel(
      title: item.title ?? 'Tanpa Judul',
      link: item.link ?? '',
      // Membersihkan format tanggal (opsional, bisa di-format ulang nanti)
      pubDate: item.pubDate?.toString() ?? '', 
      imageUrl: parsedImage,
    );
  }
}