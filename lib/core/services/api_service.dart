import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://api.penyediadata.com/v1';
  static const String _apiKey = 'ec13af2a033d4cc9994865b4e65fe7a6';

  /// Fungsi mengambil data harga (bisa dipakai untuk XAU, HSI, dll)
  Future<Map<String, dynamic>> fetchMarketData(String symbol) async {
    final url = Uri.parse('$_baseUrl/market?symbol=$symbol&apikey=$_apiKey');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Gagal mengambil data. Kode status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan jaringan: $e');
    }
  }

  /// Mengambil kurs USD ke IDR secara live
  /// Prioritas 1: Google Finance (real-time spot rate)
  /// Prioritas 2: Frankfurter API
  /// Prioritas 3: OpenER API
  Future<double?> fetchLiveUsdIdrRate() async {
    // 1. Coba ambil langsung dari Google Finance
    try {
      final googleUrl = Uri.parse('https://www.google.com/finance/quote/USD-IDR');
      final response = await http.get(
        googleUrl,
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
          'Accept-Language': 'en-US,en;q=0.9',
        },
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final body = response.body;

        // Pattern 1: data-last-price="17715.00"
        final matchLastPrice = RegExp(r'data-last-price="([\d\.]+)"').firstMatch(body);
        if (matchLastPrice != null) {
          final priceStr = matchLastPrice.group(1);
          final price = double.tryParse(priceStr ?? '');
          if (price != null && price > 0) {
            return price;
          }
        }

        // Pattern 2: class="YMlStc">17,715.0000</div>
        final matchYMlStc = RegExp(r'class="[^"]*YMlStc[^"]*">([\d\.,]+)<').firstMatch(body);
        if (matchYMlStc != null) {
          final priceStr = matchYMlStc.group(1)?.replaceAll(',', '');
          final price = double.tryParse(priceStr ?? '');
          if (price != null && price > 0) {
            return price;
          }
        }

        // Pattern 3: data-currency-code="IDR" ... price
        final matchDataPrice = RegExp(r'data-currency-code="IDR"[^>]*>([\d\.,]+)<').firstMatch(body);
        if (matchDataPrice != null) {
          final priceStr = matchDataPrice.group(1)?.replaceAll(',', '');
          final price = double.tryParse(priceStr ?? '');
          if (price != null && price > 0) {
            return price;
          }
        }
      }
    } catch (_) {
      // Lanjut ke provider cadangan jika Google Finance terhambat
    }

    // 2. Coba provider Frankfurter API
    try {
      final frankfurterUrl = Uri.parse('https://api.frankfurter.app/latest?from=USD&to=IDR');
      final response = await http.get(frankfurterUrl).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['rates'] != null && data['rates']['IDR'] != null) {
          return (data['rates']['IDR'] as num).toDouble();
        }
      }
    } catch (_) {}

    // 3. Coba Open Exchange Rate API
    try {
      final url = Uri.parse('https://open.er-api.com/v6/latest/USD');
      final response = await http.get(url).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['result'] == 'success' && data['rates'] != null && data['rates']['IDR'] != null) {
          return (data['rates']['IDR'] as num).toDouble();
        }
      }
    } catch (_) {}

    return null;
  }
}
