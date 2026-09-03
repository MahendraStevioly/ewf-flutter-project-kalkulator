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
}
