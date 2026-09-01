import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';

class ScrapingService {
  
  // 1. Fungsi sekarang meminta parameter 'targetUrl' saat dipanggil
  Future<Map<String, dynamic>> fetchHistoricalPrices(String targetUrl) async {
    try {
      // 2. Gunakan targetUrl yang dikirimkan, bukan URL permanen
      final response = await http.get(Uri.parse(targetUrl));

      if (response.statusCode == 200) {
        Document document = parser.parse(response.body);
        var firstRow = document.querySelector('table[class*="min-w-[980px]"] tbody tr');

        if (firstRow != null) {
          var cells = firstRow.querySelectorAll('td');

          if (cells.length >= 5) {
            String date = cells[0].text.trim();
            double open = _parsePriceText(cells[1].text);
            double high = _parsePriceText(cells[2].text);
            double low = _parsePriceText(cells[3].text);
            double close = _parsePriceText(cells[4].text);

            return {
              'date': date,
              'open': open,
              'high': high,
              'low': low,
              'close': close,
            };
          } else {
            throw Exception('Struktur kolom tabel berubah.');
          }
        } else {
          throw Exception('Gagal menemukan baris data.');
        }
      } else {
        throw Exception('Server web menolak koneksi. Kode Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Proses Scraping terhenti: $e');
    }
  }

  double _parsePriceText(String text) {
    String cleanText = text.replaceAll(',', '').trim();
    return double.tryParse(cleanText) ?? 0.0;
  }
}