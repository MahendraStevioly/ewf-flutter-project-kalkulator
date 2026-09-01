import 'dart:convert';
import 'package:http/http.dart' as http;
// import '../models/commodity_model.dart'; // Buka komentar ini nanti jika Model sudah siap

class ApiService {
  // Ganti URL ini dengan alamat API sungguhan yang kamu gunakan (misal: AlphaVantage / NewsAPI)
  static const String _baseUrl = 'https://api.penyediadata.com/v1';
  static const String _apiKey = 'ec13af2a033d4cc9994865b4e65fe7a6';

  // Fungsi mengambil data harga (bisa dipakai untuk XAU, HSI, dll)
  Future<Map<String, dynamic>> fetchMarketData(String symbol) async {
    // Menyusun URL beserta parameter simbol komoditas dan API Key
    final url = Uri.parse('$_baseUrl/market?symbol=$symbol&apikey=$_apiKey');

    try {
      // Melakukan permintaan HTTP GET
      final response = await http.get(url);

      // Kode 200 berarti sukses
      if (response.statusCode == 200) {
        // Mengubah teks JSON dari internet menjadi format Map/Kamus Dart
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Idealnya, di sini data diubah menjadi objek Model, misal:
        // return CommodityModel.fromJson(data);
        return data;
      } else {
        // Lempar pesan error jika API menolak permintaan
        throw Exception('Gagal mengambil data. Kode status: ${response.statusCode}');
      }
    } catch (e) {
      // Lempar pesan error jika tidak ada internet atau timeout
      throw Exception('Terjadi kesalahan jaringan: $e');
    }
  }
}